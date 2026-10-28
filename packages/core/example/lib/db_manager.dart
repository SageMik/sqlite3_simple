import 'package:sqlite3/common.dart';
import 'package:sqlite3_simple_core_example/search_result.dart';

const id = 'id';
const mainTable = 'main';
const fts5Table = 'fts5';
const title = 'title';
const content = 'content';

class DbManager {
  final CommonDatabase _db;

  DbManager._(this._db);

  static Future<DbManager> create(
    Future<CommonDatabase> Function() buildDatabase,
  ) async {
    final dbManager = DbManager._(await buildDatabase());
    await dbManager._onCreate();
    return dbManager;
  }

  Future<void> _onCreate() async {
    final version = _db.select("PRAGMA user_version").first['user_version'];
    if (version != 0) {
      return;
    }

    /// 主表
    _db.execute('''
      CREATE TABLE $mainTable (
        $id INTEGER PRIMARY KEY AUTOINCREMENT, 
        $title TEXT, 
        $content TEXT
      );
    ''');

    /// FTS5 虚表
    _db.execute('''
      CREATE VIRTUAL TABLE $fts5Table USING fts5(
        $title, $content, 
        tokenize = 'simple', 
        content = '$mainTable', 
        content_rowid = '$id'
      );
    ''');

    /// 触发器
    const newInsert =
        "INSERT INTO $fts5Table(rowid, $title, $content) VALUES (new.$id, new.$title, new.$content);";
    const deleteInsert =
        "INSERT INTO $fts5Table($fts5Table, rowid, $title, $content) VALUES ('delete', old.$id, old.$title, old.$content);";
    _db.execute('''
      CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
        $newInsert
      END;
    ''');
    _db.execute('''
      CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
        $deleteInsert
      END;
    ''');
    _db.execute('''
      CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
        $deleteInsert
        $newInsert
      END;
    ''');

    /// 插入示例数据
    final insertStmt = _db.prepare("INSERT INTO $mainTable VALUES(?, ?, ?);");
    for (final (title, content) in [
      (
        'Simple',
        '由 @wangfenjin 开发的 SQLite FTS5 全文搜索扩展，支持中文和拼音搜索，'
            '提供 simple_query、jieba_query、simple_highlight 等查询辅助函数，开箱即用。',
      ),
      (
        'FTS5',
        'SQLite 内置的第五代全文检索引擎，是一个为数据库应用提供全文搜索功能的虚拟表模块。'
            '基于倒排索引实现高效的文本匹配，并支持通过 tokenize 选项接入自定义分词器。'
            '检索日志时时间字段一般取自 datetime()，形如 2026-10-29 09:05:00，'
            '空格、冒号和短横线都会把它切成多个 token 参与建索引。',
      ),
      (
        'Dart Hooks',
        'Dart 官方的构建钩子机制，允许包在应用构建期通过 build hook 编译或获取'
            '原生资产（native assets），并在构建产物中自动打包分发。',
      ),
      (
        'sqlite3_web',
        'sqlite3.dart 官方仓库提供的 Web 适配库，基于 WebAssembly 构建，'
            '通过 Web Worker 提供异步数据库 API，并支持 OPFS、IndexedDB 等持久化文件系统。',
      ),
    ]) {
      insertStmt.execute([null, title, content]);
    }
    insertStmt.close();

    _db.execute('PRAGMA user_version = 1;');
  }

  Future<SearchResult> searchByJieba(String query) async {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final tokens = query.isEmpty
        ? ''
        : '${_db.select('SELECT jieba_query(?) AS q', [query]).first['q']}';
    final resultSet = query.isEmpty
        ? _db.select('SELECT $title, $content FROM $mainTable')
        : _db.select(
            '''
              SELECT 
                rowid AS $id, 
                simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
                simple_highlight($fts5Table, 1, $wrapperSql) AS $content 
              FROM $fts5Table 
              WHERE $fts5Table MATCH jieba_query(?);
            ''',
            [query],
          );
    return SearchResult(
      tokens: tokens,
      rows: [
        for (final row in resultSet)
          SearchRow(
            title: row[title] as String,
            content: row[content] as String,
          ),
      ],
    );
  }

  Future<void> close() async => _db.close();
}
