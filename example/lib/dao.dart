import 'dart:math';

import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';
import 'package:sqlite3_simple_example/util/random_words.dart';

import 'util/zero_width_text.dart';

class MainTableRow {
  final int id;
  final String title;
  final String content;
  final DateTime insertDate;

  const MainTableRow(this.id, this.title, this.content, this.insertDate);
}

class Dao {
  late final Database db;

  final Database Function() dbBuilder;

  Dao(this.dbBuilder);

  /// 初始化 Simple 分词器，并将结巴分词字典文件保存到本地
  Future<void> init(String jiebaDictPath) async {
    sqlite3.loadSimpleExtension();

    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    print("用于设置结巴分词字典路径：$jiebaDictSql");

    db = dbBuilder();

    db.execute(jiebaDictSql);
    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    print(init);

    _initFts5();
  }

  // final tokenizer = "simple 0";  // 关闭拼音搜索
  final tokenizer = "simple";
  final mainTable = "custom";
  final id = "id",
      title = "title",
      content = "content",
      insertDate = "insert_date";
  final fts5Table = "t1";

  /// 初始化 SQLite FTS5 虚表
  /// 参考：https://sqlite.org/fts5.html
  void _initFts5() {
    /// 主表
    db.execute("CREATE TABLE $mainTable ("
        "$id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$title TEXT,"
        "$content TEXT,"
        "$insertDate INTEGER"
        ");");

    /// Fts5虚表
    db.execute("CREATE VIRTUAL TABLE $fts5Table USING fts5("
        "$title, $content, $insertDate UNINDEXED, "
        "tokenize = '$tokenizer',"
        "content = '$mainTable',"
        "content_rowid = '$id'"
        ");");

    /// 触发器
    final newInsert = "INSERT INTO $fts5Table(rowid, $title, $content) "
        "VALUES (new.$id, new.$title, new.$content);";
    final deleteInsert =
        "INSERT INTO $fts5Table($fts5Table, rowid, $title, $content) "
        "VALUES ('delete', old.$id, old.$title, old.$content);";
    db.execute(
        "CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN "
        "$newInsert"
        "END;");
    db.execute(
        "CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN "
        "$deleteInsert"
        "END;");
    db.execute(
        "CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN "
        "$deleteInsert"
        "$newInsert"
        "END;");
  }

  /// 将查询结果转为实体类
  List<MainTableRow> _toMainTableRows(ResultSet resultSet) {
    return List.generate(
      resultSet.length,
      (i) {
        final r = resultSet.elementAt(i);
        return MainTableRow(r[id], r[title], r[content],
            DateTime.fromMillisecondsSinceEpoch(r[insertDate]));
      },
    );
  }

  /// 构造随机中文词组数据
  List<Object?> _buildData(int index) {
    return [
      randomWords(minLength: 2, maxLength: 3),
      randomWords(minLength: 4, maxLength: 10),
      DateTime.utc(2000, 1, 1)
          .add(Duration(days: index, minutes: Random().nextInt(61)))
          .millisecondsSinceEpoch,
    ];
  }

  /// 插入数据
  void insertRandomData(int length) {
    for (int i = 0; i < length; i++) {
      db.execute("INSERT INTO $mainTable VALUES(?, ?, ?, ?);",
          [null, ..._buildData(i)]);
    }
  }

  /// 查询主表中所有数据
  List<MainTableRow> selectAll() {
    final resultSet = db.select("SELECT * FROM $mainTable");
    return _toMainTableRows(resultSet);
  }

  /// 查询主表数据数量
  int selectCount() =>
      db.select("SELECT COUNT(*) as c FROM $mainTable").first['c'];

  /// 通过指定分词器 [tokenizer] 搜索
  List<MainTableRow> search(String value, String tokenizer) {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = db.select(
        "SELECT "
        "rowid AS $id, "
        "simple_highlight($fts5Table, 0, $wrapperSql) AS $title, "
        "simple_highlight($fts5Table, 1, $wrapperSql) AS $content, "
        "$insertDate "
        "FROM $fts5Table "
        "WHERE $fts5Table MATCH ${tokenizer}_query(?);",
        [value]);
    return _toMainTableRows(resultSet);
  }

  /// 修改所有数据，测试触发器
  void updateAll() {
    final mainTableRowList = selectAll();
    for (int i = 0; i < mainTableRowList.length; i++) {
      final mainTableRow = mainTableRowList[i];
      db.execute(
          "UPDATE $mainTable SET $title = ?, $content = ?, $insertDate = ? WHERE $id = ?;",
          [..._buildData(i), mainTableRow.id]);
    }
  }
}
