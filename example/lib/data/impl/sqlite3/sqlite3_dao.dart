

import 'package:sqlite3/common.dart';

import '../../../utils/zero_width.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';

class Sqlite3Dao extends MainTableDao<CommonDatabase> {
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
    insertStmt.close();
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
    updateStmt.close();
  }
}