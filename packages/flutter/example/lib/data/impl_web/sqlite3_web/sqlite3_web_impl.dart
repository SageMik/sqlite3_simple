import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3_simple/jieba_dict_assets.dart';
import 'package:sqlite3_simple/jieba_dict_type.dart';
import 'package:sqlite3_web/sqlite3_web.dart';

import '../../../utils/zero_width.dart';
import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../../search_result.dart';
import '../../main_table_schema.dart';
import '../../pinyin_dict_kind.dart';
import '../pinyin_dict.dart';
import 'sqlite3_web_worker.dart';

final class Sqlite3WebDbManager extends DbManager<Sqlite3WebDao, Database> {
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
    dao = Sqlite3WebDao(db);

    /// 传递结巴分词字典文件 URL 交由 `Sqlite3WebDb.handleCustomRequest` 处理
    final Map<JiebaDictType, String> jiebaDictPaths =
        await JiebaDictAssets.loadPaths();
    const jiebaDictDir = '.dict';
    await db.customRequest(
      {
        'type': 'updateJiebaDict',
        'path2url': {
          for (final e in jiebaDictPaths.entries)
            '$jiebaDictDir/${e.key.filename}': e.value,
        },
      }.jsify(),
    );
    await db.execute("SELECT jieba_dict(?)", parameters: [jiebaDictDir]);
    final init = await db.select(
      "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
    );
    if (kDebugMode) print(init.result);

    final version = (await db.select(
      "PRAGMA user_version",
    )).result.first['user_version'];
    if (version == 0) {
      for (final statement in createMainAndFts5Statements) {
        await db.execute(statement);
      }
      db.execute("PRAGMA user_version = 1");
    }
  }

  /// 传递拼音字典文件 URL 交由 [Sqlite3WebDb.handleCustomRequest] 处理
  @override
  Future<Map<PinyinDictKind, String>> savePinyinDict() async {
    const pinyinDictDir = "sqlite3_simple_example/pinyin_dict";
    final kind2url = PinyinDictKind.values.resolveUrl();
    final kind2path = {
      for (final k in kind2url.keys)
        k: (k.isBundled ? '' : '$pinyinDictDir/${k.assetName}'),
    };
    await dao.db.customRequest(
      {
        'type': 'savePinyinDict',
        'path2url': {
          for (final MapEntry(key: kind, value: url) in kind2url.entries.where(
            (e) => !e.key.isBundled,
          ))
            kind2path[kind]!: url,
        },
      }.jsify(),
    );
    return kind2path;
  }

  @override
  Future<void> close() {
    return dao.db.dispose();
  }
}

class Sqlite3WebDao extends MainTableDaoBase<Database> {
  Sqlite3WebDao(super.db);

  @override
  Future<void> insertRandomData(int length) async {
    await db.requestLock((token) async {
      for (int i = 0; i < length; i++) {
        final newRow = createRandomRow();
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
  Future<SearchResult> search(String value, Tokenizer tokenizer) async {
    final stopwatch = Stopwatch()..start();
    final tokenResult = await db.select(
      'SELECT ${tokenizer.queryFunctionName}(?) AS q',
      parameters: [value],
    );
    final tokens = '${tokenResult.result.first['q']}';
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = await db.select(
      '''
      SELECT 
        rowid AS $id, 
        simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
        simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
        $insertDate 
      FROM $fts5Table 
      WHERE $fts5Table MATCH ${tokenizer.queryFunctionName}(?);
    ''',
      parameters: [value],
    );
    stopwatch.stop();
    return SearchResult(
      rows: _toMainTableRows(resultSet.result),
      tokens: tokens,
      elapsed: stopwatch.elapsed,
    );
  }

  @override
  Future<void> updatePinyinDict(String newPath) async {
    await db.select("SELECT pinyin_dict(?)", parameters: [newPath]);
    await db.execute("INSERT INTO $fts5Table($fts5Table) VALUES('rebuild');");
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    final oldLen = mainTableRowList.length;
    final newCount = shuffledRowCount();
    await db.requestLock((token) async {
      for (int i = 0; i < newCount && i < oldLen; i++) {
        final newRow = createRandomRow();
        await db.execute(
          "UPDATE $mainTable SET $title = ?, $content = ?, $insertDate = ? WHERE $id = ?;",
          parameters: [
            newRow.title,
            newRow.content,
            newRow.insertDate.toDb(),
            mainTableRowList[i].id,
          ],
          token: token,
        );
      }

      for (int i = newCount; i < oldLen; i++) {
        await db.execute(
          "DELETE FROM $mainTable WHERE $id = ?;",
          parameters: [mainTableRowList[i].id],
          token: token,
        );
      }

      for (int i = oldLen; i < newCount; i++) {
        final newRow = createRandomRow();
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
}
