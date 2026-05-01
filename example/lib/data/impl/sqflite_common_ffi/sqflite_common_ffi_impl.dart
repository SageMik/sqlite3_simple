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

final class SqfliteCommonFfiDbManager extends DbManager<SqfliteCommonFfiDao>
    implements Fts5Creator<Database> {
  @override
  late final SqfliteCommonFfiDao dao;

  @override
  Future<void> init() async {
    sqfliteFfiInit();

    sqlite3.loadSimpleExtension();

    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "cpp_jieba");
    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    if (kDebugMode) print("用于设置结巴分词字典路径：$jiebaDictSql");

    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => createMainAndFts5(db),
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
  @protected
  Future<void> createMainAndFts5(Database db) async {
    /// 主表
    await db.execute('''
      CREATE TABLE $mainTable (
        $id INTEGER PRIMARY KEY AUTOINCREMENT, 
        $title TEXT, 
        $content TEXT, 
        $insertDate INTEGER
      );
    ''');

    /// FTS5虚表
    await db.execute('''
      CREATE VIRTUAL TABLE $fts5Table USING fts5(
        $title, $content, $insertDate UNINDEXED, 
        tokenize = '$fts5Tokenizer', 
        content = '$mainTable', 
        content_rowid = '$id'
      );
    ''');

    /// 触发器
    const newInsert = '''
      INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
        VALUES (new.$id, new.$title, new.$content, new.$insertDate);
    ''';
    const deleteInsert = '''
      INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate) 
        VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
    ''';
    await db.execute('''
      CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
        $newInsert
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
        $deleteInsert
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
        $deleteInsert
        $newInsert
      END;
    ''');
  }

  @override
  Future<void> close() => dao.db.close();
}

class SqfliteCommonFfiDao extends MainTableDaoBase<Database> {
  SqfliteCommonFfiDao(super.db);

  @override
  Future<void> insertRandomData(int length) async {
    for (int i = 0; i < length; i++) {
      final newRow = createRandomRow(i);
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
      where: "$fts5Table MATCH ${tokenizer.name}_query(?)",
      whereArgs: [value],
    );
    return _toMainTableRows(result);
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    for (int i = 0; i < mainTableRowList.length; i++) {
      final oldRow = mainTableRowList[i];
      final newRow = createRandomRow(i);
      db.update(
        mainTable,
        {
          title: newRow.title,
          content: newRow.content,
          insertDate: newRow.insertDate.toDb(),
        },
        where: "$id = ?",
        whereArgs: [oldRow.id],
      );
    }
  }
}
