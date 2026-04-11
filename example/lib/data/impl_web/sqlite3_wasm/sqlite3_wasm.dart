// ignore_for_file: avoid_print

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/jieba_dict.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:squadron/squadron.dart';
import 'package:web/web.dart' hide Worker;

import '../../impl/sqlite3/sqlite3_dao.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../fetch.dart';
import 'main_table_row_marshaler.dart';
import 'sqlite3_wasm.activator.g.dart';

part 'sqlite3_wasm.worker.g.dart';

///
///  调整代码后，在 `example` 目录下执行如下命令重新生成：
///  ```shell
///  dart run build_runner build -d
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
  Future<void> initDatabase(
    Map<JiebaDictType, String> jiebaDictPath2Url,
  ) async {
    final stopWatch = Stopwatch()..start();

    const jiebaDictDir = "";
    _wasmSqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
      loader: await DefaultSimpleWasmModuleLoader.create(
        files: {
          for (final e in jiebaDictPath2Url.entries)
            "$jiebaDictDir/${e.key.filename}": await _fetch(e.value),
        },
      ),
    );
    _wasmSqlite3.registerVirtualFileSystem(
      _inMemoryFileSystem,
      makeDefault: true,
    );

    final db = _wasmSqlite3.open('/database');
    _dao = Sqlite3Dao(db);

    db.select("SELECT jieba_dict(?)", [jiebaDictDir]);
    final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
    print(init);

    stopWatch.stop();
    print("数据库初始化耗时：${(stopWatch.elapsedMilliseconds)}ms");

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
