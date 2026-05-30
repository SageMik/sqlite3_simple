// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/jieba_dict_type.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:squadron/squadron.dart';

import '../../db_manager.dart';
import '../../impl/sqlite3/sqlite3_dao.dart';
import '../../main_table_dao.dart';
import '../../main_table_row.dart';
import '../../pinyin_dict_kind.dart';
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
class Sqlite3Wasm extends IDbManager<CommonDatabase> with Sqlite3Fts5Creator implements MainTableDao {
  late final Sqlite3Dao _dao;
  late final DefaultSimpleWasmModuleLoader _loader;

  late WasmSqlite3 _wasmSqlite3;
  final _inMemoryFileSystem = InMemoryFileSystem();

  /// 使用 [initWithJiebaDict] 初始化数据库
  @override
  @Deprecated("")
  Future<void> init() => initWithJiebaDict(const {});

  @SquadronMethod()
  Future<void> initWithJiebaDict(
    Map<JiebaDictType, String> jiebaDictPath2Url,
  ) async {
    final stopWatch = Stopwatch()..start();

    const jiebaDictDir = "sqlite3_simple_example/jieba_dict";
    _wasmSqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
      loader: _loader = DefaultSimpleWasmModuleLoader(
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

  late Map<PinyinDictKind, String> _kind2url;

  /// 通过在主线程调用 [assetManager.getAssetUrl] 获取拼音文件的 URL，并传递到 Web Worker 中。
  /// 在 Web 上资源文件 URL 会加上 `assets` 前缀，例如 `assets/assets/pinyin_dict/simple_default.txt`，所以其实直接加上 `assets/` 也是可以的。
  @SquadronMethod()
  Future<void> updatePinyinKind2Url(Map<PinyinDictKind, String> kind2url) async {
    _kind2url = kind2url;
  }

  @override
  @SquadronMethod()
  Future<Map<PinyinDictKind, String>> savePinyinDict() async {
    const pinyinDictDir = "sqlite3_simple_example/pinyin_dict";
    final Map<PinyinDictKind, String> kind2path = {};
    final Map<String, Uint8List> path2asset = {};
    final existingFiles = _loader.files;
    for (final MapEntry(key: kind, value: url) in _kind2url.entries) {
      if(kind.isBundled) {
        kind2path[kind] = '';
      } else {
        final path = "$pinyinDictDir/${kind.assetName!}";
        if (!existingFiles.containsKey(path)) {
          kind2path[kind] = path;
          path2asset[path] = await fetchFromBase(url);
        }
      }
    }
    if (path2asset.isNotEmpty) {
      _loader.updateFiles((it) => it..addAll(path2asset));
    }
    return kind2path;
  }

  @override
  @SquadronMethod()
  Future<void> close() async {
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
  Future<void> updatePinyinDict(String newPath) => _dao.updatePinyinDict(newPath);

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
