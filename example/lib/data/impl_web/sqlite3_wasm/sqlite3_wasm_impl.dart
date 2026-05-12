import 'package:sqlite3/common.dart';
import 'package:sqlite3_simple/assets.dart';
import 'package:squadron/squadron.dart';

import '../../db_manager.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../../pinyin_dict_kind.dart';
import 'sqlite3_wasm.dart';

final class Sqlite3WasmDbManager extends DbManager<Sqlite3WasmDao, CommonDatabase> {
  /// 将结巴分词字典文件的加载和数据库操作，放到由 [Squadron](https://github.com/d-markey/squadron) 管理的 Web Worker，具体见 [Sqlite3Wasm] 。
  final _pool = Sqlite3WasmWorkerPool(
    concurrencySettings: const ConcurrencySettings(
      minWorkers: 1,
      maxWorkers: 4,
      maxParallel: 1,
    ),
  );

  @override
  late final Sqlite3WasmDao dao = Sqlite3WasmDao(_pool);

  /// 在主线程获取结巴分词字典文件的 URL，并传给 Web Worker 交由 [Sqlite3Wasm.initWithJiebaDict] 处理
  @override
  Future<void> init() async {
    await _pool.initWithJiebaDict(await JiebaDictAssets.loadPaths());
  }

  /// 该函数不会被调用，真正实现在 [Sqlite3Wasm.createMainAndFts5]
  @override
  @Deprecated("")
  Future<void> createMainAndFts5(CommonDatabase db) => _pool.createMainAndFts5(db);

  @override
  Future<Map<PinyinDictKind, String>> savePinyinDict() => _pool.savePinyinDict();

  @override
  Future<void> close() async {
    await _pool.close();
    _pool.stop();
  }
}

class Sqlite3WasmDao implements MainTableDao {
  final Sqlite3WasmWorkerPool _pool;

  Sqlite3WasmDao(this._pool);

  @override
  Future<void> insertRandomData(int length) => _pool.insertRandomData(length);

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      _pool.search(value, tokenizer);

  @override
  Future<void> updatePinyinDict(String newPath) =>
      _pool.updatePinyinDict(newPath);

  @override
  Future<List<MainTableRow>> selectAll() => _pool.selectAll();

  @override
  Future<int> selectCount() => _pool.selectCount();

  @override
  Future<void> updateAll() => _pool.updateAll();
}
