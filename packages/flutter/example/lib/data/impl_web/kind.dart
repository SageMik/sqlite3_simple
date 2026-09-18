// ignore_for_file: constant_identifier_names

import '../db_manager.dart';
import 'sqlite3_wasm/sqlite3_wasm_impl.dart';
import 'sqlite3_web/sqlite3_web_impl.dart';

enum DbManagerKind {
  sqlite3_web,
  sqlite3_wasm,
}

DbManager createDbManager(DbManagerKind kind) {
  return switch (kind) {
    DbManagerKind.sqlite3_web => Sqlite3WebDbManager(),
    DbManagerKind.sqlite3_wasm => Sqlite3WasmDbManager(),
  };
}
