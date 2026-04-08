import 'dart:typed_data';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:squadron/squadron.dart';

import '../../impl/sqlite3/sqlite3_dao.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import 'sqlite3_wasm.activator.g.dart';

part 'sqlite3_wasm.worker.g.dart';

@SquadronService(baseUrl: "~", targetPlatform: TargetPlatform.js)
base class Sqlite3Wasm implements MainTableDao<CommonDatabase> {
  late final Sqlite3Dao dao;

  @override
  CommonDatabase get db => dao.db;

  late WasmSqlite3 _wasmSqlite3;
  final _inMemoryFileSystem = InMemoryFileSystem();

  @SquadronMethod()
  Future<void> initDatabase(Map<String, Uint8List> files) async {
    _wasmSqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.debug.wasm'),
      loader: await DefaultSimpleWasmModuleLoader.create(files: files),
    );
    _wasmSqlite3.registerVirtualFileSystem(
      _inMemoryFileSystem,
      makeDefault: true,
    );

    final db = _wasmSqlite3.open('/database');
    dao = Sqlite3Dao(db);

    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    // ignore: avoid_print
    print(init);

    await dao.initFts5();
  }

  @SquadronMethod()
  Future<void> closeDatabase() async {
    _wasmSqlite3.unregisterVirtualFileSystem(_inMemoryFileSystem);
  }

  @override
  @SquadronMethod()
  Future<void> initFts5() => dao.initFts5();

  @override
  @SquadronMethod()
  Future<void> insertRandomData(int length) => dao.insertRandomData(length);

  @override
  @SquadronMethod()
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      dao.search(value, tokenizer);

  @override
  @SquadronMethod()
  Future<List<MainTableRow>> selectAll() => dao.selectAll();

  @override
  @SquadronMethod()
  Future<int> selectCount() => dao.selectCount();

  @override
  @SquadronMethod()
  Future<void> updateAll() => dao.updateAll();
}
