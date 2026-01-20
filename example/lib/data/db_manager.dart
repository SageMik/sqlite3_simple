import 'package:sqlite3_simple_example/data/main_table_dao.dart';

import 'impl/drift/drift_impl.dart';
import 'impl/sqflite_common_ffi_impl.dart';
import 'impl/sqlite3_impl.dart';

abstract class IDbManager<TDao extends IMainTableDao> {
  abstract final TDao dao;

  /// 初始化 Simple 分词器，并将结巴分词字典文件保存到本地
  Future<void> init();

  /// 关闭数据库
  Future<void> dispose();
}

enum DbManagerImpl {
  sqlite3,
  sqfliteCommonFfi,
  drift;

  IDbManager create() {
    return switch (this) {
      DbManagerImpl.sqlite3 => Sqlite3DbManager(),
      DbManagerImpl.sqfliteCommonFfi => SqfliteCommonFfiDbManager(),
      DbManagerImpl.drift => DriftDbManager(),
    };
  }
}
