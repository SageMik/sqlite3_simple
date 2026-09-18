import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';
import 'package:sqlite3_simple_core/jieba_dict_type.dart';

import '../../jieba_dict_assets.dart';

extension Sqlite3SimpleEx on Sqlite3 {
  /// 将结巴分词字典文件保存到指定目录 [dir] 。
  ///
  /// 由于涉及访问 [AssetBundle] 的资源，该方法需要在 **主隔离 (Main Isolate)** 中调用。
  ///
  /// 当字典文件存在时，通过 [overwriteWhenExist] 控制是否覆盖，默认不覆盖。
  ///
  /// 使用结巴分词功能需要执行本方法返回的 SQL 语句，或自行实现相似逻辑。
  ///
  /// 另请参阅 [saveJiebaDictFromBytes] 。
  Future<String> saveJiebaDict(
    String dir, {
    bool overwriteWhenExist = false,
  }) async {
    final jiebaDictPath = await JiebaDictAssets.loadPaths();
    final dictData = <JiebaDictType, Uint8List>{};
    for (final entry in jiebaDictPath.entries) {
      final data = await rootBundle.load(entry.value);
      dictData[entry.key] = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
    }
    return saveJiebaDictFromBytes(
      dir,
      dict: dictData,
      overwriteWhenExist: overwriteWhenExist,
    );
  }
}
