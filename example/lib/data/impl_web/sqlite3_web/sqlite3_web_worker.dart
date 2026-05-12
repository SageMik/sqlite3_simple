import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:sqlite3_web/sqlite3_web.dart';
import 'package:web/web.dart';

import '../../pinyin_dict_kind.dart';
import '../fetch.dart';

/// 调整代码后，在 `example` 目录下执行如下命令重新生成：
/// ```
/// dart compile js lib\data\impl_web\sqlite3_web\sqlite3_web_worker.dart -o web\sqlite3_web_worker.dart.js
/// ```
/// 建议最终发布时使用 `-O4` 编译优化等级。
void main() {
  WebSqlite.workerEntrypoint(controller: Sqlite3WebDbController());
}

final class Sqlite3WebDbController extends DatabaseController {
  final DefaultSimpleWasmModuleLoader _loader = DefaultSimpleWasmModuleLoader();

  @override
  Future<WasmSqlite3> loadWasmModule(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    return WasmSqlite3.loadFromUrl(uri, headers: headers, loader: _loader);
  }

  @override
  Future<WorkerDatabase> openDatabase(
    WasmSqlite3 sqlite3,
    String path,
    String vfs,
    JSAny? additionalData,
  ) async {
    return Sqlite3WebDb(sqlite3.open(path, vfs: vfs), _loader);
  }

  @override
  Future<JSAny?> handleCustomRequest(
    ClientConnection connection,
    CustomClientRequest request,
  ) async => null;
}

final class Sqlite3WebDb extends WorkerDatabase {
  @override
  final CommonDatabase database;

  final DefaultSimpleWasmModuleLoader _loader;

  Sqlite3WebDb(this.database, this._loader);

  @override
  Future<JSAny?> handleCustomRequest(
    ClientConnection connection,
    CustomClientDatabaseRequest request,
  ) async {
    try {
      final requestJO = request.request as JSObject;
      final type = (requestJO['type'] as JSString).toDart;
      switch(type) {
        case 'updateJiebaDict':
          // 将内置的结巴分词文件传递给 Wasm 模块以供运行时读取，不需要结巴分词直接 `return null` 即可
          // 自定义消息 { 'type': 'updateJiebaDict', 'path2url': 虚拟路径 → 文件内容 }
          final path2url = (requestJO['path2url'].dartify() as Map).cast<String, String>();
          final jiebaDictFiles = {
            for (final e in path2url.entries)
              e.key: await fetchFromBase(e.value),
          };
          _loader.updateFiles((it) => it..addAll(jiebaDictFiles)); // 更新结巴分词文件，其他已有文件继续保留
          break;
        case 'savePinyinDict':
          final path2url = (requestJO['path2url'].dartify() as Map).cast<String, String>();
          final path2asset = Map.fromEntries(
              await Future.wait(
                  path2url.entries
                      .map((e) async => MapEntry(e.key, await fetchFromBase(e.value)))
              )
          );
          _loader.updateFiles((it) => it..addAll(path2asset));
          break;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
