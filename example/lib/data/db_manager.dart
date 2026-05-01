import 'package:meta/meta.dart';

import 'db_manager_kind.dart';
import 'main_table_dao.dart';

abstract class DbManager<TDao extends MainTableDao> {
  abstract final TDao dao;

  /// 初始化数据库
  Future<void> init();

  /// 关闭数据库
  Future<void> close();

  static DbManager create(DbManagerKind kind) {
    return createDbManager(kind);
  }
}

abstract interface class Fts5Creator<TDb> {
  /// 创建主表、FTS5 虚表及其触发器，官方说明：https://sqlite.org/fts5.html
  @protected
  Future<void> createMainAndFts5(TDb db);
}