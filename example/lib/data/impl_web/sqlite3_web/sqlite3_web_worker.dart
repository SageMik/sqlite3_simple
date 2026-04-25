import 'dart:js_interop';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/web.dart';
import 'package:sqlite3_web/sqlite3_web.dart';

import '../fetch.dart';
import 'sqlite3_web_request.dart';

/// 调整代码后，在 `example` 目录下执行如下命令重新生成：
/// ```
/// dart compile js lib\data\impl_web\sqlite3_web\sqlite3_web_worker.dart -o web\sqlite3_web_worker.dart.js -O4
/// ```
/// 调试可以不加编译优化等级，最终发布时再使用 `-O4` 。
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
      switch (Sqlite3WebRequest.fromJs(request.request as JSObject)) {
        case UpdateJiebaDictRequest r:
          await _loader.updateFiles(
            files: {
              for (final e in r.path2url.entries)
                e.key: await fetchFromBase(e.value),
            },
          );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
