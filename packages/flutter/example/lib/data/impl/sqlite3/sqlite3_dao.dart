import 'package:sqlite3/common.dart';

import '../../../utils/zero_width.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../../search_result.dart';
import '../../main_table_schema.dart';

class Sqlite3Dao extends MainTableDaoBase<CommonDatabase> {
  Sqlite3Dao(super.db);

  @override
  Future<void> insertRandomData(int length) async {
    final insertStmt = db.prepare("INSERT INTO $mainTable VALUES(?, ?, ?, ?);");
    for (int i = 0; i < length; i++) {
      final newRow = createRandomRow();
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
  Future<SearchResult> search(String value, Tokenizer tokenizer) async {
    final stopwatch = Stopwatch()..start();
    final tokens =
        '${db.select('SELECT ${tokenizer.queryFunctionName}(?) AS q', [value]).first['q']}';
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = db.select('''
      SELECT 
        rowid AS $id, 
        simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
        simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
        $insertDate 
      FROM $fts5Table 
      WHERE $fts5Table MATCH ${tokenizer.queryFunctionName}(?);
    ''', [value]);
    stopwatch.stop();
    return SearchResult(
      rows: _toMainTableRows(resultSet),
      tokens: tokens,
      elapsed: stopwatch.elapsed,
    );
  }

  @override
  Future<void> updatePinyinDict(String newPath) async {
    db.select("SELECT pinyin_dict(?)", [newPath]);
    db.execute("INSERT INTO $fts5Table($fts5Table) VALUES('rebuild');");
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    final oldLen = mainTableRowList.length;
    final newCount = shuffledRowCount();

    final updateStmt = db.prepare(
        "UPDATE $mainTable SET $title = ?, $content = ?, $insertDate = ? WHERE $id = ?;");
    for (int i = 0; i < newCount && i < oldLen; i++) {
      final newRow = createRandomRow();
      updateStmt.execute([
        newRow.title,
        newRow.content,
        newRow.insertDate.toDb(),
        mainTableRowList[i].id,
      ]);
    }
    updateStmt.close();

    final deleteStmt = db.prepare("DELETE FROM $mainTable WHERE $id = ?;");
    for (int i = newCount; i < oldLen; i++) {
      deleteStmt.execute([mainTableRowList[i].id]);
    }
    deleteStmt.close();

    final insertStmt = db.prepare("INSERT INTO $mainTable VALUES(?, ?, ?, ?);");
    for (int i = oldLen; i < newCount; i++) {
      final newRow = createRandomRow();
      insertStmt.execute([
        null,
        newRow.title,
        newRow.content,
        newRow.insertDate.toDb(),
      ]);
    }
    insertStmt.close();
  }
}