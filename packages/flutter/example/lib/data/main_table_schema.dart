// final fts5Tokenizer = "simple 0";  // 关闭拼音搜索
const fts5Tokenizer = "simple";
const mainTable = "custom";
const id = "id",
    title = "title",
    content = "content",
    insertDate = "insert_date";
const fts5Table = "t1";

/// 主表、FTS5 虚表及其触发器的建表语句，供各原始 SQL 实现共用。
/// 官方说明：https://sqlite.org/fts5.html
const createMainAndFts5Statements = <String>[
  /// 主表
  '''
    CREATE TABLE $mainTable (
      $id INTEGER PRIMARY KEY AUTOINCREMENT, 
      $title TEXT, 
      $content TEXT, 
      $insertDate INTEGER
    );
  ''',

  /// FTS5 虚表
  '''
    CREATE VIRTUAL TABLE $fts5Table USING fts5(
      $title, $content, $insertDate UNINDEXED, 
      tokenize = '$fts5Tokenizer', 
      content = '$mainTable', 
      content_rowid = '$id'
    );
  ''',

  /// 触发器
  '''
    CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
      $_newInsert
    END;
  ''',
  '''
    CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
      $_deleteInsert
    END;
  ''',
  '''
    CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
      $_deleteInsert
      $_newInsert
    END;
  ''',
];

const _newInsert = '''
  INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
    VALUES (new.$id, new.$title, new.$content, new.$insertDate);
''';

const _deleteInsert = '''
  INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate) 
    VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
''';
