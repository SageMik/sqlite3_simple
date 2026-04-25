import 'package:flutter/foundation.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3_simple/assets.dart';
import 'package:sqlite3_web/sqlite3_web.dart';

import '../../../utils/zero_width.dart';
import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import 'sqlite3_web_request.dart';

final class Sqlite3WebDbManager extends DbManager<Sqlite3WebDao> {
  late final WebSqlite _webSqlite3;

  @override
  late final Sqlite3WebDao dao;

  @override
  Future<void> init() async {
    _webSqlite3 = WebSqlite.open(
      workers: WorkerConnector.defaultWorkers(
        Uri.parse('sqlite3_web_worker.dart.js'),
      ),
      wasmModule: Uri.parse('sqlite3.wasm'),
    );

    /// `inMemoryShared` 会创建 Shared Worker，需要通过 `chrome://inspect/#workers` -> `inspect` 查看打印的日志
    final db = await _webSqlite3.connect(
      'database',
      DatabaseImplementation.inMemoryShared,
    );

    final jiebaDictPaths = await JiebaDictAssets.loadPaths();
    const jiebaDictDir = '.dict';
    await db.customRequest(
      UpdateJiebaDictRequest({
        for (final e in jiebaDictPaths.entries)
          '$jiebaDictDir/${e.key.filename}': e.value,
      }).toJs(),
    );
    await db.execute("SELECT jieba_dict(?)", parameters: [jiebaDictDir]);
    final init = await db.select(
      "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
    );
    if (kDebugMode) print(init.result);

    dao = Sqlite3WebDao(db);
    await dao.initFts5();
  }

  @override
  Future<void> close() {
    return dao.db.dispose();
  }
}

class Sqlite3WebDao extends MainTableDaoBase<Database> {
  Sqlite3WebDao(super.db);

  final fts5Tokenizer = "simple";
  final mainTable = "custom";
  final id = "id",
      title = "title",
      content = "content",
      insertDate = "insert_date";
  final fts5Table = "t1";

  @override
  Future<void> initFts5() async {
    await db.execute('''
      CREATE TABLE $mainTable (
        $id INTEGER PRIMARY KEY AUTOINCREMENT, 
        $title TEXT, 
        $content TEXT, 
        $insertDate INTEGER
      );
    ''');

    await db.execute('''
      CREATE VIRTUAL TABLE $fts5Table USING fts5(
        $title, $content, $insertDate UNINDEXED, 
        tokenize = '$fts5Tokenizer', 
        content = '$mainTable', 
        content_rowid = '$id'
      );
    ''');

    final newInsert =
        '''
      INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
        VALUES (new.$id, new.$title, new.$content, new.$insertDate);
    ''';
    final deleteInsert =
        '''
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
  Future<void> insertRandomData(int length) async {
    await db.requestLock((token) async {
      for (int i = 0; i < length; i++) {
        final newRow = createRandomRow(i);
        await db.execute(
          "INSERT INTO $mainTable VALUES(?, ?, ?, ?);",
          parameters: [
            null,
            newRow.title,
            newRow.content,
            newRow.insertDate.toDb(),
          ],
          token: token,
        );
      }
    });
  }

  List<MainTableRow> _toMainTableRows(ResultSet resultSet) {
    return List.generate(resultSet.length, (i) {
      final r = resultSet.elementAt(i);
      return MainTableRow(
        id: r[id],
        title: r[title],
        content: r[content],
        insertDate: (r[insertDate] as int).toEntity(),
      );
    });
  }

  @override
  Future<List<MainTableRow>> selectAll() async {
    final result = await db.select("SELECT * FROM $mainTable");
    return _toMainTableRows(result.result);
  }

  @override
  Future<int> selectCount() async {
    final result = await db.select("SELECT COUNT(*) as c FROM $mainTable");
    return result.result.first['c'];
  }

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = await db.select(
      '''
      SELECT 
        rowid AS $id, 
        simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
        simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
        $insertDate 
      FROM $fts5Table 
      WHERE $fts5Table MATCH ${tokenizer.name}_query(?);
    ''',
      parameters: [value],
    );
    return _toMainTableRows(resultSet.result);
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    await db.requestLock((token) async {
      for (int i = 0; i < mainTableRowList.length; i++) {
        final oldRow = mainTableRowList[i];
        final newRow = createRandomRow(i);
        await db.execute(
          "UPDATE $mainTable SET $title = ?, $content = ?, $insertDate = ? WHERE $id = ?;",
          parameters: [
            newRow.title,
            newRow.content,
            newRow.insertDate.toDb(),
            oldRow.id,
          ],
          token: token,
        );
      }
    });
  }
}
