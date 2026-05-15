# sqlite3_simple - Web 

在线演示：[Simple 分词器 示例](https://sagemik.github.io/sqlite3_simple) 。代码请参考 [`example/lib/data/impl_web`](../example/lib/data/impl_web) 。

## 快速开始

### 1. 添加 `sqlite3` 、`sqlite3_web` 依赖

在 Web 上使用 Simple 分词器，**需要 [`sqlite3: ^3.3.0`](https://github.com/simolus3/sqlite3.dart/tree/sqlite3-3.3.0/sqlite3) 或以上版本（原因见<a href="#wasm-module-loader-requirement">此处</a>）**，[`sqlite3_web`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_web) 理论上不受限制但还是建议使用最新版本：

```yaml
dependencies:
  sqlite3: ^3.3.0
  sqlite3_web: ^0.7.0
```

<details>
<summary><b>&nbsp;📝 为什么需要 <code>sqlite3_web</code> ？</b></summary>

<br />

SQLite 是基于文件的嵌入式数据库，但在 Web 环境中无法直接访问文件系统，因此需要 `sqlite3_web` 提供的基于 [Web Worker](https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers)（属于后台线程，支持[文件系统 API](https://developer.mozilla.org/zh-CN/docs/Web/API/File_System_API)）管理数据库的**异步 API** 。

`sqlite3` 提供的同步 API 不满足 Web Worker 的异步通信需求，已有项目增加 Web 支持，可能涉及大量同步异步代码的调整。一种可以复用同步 API 的方法是通过 [`squadron`](https://github.com/d-markey/squadron) 或其他框架自行管理 Web Worker，例如示例中的 [`impl_web/sqlite3_wasm`](../example/lib/data/impl_web/sqlite3_wasm) 就复用了 `Sqlite3Dao` 。不过此类通用框架首屏加载速度会稍慢，需要根据实际项目需求选择。

</details>

### 2. 添加本库，下载 `sqlite3.wasm`

```shell
flutter pub add sqlite3_simple
```

随后到本仓库的 [Release](https://github.com/SageMik/sqlite3_simple/releases) 中下载 [`sqlite3.wasm`](https://github.com/SageMik/sqlite3_simple/releases/latest/download/sqlite3.wasm) 或 [`sqlite3mc.wasm`](https://github.com/SageMik/sqlite3_simple/releases/latest/download/sqlite3mc.wasm) (内置 [SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) 扩展) ，置于项目的 `web` 或者资源等可访问目录下，以便后续加载使用。

> [!TIP]
> `sqlite3` 使用 [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 通过 [sqlite3_wasm_build](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_wasm_build) 将 SQLite 编译为 WebAssembly 文件以在 Web 上使用。
>
> 由于目前 [SQLite 不支持在 Web 上加载运行时扩展](https://sqlite.org/forum/forumpost/9273e6c9159502a1842287f4c20aec964a81c01057bdecf0e8137dd8b5c44dd1) ，本项目基于 [sqlite3_wasm_build](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_wasm_build) 编译了内置 Simple 分词器的 `sqlite3.wasm` 和 `sqlite3mc.wasm` ，编译代码由 [simple-native 分支](https://github.com/SageMik/sqlite3_simple/tree/simple-native) 维护，若需自行编译请参考 [`src/web`](https://github.com/SageMik/sqlite3_simple/tree/simple-native/src/web) 。

### 3. 编写在 Web Worker 中的数据库管理逻辑

根据 [`sqlite3_web` 的说明](https://github.com/simolus3/sqlite3.dart/tree/sqlite3-3.3.0/sqlite3_web#getting-started) 进行编写，例如 [`impl_web/sqlite3_web/sqlite3_web_worker.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_worker.dart) 。

#### Web Worker 启动入口

```
void main() {
  WebSqlite.workerEntrypoint(controller: Sqlite3WebDbController());
}
```

#### Wasm 模块和数据库加载

```dart
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
```

其中 `DefaultSimpleWasmModuleLoader` 是支撑 Simple 扩展在 Web 上正常使用的核心组件，主要职责如下：

1. 在 [`WebAssembly.instantiateStreaming(source, importObject)`](https://developer.mozilla.org/zh-CN/docs/WebAssembly/Reference/JavaScript_interface/instantiateStreaming_static) 模块实例化时，将所需的宿主侧能力通过 `importObject` 提供给模块用于运行期调用。
2. 在模块实例化后，将模块导出的线性内存交由宿主侧，以供文件读写。

<a id="wasm-module-loader-requirement"></a>

> [!TIP]
>
> 用于自定义 Wasm 模块加载的 `WasmModuleLoader` 在 `sqlite3: 3.3.0` 才[被引入](https://github.com/simolus3/sqlite3.dart/issues/359)，因此 `3.3.0` 是在 Web 上使用 Simple 的最低版本要求。

<details>
<summary><b> 📝 <code>DefaultSimpleWasmModuleLoader</code></b> 实现</summary>

<br />

由于 Simple 涉及文件读写（`fopen`、`read`、`write` ...）等在 Web 环境中不可用的系统调用，WASI 会将其统一为抽象为 `wasi_snapshot_preview1` 模块的 API（`path_open`、`fd_read`、`fd_write` 等）并要求宿主侧提供实现。`DefaultSimpleWasmModuleLoader` 通过 [`wasd`](https://github.com/medz/wasd) 实现了这些 API，为 Simple 提供了 Web 环境支持。

如果默认实现不满足要求，可以自行继承 [`SimpleBridgeCallbacks`](../lib/src/web/bridge_callbacks.dart) 和 `WasmModuleLoader` 进行扩展。

</details>

#### 通过主线程传递自定义消息，加载结巴分词字典文件
本库内置了结巴分词所需的字典文件，可通过 [`JiebaDictAssets.loadPaths()`](../lib/src/io/jieba_dict_assets.dart) 获取其路径。**由于涉及对 Flutter 资源的访问，该方法需要在主线程中调用。** 因此，使用结巴分词，需要自定义消息将路径传递到 Worker 中，然后使用 JS 的 `fetch` 函数进行加载：

```dart
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
    // 将内置的结巴分词文件传递给 Wasm 模块以供运行时读取，不需要结巴分词直接 `return null` 即可
    try {
      final requestJO = request.request as JSObject;
      final type = (requestJO['type'] as JSString).toDart;
      switch(type) {
        case 'updateJiebaDict': // 自定义消息 { 'type': 'updateJiebaDict', 'path2url': 虚拟路径 → 文件内容 }
          final path2url = (requestJO['path2url'].dartify() as Map).cast<String, String>();
          final jiebaDictFiles = {
            for (final e in path2url.entries)
              e.key: await fetchFromBase(e.value),
          };
          _loader.updateFiles((it) => it..addAll(jiebaDictFiles)); // 更新结巴分词文件，其他已有文件继续保留
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
```

`fetchFromBase` 来自 [`impl_web/fetch.dart`](../example/lib/data/impl_web/fetch.dart)：

```dart
@JS()
external JSPromise<Response> fetch(URL resource, [RequestInit? options]);

/// 用于在 Web Worker 中读取结巴分词字典文件
Future<Uint8List> fetchFromBase(String url) async {
  final response = await fetch(URL(url, Uri.base.toString())).toDart;
  return (await response.bytes().toDart).toDart;
}
```

`_loader.updateFiles` 用于更新提供给 Wasm 模块读取的文件。在 `DefaultSimpleWasmModuleLoader` 的实现中，文件读写通过内存中的「虚拟路径 → 文件内容 `Uint8List`」映射关系来模拟实现。

#### 编译为 JavaScript

上述代码通过 `dart compile js` 编译为 JavaScript 后才能使用，注意**不能间接或直接包含以 `package:flutter` 开头的依赖。**

参考示例代码在 `example` 目录下执行如下命令，即可编译成 `sqlite3_web_worker.dart.js` 供后续使用：

```dart
dart compile js lib\data\impl_web\sqlite3_web\sqlite3_web_worker.dart -o web\sqlite3_web_worker.dart.js -O4
```

调试阶段建议省略 `-O4` 优化选项，以保留更清晰的错误信息和调用栈，方便问题定位。

### 4. 打开数据库

根据 [`sqlite3_web` 的说明](https://github.com/simolus3/sqlite3.dart/tree/sqlite3-3.3.0/sqlite3_web#getting-started)，以及前面下载的 `sqlite3.wasm` 和编译的 `sqlite3_web_worker.dart.js` 的位置，打开数据库：

```dart
final webSqlite3 = WebSqlite.open(
  workers: WorkerConnector.defaultWorkers(
    Uri.parse('sqlite3_web_worker.dart.js'),
  ),
  wasmModule: Uri.parse('sqlite3.wasm'),
);
final db = await webSqlite3.connectToRecommended('database');
```

如需启用结巴分词，根据前面自定义的消息，调用 `db.customRequest()` 进行传递：

```dart
final Map<JiebaDictType, String> jiebaDictPaths = await JiebaDictAssets.loadPaths();
const jiebaDictDir = '.dict';
await db.customRequest(
  {
    'type': 'updateJiebaDict',
    'path2url': {
      for (final e in jiebaDictPaths.entries)
        '$jiebaDictDir/${e.key.filename}': e.value,
    }
  }.jsify(),
);
await db.execute("SELECT jieba_dict(?)", parameters: [jiebaDictDir]);
final init = await db.select( // 推荐在正式查询前执行一次查询，提前加载
  "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
);
if (kDebugMode) print(init.result);
```

[`JiebaDictType`](../lib/src/common/jieba_dict_type.dart) 枚举定义了结巴分词所需的所有字典类型，如 `jiebaDict("jieba.dict.utf8")` 等。

### 5. 创建主表、FTS5 虚表和触发器

根据 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 的说明和实际项目需求创表，例如 [`impl_web/sqlite3_web/sqlite3_web_impl.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_impl.dart) ：

```dart
// final fts5Tokenizer = "simple 0";  // 关闭拼音搜索
const fts5Tokenizer = "simple";
const mainTable = "custom";
const id = "id",
    title = "title",
    content = "content",
    insertDate = "insert_date";
const fts5Table = "t1";

@override
@protected
Future<void> createMainAndFts5(Database db) async {
  /// 主表
  await db.execute('''
    CREATE TABLE $mainTable (
      $id INTEGER PRIMARY KEY AUTOINCREMENT, 
      $title TEXT, 
      $content TEXT, 
      $insertDate INTEGER
    );
  ''');

  /// FTS5虚表
  await db.execute('''
    CREATE VIRTUAL TABLE $fts5Table USING fts5(
      $title, $content, $insertDate UNINDEXED, 
      tokenize = '$fts5Tokenizer', 
      content = '$mainTable', 
      content_rowid = '$id'
    );
  ''');

  const newInsert = '''
    INSERT INTO $fts5Table(rowid, $title, $content, $insertDate)
      VALUES (new.$id, new.$title, new.$content, new.$insertDate);
  ''';
  const deleteInsert = '''
    INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate)
      VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
  ''';
  await db.execute('''
    CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
      $newInsert
    END;
  ''');
  await db.execute('''
    CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
      $deleteInsert
    END;
  ''');
  await db.execute('''
    CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
      $deleteInsert
      $newInsert
    END;
  ''');
}
```

### 6. 查询

参阅 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用 `jieba_query`、`simple_query`、`highlight`、  `simple_highlight` 进行查询，例如 [`impl_web/sqlite3_web/sqlite3_web_impl.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_impl.dart) ：

```dart
@override
Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
  const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
  final resultSet = await db.select(
    '''
    SELECT 
      rowid AS $id, 
      simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
      simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
      $insertDate 
    FROM $fts5Table 
    WHERE $fts5Table MATCH ${tokenizer.name}_query(?);
  ''',
    parameters: [value],
  );
  return _toMainTableRows(resultSet.result);
}
```