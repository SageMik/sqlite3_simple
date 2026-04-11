import 'db_manager_kind.dart';
import 'main_table_dao.dart';

abstract interface class DbManager<TDao extends MainTableDao> {
  abstract final TDao dao;

  /// 初始化 Simple 分词器，并将结巴分词字典文件保存到本地
  Future<void> init();

  /// 关闭数据库
  Future<void> close();

  static DbManager create(DbManagerKind kind) {
    return createDbManager(kind);
  }
}
