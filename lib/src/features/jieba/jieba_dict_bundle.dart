import 'package:flutter/services.dart';
import 'package:sqlite3_simple/assets.dart';

import '../../../jieba_dict.dart';

/// 结巴分词字典包
class JiebaDictBundle {
  /// 字典目录，应与 `select jieba_dict(...)` 使用的目录一致，默认 `./dict` 与 Simple 扩展一致
  final String directory;

  /// 字典文件 [JiebaDictType] 到对应字节的映射
  final Map<JiebaDictType, Uint8List> replacement;

  /// 默认使用本库内置的字典文件，可通过 [JiebaDictBundle.replacement] 进行自定义替换。
  const JiebaDictBundle({
    this.directory = "./dict",
    this.replacement = const <JiebaDictType, Uint8List>{},
  });

  /// 提供字典文件「路径 → 字节」的映射，供 Web 运行时注入。
  Future<Map<String, Uint8List>> toPathBytesMap() async {
    final assetPaths = await JiebaDictAssets.loadPaths();
    return Map.fromEntries(
      await Future.wait(
        assetPaths.entries.map((e) async {
          final path = "$directory/${e.key.filename}";
          final bytes =
              replacement[e.key] ??
              (await rootBundle.load(e.value)).buffer.asUint8List();
          return MapEntry(path, bytes);
        }),
      ),
    );
  }
}

class MissingJiebaDictException implements Exception {
  final List<String> missingTypes;

  MissingJiebaDictException(this.missingTypes);

  @override
  String toString() => 'MissingJiebaDictException: 缺少结巴字典文件 $missingTypes';
}
