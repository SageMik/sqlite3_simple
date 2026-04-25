import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

import '../common/jieba_dict_type.dart';

class JiebaDictAssets {
  JiebaDictAssets._();

  /// 获取内置结巴分词文件在 [AssetBundle] 中的路径。由于涉及访问 [AssetBundle] 的资源，该方法需要在主隔离（Main Isolate）中调用。
  /// - 非 Web 平台：`packages/sqlite3_simple/cpp_jieba_dict/xxx.utf8`，可通过 [rootBundle] 或 [DefaultAssetBundle.of] 在主隔离中 [AssetBundle.load] 加载文件内容；
  /// - Web 平台：`assets/packages/sqlite3_simple/cpp_jieba_dict/xxx.utf8`，可通过 JavaScript 的 [fetch] 函数加载文件内容，建议在 Web Worker 中加载避免阻塞主线程。
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
      kind2path[kind] = !kIsWeb ? path : "assets/$path";
    }
    return kind2path;
  }
}
