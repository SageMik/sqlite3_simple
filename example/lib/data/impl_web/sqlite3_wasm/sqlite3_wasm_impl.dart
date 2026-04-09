import 'package:flutter/foundation.dart';
import 'package:sqlite3_simple/assets.dart';
import 'package:squadron/squadron.dart';
import 'package:web/web.dart';

import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import 'sqlite3_wasm.dart';

class Sqlite3WasmDbManager implements DbManager<Sqlite3WasmDao> {
  /// 对 [Sqlite3Wasm] 的 Web Worker 封装
  final _pool = Sqlite3WasmWorkerPool(
    concurrencySettings: const ConcurrencySettings(
      minWorkers: 1,
      maxWorkers: 4,
      maxParallel: 1,
    ),
  );

  @override
  late final Sqlite3WasmDao dao = Sqlite3WasmDao(_pool);

  @override
  Future<void> init() async {
    final jiebaAssetPaths = await JiebaDictAssets.loadPaths();
    final jiebaDictPath2Url = jiebaAssetPaths.map((k, v) =>
        MapEntry("./dict/${k.filename}", "assets/$v"));
    if (kDebugMode) print(jiebaDictPath2Url);
    await _pool.initDatabase(jiebaDictPath2Url);
  }

  @override
  Future<void> close() async {
    await _pool.closeDatabase();
    _pool.stop();
  }
}

class Sqlite3WasmDao implements MainTableDao {
  final Sqlite3WasmWorkerPool _pool;

  Sqlite3WasmDao(this._pool);

  @override
  Future<void> initFts5() => _pool.initFts5();

  @override
  Future<void> insertRandomData(int length) => _pool.insertRandomData(length);

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      _pool.search(value, tokenizer);

  @override
  Future<List<MainTableRow>> selectAll() => _pool.selectAll();

  @override
  Future<int> selectCount() => _pool.selectCount();

  @override
  Future<void> updateAll() => _pool.updateAll();
}
