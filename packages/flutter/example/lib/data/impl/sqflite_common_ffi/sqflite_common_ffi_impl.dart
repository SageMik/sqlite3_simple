import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' hide Database;
import 'package:sqlite3_simple/sqlite3_simple.dart';

import '../../../utils/zero_width.dart';
import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../../main_table_schema.dart';
import '../pinyin_dict.dart';

final class SqfliteCommonFfiDbManager extends DbManager<SqfliteCommonFfiDao, Database>
    with PinyinDictSaver {
  @override
  late final SqfliteCommonFfiDao dao;

  @override
  Future<void> init() async {
    sqfliteFfiInit();

    sqlite3.loadSimpleExtension();

    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "sqlite3_simple_example/jieba_dict");
    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    if (kDebugMode) print("用于设置结巴分词字典路径：$jiebaDictSql");

    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          for (final statement in createMainAndFts5Statements) {
            await db.execute(statement);
          }
        },
      ),
    );
    dao = SqfliteCommonFfiDao(db);

    db.execute(jiebaDictSql);
    final init = await db.rawQuery(
      "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
    );
    if (kDebugMode) print(init);
  }

  @override
  Future<void> close() => dao.db.close();
}

class SqfliteCommonFfiDao extends MainTableDaoBase<Database> {
  SqfliteCommonFfiDao(super.db);

  @override
  Future<void> insertRandomData(int length) async {
    for (int i = 0; i < length; i++) {
      final newRow = createRandomRow();
      await db.insert(mainTable, {
        id: null,
        title: newRow.title,
        content: newRow.content,
        insertDate: newRow.insertDate.toDb(),
      });
    }
  }

  /// 将查询结果转为实体类
  List<MainTableRow> _toMainTableRows(List<Map<String, Object?>> result) {
    return result.map((columnName2Value) {
      return MainTableRow(
        id: columnName2Value[id] as int,
        title: columnName2Value[title] as String,
        content: columnName2Value[content] as String,
        insertDate: (columnName2Value[insertDate] as int).toEntity(),
      );
    }).toList();
  }

  @override
  Future<List<MainTableRow>> selectAll() async =>
      _toMainTableRows(await db.query(mainTable));

  @override
  Future<int> selectCount() async =>
      (await db.query(mainTable, columns: ["COUNT(*) as c"])).first["c"] as int;

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final result = await db.query(
      fts5Table,
      columns: [
        "rowid AS $id",
        "simple_highlight($fts5Table, 0, $wrapperSql) AS $title",
        "simple_highlight($fts5Table, 1, $wrapperSql) AS $content",
        insertDate
      ],
      where: "$fts5Table MATCH ${tokenizer.queryFunctionName}(?)",
      whereArgs: [value],
    );
    return _toMainTableRows(result);
  }

  @override
  Future<void> updatePinyinDict(String newPath) async {
    await db.rawQuery("SELECT pinyin_dict(?)", [newPath]);
    await db.execute("INSERT INTO $fts5Table($fts5Table) VALUES('rebuild');");
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    final oldLen = mainTableRowList.length;
    final newCount = shuffledRowCount();

    for (int i = 0; i < newCount && i < oldLen; i++) {
      final newRow = createRandomRow();
      await db.update(
        mainTable,
        {
          title: newRow.title,
          content: newRow.content,
          insertDate: newRow.insertDate.toDb(),
        },
        where: "$id = ?",
        whereArgs: [mainTableRowList[i].id],
      );
    }

    for (int i = newCount; i < oldLen; i++) {
      await db.delete(
        mainTable,
        where: "$id = ?",
        whereArgs: [mainTableRowList[i].id],
      );
    }

    for (int i = oldLen; i < newCount; i++) {
      final newRow = createRandomRow();
      await db.insert(mainTable, {
        id: null,
        title: newRow.title,
        content: newRow.content,
        insertDate: newRow.insertDate.toDb(),
      });
    }
  }
}
