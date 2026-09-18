part of 'source.dart';

final class LocalSource with SimpleSourceInfoMixin implements SimpleSource {
  @override
  final SimpleSourceInfo info;

  LocalSource(this.info, {required this.path});

  /// 本地原生库，可以是单个文件、压缩包或已解压目录
  final Uri path;

  /// 支持的压缩包扩展名
  static const _archiveExtensions = {
    '.zip',
    '.tar',
    '.tar.gz',
    '.tgz',
    '.tar.bz2',
    '.tbz',
    '.tar.xz',
    '.txz',
  };

  bool _isArchive(String fileName) =>
      _archiveExtensions.contains(getInputExtension(fileName));

  /// 从本地路径提供原生库（支持压缩包 / 目录 / 单个文件）。
  ///
  /// 触发更新的条件：
  /// - 压缩包：内容变化
  /// - 目录 / 单个文件：产物文件内容变化
  @override
  Future<void> build() async {
    File src;
    final Uri dependency;

    if (_isArchive(path.path)) {
      final archiveFile = File.fromUri(path);
      dependency = archiveFile.uri;
      final zipHash = crypto.sha256
          .convert(await archiveFile.readAsBytes())
          .toString();
      final cacheDir = Directory.fromUri(
        input.outputDirectoryShared.resolve(
          '${zipHash.substring(0, 16)}/lib$assetName',
        ),
      );
      await _extractIfAbsent(archiveFile, cacheDir);
      src = resolveAssetFile(cacheDir.uri);
      if (!src.existsSync()) {
        throw StateError(
          'Required $expectedAssetFileNames not found in archive $path',
        );
      }
    } else if (Directory.fromUri(path).existsSync()) {
      src = resolveAssetFile(Uri.directory(path.toFilePath()));
      if (!src.existsSync()) {
        throw StateError(
          'Required $expectedAssetFileNames not found in local directory $path',
        );
      }
      dependency = src.uri;
    } else {
      src = File.fromUri(path);
      dependency = src.uri;
    }

    output.dependencies.add(dependency);
    await _addToOutput(src);
  }
}
