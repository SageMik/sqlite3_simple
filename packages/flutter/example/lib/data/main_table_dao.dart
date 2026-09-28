import 'dart:math';

import '../utils/random_words.dart';
import 'main_table_row.dart';

enum Tokenizer {
  jieba("jieba_query"),
  simple("simple_query");

  /// FTS5 `MATCH` 时使用的查询函数名
  final String queryFunctionName;

  const Tokenizer(this.queryFunctionName);
}

abstract interface class MainTableDao {
  /// 插入 [length] 行随机中文词组数据
  Future<void> insertRandomData(int length);

  /// 查询主表中所有数据
  Future<List<MainTableRow>> selectAll();

  /// 查询主表数据数量
  Future<int> selectCount();

  /// 根据 [value] 和 指定分词器 [tokenizer] 搜索， [tokenizer] 取值：[Tokenizer.jieba], [Tokenizer.simple]
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer);

  /// 更换拼音文件为 [newPath] 路径所指向的文件，并重建 FTS5 的索引。[newPath] 为空时使用内置拼音文件
  Future<void> updatePinyinDict(String newPath);

  /// 增删改数据，测试触发器
  Future<void> updateAll();
}

abstract class MainTableDaoBase<T> implements MainTableDao {
  final T db;

  MainTableDaoBase(this.db);
}

/// 构造随机中文词组数据
MainTableRow createRandomRow() {
  final r = Random();
  final now = DateTime.now();
  final yearStart = DateTime(now.year);
  return MainTableRow(
    id: 0,
    title: randomWords(minLength: 3, maxLength: 4),
    content: randomWords(minLength: 6, maxLength: 16),
    insertDate: yearStart.add(
      Duration(seconds: r.nextInt(now.difference(yearStart).inSeconds + 1)),
    ),
  );
}

int shuffledRowCount() => 20 + Random().nextInt(21);