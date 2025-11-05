import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';

import '../../utils/zero_width.dart';
import '../db_manager.dart';
import '../main_table_dao.dart';
import '../main_table_row.dart';

class Sqlite3DbManager extends IDbManager<Sqlite3Dao> {
  @override
  late final Sqlite3Dao dao;

  @override
  Future<void> init() async {
    // // [Android SQLite 覆盖]
    // _overrideForAndroid();

    sqlite3.loadSimpleExtension();

    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "cpp_jieba");
    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    if (kDebugMode) print("用于设置结巴分词字典路径：$jiebaDictSql");

    final db = sqlite3.openInMemory();
    dao = Sqlite3Dao(db);

    db.execute(jiebaDictSql);
    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    if (kDebugMode) print(init);

    await dao.initFts5();
  }

  @override
  Future<void> dispose() async => dao.db.dispose();

// /// 自定义 SQLite Android 示例，请全局搜索 Android SQLite 覆盖 来查看与此相关的配置。
// /// 如果你想自定义 SQLite 原生库，可以参考 本方法 或 sqlite3 的文档说明。
// /// 本方法将原来 sqlite3_flutter_libs 的 [libsqlite.so]，替换为了 sqlite-android 的 [libsqlite3x.so]
// void _overrideForAndroid() {
//   open.overrideFor(
//       OperatingSystem.android, () => DynamicLibrary.open("libsqlite3x.so"));
// }

}

class Sqlite3Dao extends IMainTableDao<Database> {
  Sqlite3Dao(super.db);

  // final fts5Tokenizer = "simple 0";  // 关闭拼音搜索
  final fts5Tokenizer = "simple";
  final mainTable = "custom";
  final id = "id",
      title = "title",
      content = "content",
      insertDate = "insert_date";
  final fts5Table = "t1";

  @override
  Future<void> initFts5() async {
    /// 主表
    db.execute('''
      CREATE TABLE $mainTable (
        $id INTEGER PRIMARY KEY AUTOINCREMENT, 
        $title TEXT, 
        $content TEXT, 
        $insertDate INTEGER
      );
    ''');

    /// FTS5虚表
    db.execute('''
      CREATE VIRTUAL TABLE $fts5Table USING fts5(
        $title, $content, $insertDate UNINDEXED, 
        tokenize = '$fts5Tokenizer', 
        content = '$mainTable', 
        content_rowid = '$id'
      );
    ''');

    /// 触发器
    final newInsert = '''
      INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
        VALUES (new.$id, new.$title, new.$content, new.$insertDate);
    ''';
    final deleteInsert = '''
      INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate) 
        VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
    ''';
    db.execute('''
      CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
        $newInsert
      END;
    ''');
    db.execute('''
      CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
        $deleteInsert
      END;
    ''');
    db.execute('''
      CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
        $deleteInsert
        $newInsert
      END;
    ''');
  }

  @override
  Future<void> insertRandomData(int length) async {
    final insertStmt = db.prepare("INSERT INTO $mainTable VALUES(?, ?, ?, ?);");
    for (int i = 0; i < length; i++) {
      final newRow = buildRow(i);
      insertStmt.execute([
        null,
        newRow.title,
        newRow.content,
        newRow.insertDate.toDb(),
      ]);
    }
    insertStmt.dispose();
  }

  /// 将查询结果转为实体类
  List<MainTableRow> _toMainTableRows(ResultSet resultSet) {
    return List.generate(
      resultSet.length,
      (i) {
        final r = resultSet.elementAt(i);
        return MainTableRow(
          id: r[id],
          title: r[title],
          content: r[content],
          insertDate: (r[insertDate] as int).toEntity(),
        );
      },
    );
  }

  @override
  Future<List<MainTableRow>> selectAll() async =>
      _toMainTableRows(db.select("SELECT * FROM $mainTable"));

  @override
  Future<int> selectCount() async =>
      db.select("SELECT COUNT(*) as c FROM $mainTable").first['c'];

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = db.select('''
      SELECT 
        rowid AS $id, 
        simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
        simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
        $insertDate 
      FROM $fts5Table 
      WHERE $fts5Table MATCH ${tokenizer.name}_query(?);
    ''', [value]);
    return _toMainTableRows(resultSet);
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    final updateStmt = db.prepare(
        "UPDATE $mainTable SET $title = ?, $content = ?, $insertDate = ? WHERE $id = ?;");
    for (int i = 0; i < mainTableRowList.length; i++) {
      final oldRow = mainTableRowList[i];
      final newRow = buildRow(i);
      updateStmt.execute(
          [newRow.title, newRow.content, newRow.insertDate.toDb(), oldRow.id]);
    }
    updateStmt.dispose();
  }
}