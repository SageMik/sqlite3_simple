import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';

import '../../db_manager.dart';
import '../pinyin_dict.dart';
import 'sqlite3_dao.dart';

final class Sqlite3DbManager extends DbManager<Sqlite3Dao, Database>
    with PinyinDictSaver, Sqlite3Fts5Creator {
  @override
  late final Sqlite3Dao dao;

  @override
  Future<void> init() async {
    sqlite3.loadSimpleExtension();

    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "sqlite3_simple_example/jieba_dict");
    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    if (kDebugMode) print("用于设置结巴分词字典路径：$jiebaDictSql");

    final db = sqlite3.openInMemory();
    dao = Sqlite3Dao(db);

    db.execute(jiebaDictSql);
    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    if (kDebugMode) print(init);

    final version = db.select("PRAGMA user_version").first['user_version'];
    if (version == 0) {
      await createMainAndFts5(db);
      db.execute("PRAGMA user_version = 1");
    }
  }

  @override
  Future<void> close() async => dao.db.close();
}
