import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../utils/random_words.dart';
import 'main_table_row.dart';

enum Tokenizer {
  jieba,
  simple;
}

abstract class IMainTableDao<T> {
  final T db;

  IMainTableDao(this.db);

  /// 初始化 SQLite FTS5 虚表，官方说明：https://sqlite.org/fts5.html
  Future<void> initFts5();

  /// 插入 [length] 行随机中文词组数据
  Future<void> insertRandomData(int length);

  /// 查询主表中所有数据
  Future<List<MainTableRow>> selectAll();

  /// 查询主表数据数量
  Future<int> selectCount();

  /// 根据 [value] 和 指定分词器 [tokenizer] 搜索， [tokenizer] 取值：[Tokenizer.jieba], [Tokenizer.simple]
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer);

  /// 修改所有数据，测试触发器
  Future<void> updateAll();

  /// 构造随机中文词组数据
  @protected
  MainTableRow buildRow(int index) {
    return MainTableRow(
      id: 0,
      title: randomWords(minLength: 3, maxLength: 4),
      content: randomWords(minLength: 6, maxLength: 16),
      insertDate: DateTime.utc(2000, 1, 1)
          .add(Duration(days: index, minutes: Random().nextInt(61))),
    );
  }
}
