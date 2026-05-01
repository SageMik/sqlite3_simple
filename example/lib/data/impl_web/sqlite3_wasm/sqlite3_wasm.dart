// ignore_for_file: avoid_print

import 'package:meta/meta.dart';
import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/jieba_dict_type.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:squadron/squadron.dart';

import '../../impl/sqlite3/sqlite3_dao.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../fetch.dart';
import 'main_table_row_marshaler.dart';
import 'sqlite3_wasm.activator.g.dart';

part 'sqlite3_wasm.worker.g.dart';

/// 调整代码后，在 `example` 目录下执行如下命令重新生成：
/// ```shell
/// dart run build_runner build -d
/// dart compile js lib\data\impl_web\sqlite3_wasm\sqlite3_wasm.web.g.dart -o web\sqlite3_wasm.web.g.dart.js
/// ```
/// 建议最终发布时使用 `-O4` 编译优化等级。
@SquadronService(baseUrl: "~", targetPlatform: TargetPlatform.js)
class Sqlite3Wasm with Sqlite3Fts5Creator implements MainTableDao {
  late final Sqlite3Dao _dao;

  late WasmSqlite3 _wasmSqlite3;
  final _inMemoryFileSystem = InMemoryFileSystem();

  @SquadronMethod()
  Future<void> initDatabase(
    Map<JiebaDictType, String> jiebaDictPath2Url,
  ) async {
    final stopWatch = Stopwatch()..start();

    const jiebaDictDir = ".dict";
    _wasmSqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
      loader: DefaultSimpleWasmModuleLoader(
        files: {
          for (final e in jiebaDictPath2Url.entries)
            "$jiebaDictDir/${e.key.filename}": await fetchFromBase(e.value),
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

    final version = db.select("PRAGMA user_version").first['user_version'];
    if (version == 0) {
      await createMainAndFts5(db);
      db.execute("PRAGMA user_version = 1");
    }

    stopWatch.stop();
    print("数据库初始化耗时：${(stopWatch.elapsedMilliseconds)}ms");
  }

  /// 避免 `squadron` 生成报错
  @override
  @protected
  Future<void> createMainAndFts5(CommonDatabase db) {
    return super.createMainAndFts5(db);
  }

  @SquadronMethod()
  Future<void> closeDatabase() async {
    _dao.db.close();
    _wasmSqlite3.unregisterVirtualFileSystem(_inMemoryFileSystem);
  }

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
