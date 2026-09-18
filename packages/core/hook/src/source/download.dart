part of 'source.dart';

final class DownloadSource with SimpleSourceInfoMixin implements SimpleSource {
  DownloadSource(this.info, {required this.url, this.sha256});

  @override
  final SimpleSourceInfo info;

  /// 发布包的下载地址
  final String url;

  /// 发布包的 SHA-256 校验值，为空则跳过校验
  final String? sha256;

  /// 下载发布包并解压到缓存。
  ///
  /// 触发重新下载 + 解压的条件：
  /// - [url] 变更
  @override
  Future<void> build() async {
    final cacheRoot = input.outputDirectoryShared.resolve(
      crypto.sha256.convert(utf8.encode(url)).toString().substring(0, 16),
    );
    final cacheDir = Directory.fromUri(cacheRoot.resolve('lib$assetName/'));
    final archiveFileName = Uri.parse(url).pathSegments.last;
    final archiveFile = File.fromUri(cacheRoot.resolve(archiveFileName));
    if (!archiveFile.existsSync()) {
      await _download(archiveFile);
    }
    await _extractIfAbsent(archiveFile, cacheDir);
    output.dependencies.add(archiveFile.uri);
    await _addToOutput(resolveAssetFile(cacheDir.uri));
  }

  Future<void> _download(File localFile) async {
    final uri = Uri.parse(url);
    final client = HttpClient()
      ..findProxy = HttpClient.findProxyFromEnvironment;
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) {
        throw StateError(
          'Failed to download $uri: [${response.statusCode}] ${response.reasonPhrase}',
        );
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }

      final expected = sha256;
      if (expected != null) {
        final actual = crypto.sha256.convert(bytes).toString();
        if (actual != expected) {
          throw StateError(
            'Checksum mismatch for $uri\n  expected: $expected\n  actual:   $actual',
          );
        }
      }
      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes(bytes);
    } finally {
      client.close();
    }
  }
}
