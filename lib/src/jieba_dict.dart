import 'package:flutter/services.dart';
import 'package:path/path.dart';

/// 结巴分词字典包
class JiebaDictBundle {
  /// 字典目录，应与 `select jieba_dict(...)` 使用的目录一致，默认 `./dict` 与 Simple 扩展一致
  final String directory;

  /// 字典文件 [JiebaDictType] 到对应字节的映射
  final Map<JiebaDictType, Uint8List> type2bytes;

  /// 默认使用本库内置的字典文件，可通过 [JiebaDictBundle.type2bytes] 自定义。
  const JiebaDictBundle({
    this.directory = "./dict",
    this.type2bytes = const <JiebaDictType, Uint8List>{},
  });

  /// 提供字典文件「路径 → 字节」的映射，供 Web 运行时注入。
  Future<Map<String, Uint8List>> resolvePath2Bytes() async {
    final assetPaths = await JiebaDictType.resolveAssetPaths();
    return Map.fromEntries(
      await Future.wait(
        assetPaths.entries.map((e) async {
          final path = "$directory/${e.key.filename}";
          final bytes =
              type2bytes[e.key] ??
              (await rootBundle.load(e.value)).buffer.asUint8List();
          return MapEntry(path, bytes);
        }),
      ),
    );
  }
}

/// 结巴分词所需的字典文件，每个字典文件视为一个类型，详见 [simple_tokenizer.cc](https://github.com/wangfenjin/simple/blob/4ed008934495fc55ff4bf6620bba58311988b23e/src/simple_tokenizer.cc#L96-L98) 。
enum JiebaDictType {
  jiebaDictUtf8("jieba.dict.utf8"),
  hmmModelUtf8("hmm_model.utf8"),
  userDictUtf8("user.dict.utf8"),
  idfUtf8("idf.utf8"),
  stopWordsUtf8("stop_words.utf8");

  const JiebaDictType(this.filename);

  /// 文件名
  final String filename;

  /// [filename] 到 [JiebaDictType] 的映射
  static final Map<String, JiebaDictType> byFilename = Map.unmodifiable({
    for (final k in values) k.filename: k,
  });

  /// 获取内置结巴分词文件在 [AssetBundle] 中的路径，可通过 [rootBundle] 调用 [AssetBundle.load] 加载文件内容。
  static Future<Map<JiebaDictType, String>> resolveAssetPaths() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final kind2path = <JiebaDictType, String>{};
    for (final path in assetManifest.listAssets()) {
      if (!path.startsWith("packages/sqlite3_simple") ||
          !path.contains("cpp_jieba_dict")) {
        continue;
      }
      final kind = JiebaDictType.byFilename[basename(path)];
      if (kind == null) {
        continue;
      }
      kind2path[kind] = path;
    }
    return kind2path;
  }
}
