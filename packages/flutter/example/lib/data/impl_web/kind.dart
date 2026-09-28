// ignore_for_file: constant_identifier_names

import '../db_manager.dart';
import 'sqlite3_wasm/sqlite3_wasm_impl.dart';
import 'sqlite3_web/sqlite3_web_impl.dart';

enum DbManagerKind {
  sqlite3_web(Sqlite3WebDbManager.new),
  sqlite3_wasm(Sqlite3WasmDbManager.new);

  final DbManager Function() create;

  const DbManagerKind(this.create);
}
