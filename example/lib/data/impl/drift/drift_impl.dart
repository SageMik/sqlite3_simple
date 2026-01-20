import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';
import 'package:sqlite3_simple_example/utils/zero_width.dart';

import '../../../data/main_table_dao.dart';
import '../../../data/main_table_row.dart';
import '../../db_manager.dart';
import 'custom_expression.dart';
import 'database.dart';

class DriftDbManager extends IDbManager<DriftDao> {
  @override
  late final DriftDao dao;

  @override
  Future<void> init() async {
    sqlite3.loadSimpleExtension();

    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "cpp_jieba");
    final jiebaDictSql =
        await sqlite3.saveJiebaDict(jiebaDictPath, overwriteWhenExist: true);
    if (kDebugMode) print("用于设置结巴分词字典路径：$jiebaDictSql");

    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    dao = DriftDao(db);

    await db.customStatement(jiebaDictSql);
    final init = await db
        .customSelect("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')")
        .getSingle();
    if (kDebugMode) print(init.data);
  }

  @override
  Future<void> dispose() => dao.db.close();
}

class DriftDao extends IMainTableDao<AppDatabase> {
  DriftDao(super.db);

  $MainTable get mainTable => db.main;

  T1 get fts5Table => db.t1;

  /// 见 [AppDatabase.buildFts5Triggers]
  @override
  @Deprecated("不需要手动调用")
  Future<void> initFts5() async {}

  @override
  Future<void> insertRandomData(int length) {
    return db.batch((b) {
      b.insertAll(mainTable,
          Iterable.generate(length, (i) => buildRow(i).toCompanion()));
    });
  }

  SimpleHighlight<T1, T1Data> _simpleHighlight(int columnIndex) =>
      SimpleHighlight(
        table: fts5Table,
        columnIndex: columnIndex,
        start: ZeroWidth.start,
        end: ZeroWidth.end,
      );

  late final idExpr = fts5Table.fts5RowId;
  late final titleExpr = _simpleHighlight(0);
  late final contentExpr = _simpleHighlight(1);
  late final insertDateExpr = CustomExpression<DateTime>(mainTable.insertDate.name);
  late final List<Expression> searchExprList = [
    idExpr,
    titleExpr,
    contentExpr,
    insertDateExpr
  ];

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    final query = fts5Table.selectOnly()
      ..addColumns(searchExprList)
      ..where(
        fts5Table.match(
          switch (tokenizer) {
            Tokenizer.simple => SimpleQuery(value),
            Tokenizer.jieba => JiebaQuery(value)
          },
        ),
      );
    final result = await query.get();
    return result
        .map((it) => MainTableRow(
              id: it.read(idExpr)!,
              title: it.read(titleExpr)!,
              content: it.read(contentExpr)!,
              insertDate: it.read(insertDateExpr)!,
            ))
        .toList();
  }

  @override
  Future<List<MainTableRow>> selectAll() async {
    final items = await mainTable.select().get();
    return items
        .map((it) => MainTableRow(
              id: it.id,
              title: it.title,
              content: it.content,
              insertDate: it.insertDate,
            ))
        .toList();
  }

  @override
  Future<int> selectCount() async {
    final countExpr = mainTable.id.count();
    final query = mainTable.selectOnly()..addColumns([countExpr]);
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  @override
  Future<void> updateAll() async {
    final mainTableRowList = await selectAll();
    db.batch((b) {
      for (int i = 0; i < mainTableRowList.length; i++) {
        b.update(
          mainTable,
          buildRow(i).toCompanion(),
          where: (t) => t.id.equals(mainTableRowList[i].id),
        );
      }
    });
  }
}

extension _MainTableRowDrift on MainTableRow {
  MainCompanion toCompanion() {
    return MainCompanion(
      title: Value(title),
      content: Value(content),
      insertDate: Value(insertDate),
    );
  }
}
