// ignore_for_file: constant_identifier_names

import '../db_manager.dart';
import 'drift/drift_impl.dart';
import 'sqflite_common_ffi/sqflite_common_ffi_impl.dart';
import 'sqlite3/sqlite3_impl.dart';

enum DbManagerKind {
  sqlite3,
  sqflite_common_ffi,
  drift,
}

DbManager createDbManager(DbManagerKind kind) {
  return switch (kind) {
    DbManagerKind.sqlite3 => Sqlite3DbManager(),
    DbManagerKind.sqflite_common_ffi => SqfliteCommonFfiDbManager(),
    DbManagerKind.drift => DriftDbManager(),
  };
}
