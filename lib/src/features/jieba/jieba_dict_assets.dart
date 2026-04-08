import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'jieba_dict_type.dart';

class JiebaDictAssets {
  JiebaDictAssets._();

  /// 获取内置结巴分词文件。
  static Future<Map<JiebaDictType, Uint8List>> load() async {
    final jiebaAssetPaths = await loadPaths();
    return {
      for (final e in jiebaAssetPaths.entries)
        e.key: (await rootBundle.load(e.value)).buffer.asUint8List(),
    };
  }

  /// 获取内置结巴分词文件在 [AssetBundle] 中的路径，可通过 [rootBundle] 调用 [AssetBundle.load] 加载文件内容。
  static Future<Map<JiebaDictType, String>> loadPaths() async {
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
