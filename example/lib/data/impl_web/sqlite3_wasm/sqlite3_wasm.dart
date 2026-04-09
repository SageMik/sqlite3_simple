import 'dart:js_interop';
import 'dart:typed_data';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:squadron/squadron.dart';
import 'package:web/web.dart' hide Worker;

import '../../impl/sqlite3/sqlite3_dao.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import 'main_table_row_marshaler.dart';
import 'sqlite3_wasm.activator.g.dart';

part 'sqlite3_wasm.worker.g.dart';

///  ```shell
///  dart run build_runner build -d
///  ```
///
///  ```shell
///  dart compile js .\lib\data\impl_web\sqlite3_wasm\sqlite3_wasm.web.g.dart -o web\sqlite3_wasm.web.g.dart.js
///  ```
@SquadronService(baseUrl: "~", targetPlatform: TargetPlatform.js)
base class Sqlite3Wasm implements MainTableDao {
  late final Sqlite3Dao _dao;

  late WasmSqlite3 _wasmSqlite3;
  final _inMemoryFileSystem = InMemoryFileSystem();

  /// 在 Worker 中读取结巴分词字典文件，避免阻塞主线程导致卡顿。
  static Future<Uint8List> _fetch(String url) async {
    final response = await fetch(URL(url, Uri.base.toString())).toDart;
    return (await response.bytes().toDart).toDart;
  }

  @SquadronMethod()
  Future<void> initDatabase(Map<String, String> jiebaDictPath2Url) async {
    _wasmSqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.debug.wasm'),
      loader: await DefaultSimpleWasmModuleLoader.create(
        files: {
          for (final e in jiebaDictPath2Url.entries)
            e.key: await _fetch(e.value),
        },
      ),
    );
    _wasmSqlite3.registerVirtualFileSystem(
      _inMemoryFileSystem,
      makeDefault: true,
    );

    final db = _wasmSqlite3.open('/database');
    _dao = Sqlite3Dao(db);

    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    // ignore: avoid_print
    print(init);

    await _dao.initFts5();
  }

  @SquadronMethod()
  Future<void> closeDatabase() async {
    _wasmSqlite3.unregisterVirtualFileSystem(_inMemoryFileSystem);
  }

  @override
  @SquadronMethod()
  Future<void> initFts5() => _dao.initFts5();

  @override
  @SquadronMethod()
  Future<void> insertRandomData(int length) => _dao.insertRandomData(length);

  @override
  @SquadronMethod()
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      _dao.search(value, tokenizer);

  @override
  @SquadronMethod()
  Future<List<MainTableRow>> selectAll() => _dao.selectAll();

  @override
  @SquadronMethod()
  Future<int> selectCount() => _dao.selectCount();

  @override
  @SquadronMethod()
  Future<void> updateAll() => _dao.updateAll();
}

@JS()
external JSPromise<Response> fetch(URL resource, [RequestInit? options]);
