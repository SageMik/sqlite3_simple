import 'package:sqlite3_simple_example/data/main_table_dao.dart';

abstract class IDbManager<TDao extends IMainTableDao> {
  abstract final TDao dao;

  /// 初始化 Simple 分词器，并将结巴分词字典文件保存到本地
  Future<void> init();

  /// 关闭数据库
  Future<void> dispose();
}