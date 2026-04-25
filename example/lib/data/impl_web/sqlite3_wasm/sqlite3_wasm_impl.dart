import 'package:sqlite3_simple/assets.dart';
import 'package:squadron/squadron.dart';

import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import 'sqlite3_wasm.dart';

final class Sqlite3WasmDbManager extends DbManager<Sqlite3WasmDao> {
  /// 将结巴分词字典文件的加载和数据库操作，放到由 [Squadron](https://github.com/d-markey/squadron) 管理的 Web Worker，避免阻塞主线程导致 UI 卡顿，具体见 [Sqlite3Wasm] 。
  final _pool = Sqlite3WasmWorkerPool(
    concurrencySettings: const ConcurrencySettings(
      minWorkers: 1,
      maxWorkers: 4,
      maxParallel: 1,
    ),
  );

  @override
  late final Sqlite3WasmDao dao = Sqlite3WasmDao(_pool);

  /// 在主线程获取结巴分词字典文件的 URL，并传给 Web Worker 交由 [Sqlite3Wasm.initDatabase] 处理
  @override
  Future<void> init() async {
    await _pool.initDatabase(await JiebaDictAssets.loadPaths());
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
