import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hooks/hooks.dart';

import '../defines.dart';
import '../targets.dart';

part 'download.dart';

part 'local.dart';

part 'none.dart';

const assetName = 'simple';

const defaultArchiveUrl =
    'https://github.com/SageMik/sqlite3_simple/releases/download/Nv3.0.0/libsimple.dart.zip';

sealed class SimpleSource {
  Future<void> build();

  factory SimpleSource.fromBuild(BuildInput input, BuildOutputBuilder output) {
    final config = input.config.code;
    final CodeConfig(:targetArchitecture) = config;
    final defines = SimpleUserDefines(input);
    final simpleOS = SimpleTargetOS.forConfig(config);

    /// 跳过用户指定平台架构
    final skip = defines.list('skip_targets');
    if (skip != null) {
      final osName = simpleOS.name;
      if (skip.any({osName, '$osName-${targetArchitecture.name}'}.contains)) {
        return const NoneSource();
      }
    }

    final info = SimpleSourceInfo(
      input: input,
      output: output,
      targetOS: simpleOS,
      targetArchitecture: targetArchitecture,
    );

    final src = defines.str('source');
    return switch (src) {
      null || 'download' => DownloadSource(
        info,
        url: defines.str('url') ?? defaultArchiveUrl,
        sha256: defines.str('sha256'),
      ),
      'local' => LocalSource(
        info,
        path:
            defines.path('path') ??
            (throw defines.exception('path', (it) => '$it is required when `source: local`')),
      ),
      'none' => const NoneSource(),
      _ => throw defines.exception(
        'source',
        (it) => 'Invalid value `$src` for $it, expected `download`, `local` or `none`',
      ),
    };
  }
}

class SimpleSourceInfo {
  final BuildInput input;
  final BuildOutputBuilder output;
  final SimpleTargetOS targetOS;
  final Architecture targetArchitecture;

  const SimpleSourceInfo({
    required this.input,
    required this.output,
    required this.targetOS,
    required this.targetArchitecture,
  });
}

mixin SimpleSourceInfoMixin implements SimpleSourceInfo {
  abstract final SimpleSourceInfo info;

  @override
  BuildInput get input => info.input;

  @override
  BuildOutputBuilder get output => info.output;

  @override
  SimpleTargetOS get targetOS => info.targetOS;

  @override
  Architecture get targetArchitecture => info.targetArchitecture;

  /// 产物在发布包中的文件名，例如 `libsimple.android.arm64.so`、`simple.windows.x64.dll`
  String get assetFileName =>
      targetOS.hookOS.dylibFileName('$assetName.${targetOS.name}.${targetArchitecture.name}');

  /// 在 [directoryUri] 下定位原生库
  File resolveAssetFile(Uri directoryUri) => File.fromUri(directoryUri.resolve(assetFileName));

  /// 原生库落地到构建目录时使用的文件名
  String get outFileName => targetOS.hookOS.dylibFileName(assetName);

  /// 解压压缩包到目标目录（已存在则跳过），失败时清理半截目录后重新抛出
  Future<void> _extractIfAbsent(File archiveFile, Directory targetDir) async {
    if (targetDir.existsSync()) return;
    try {
      await extractFileToDisk(archiveFile.path, targetDir.path);
    } on Object {
      if (targetDir.existsSync()) {
        await targetDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  /// 将原生库复制到构建输出目录并注册为 CodeAsset
  Future<void> _addToOutput(File assetFile) async {
    final outFile = File.fromUri(input.outputDirectory.resolve(outFileName));
    await outFile.parent.create(recursive: true);
    await assetFile.copy(outFile.path);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: assetName,
        linkMode: DynamicLoadingBundled(),
        file: outFile.uri,
      ),
    );
  }
}
