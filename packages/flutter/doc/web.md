# sqlite3_simple - Web

在线演示：[Simple 分词器 示例](https://sagemik.github.io/sqlite3_simple)。代码请参考 [`example/lib/data/impl_web`](../example/lib/data/impl_web) 。

## 快速开始

### 1. 添加 `sqlite3`、`sqlite3_web` 等依赖

在 Web 上使用 Simple 分词器，**需要 [`sqlite3: ^3.3.0`](https://github.com/simolus3/sqlite3.dart/tree/sqlite3-3.3.0/sqlite3) 或以上版本（原因见<a href="#wasm-module-loader-requirement">此处</a>）**，[`sqlite3_web`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_web) 理论上不受限制但还是建议使用最新版本：

```yaml
dependencies:
  sqlite3: ^3.3.0
  sqlite3_web: ^0.7.0
  web: ^1.1.1
```

<details>
<summary><b>&nbsp;📝 为什么需要 <code>sqlite3_web</code> ？</b></summary>

<br />

如 [`sqlite3_web`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_web) 的文档所述，SQLite 作为基于文件的嵌入式数据库，在 Web 上运行会受到 WebAssembly 沙箱、文件系统、各浏览器持久化 API 差异、主线程阻塞等诸多因素的限制，因此最可靠的方式是将 SQLite 实例移入 [Web Worker](https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers) 中运行，由 Worker 侧代码管理数据库，并通过消息通道与主线程异步通信。`sqlite3_web` 正为此提供了对应的异步封装，既可替换 `sqlite3` 中不满足要求的同步 API，又省去了自行实现的繁琐。

已有项目增加 Web 支持，可能涉及大量同步异步代码的调整。一种可以复用同步 API 的方法是通过 [`squadron`](https://github.com/d-markey/squadron) 或其他框架自行管理 Web Worker，例如示例 [`impl_web/sqlite3_wasm`](../example/lib/data/impl_web/sqlite3_wasm) 就复用了基于同步 API 的 `Sqlite3Dao` 。此类通用框架首屏加载速度会稍慢，需根据实际项目需求选择。

</details>

### 2. 添加本库，下载 `sqlite3.wasm`

```shell
# Dart 项目
dart pub add sqlite3_simple_core

# Flutter 项目
flutter pub add sqlite3_simple
```

随后到本仓库的 [Release](https://github.com/SageMik/sqlite3_simple/releases) 中，找到 `simple-native vX.Y.Z` 下载 [`sqlite3.wasm`](https://github.com/SageMik/sqlite3_simple/releases/download/Nv3.0.0/sqlite3.wasm) 或 [`sqlite3mc.wasm`](https://github.com/SageMik/sqlite3_simple/releases/download/Nv3.0.0/sqlite3mc.wasm) (内置 [SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) 扩展) ，置于项目的 `web` 或者资源等可访问目录下，以便后续加载使用。`simple-native` 的版本一般与主库保持一致，但主库升级而原生库未变时不会重复发版，此时取不大于当前主库版本的最近一个即可。

<details>
<summary><b>&nbsp;📝 自行编译 Simple Wasm 模块</b></summary>

<br />

`sqlite3` 使用 [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 通过 [`sqlite3_wasm_build`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_wasm_build) 将 SQLite 编译为 WebAssembly 以在 Web 上使用。由于目前 [SQLite 不支持在 Web 上加载运行时扩展](https://sqlite.org/forum/forumpost/9273e6c9159502a1842287f4c20aec964a81c01057bdecf0e8137dd8b5c44dd1) ，本项目在 [simple-native 分支](https://github.com/SageMik/sqlite3_simple/tree/simple-native) 上编译了「内置 Simple 分词器」的 `sqlite3.wasm` 和 `sqlite3mc.wasm` ，编译代码请参考 [`src/web`](https://github.com/SageMik/sqlite3_simple/tree/simple-native/src/web) 。

</details>

### 3. 编写在 Web Worker 中的数据库管理逻辑

根据 [`sqlite3_web` 的说明](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_web#getting-started) 编写在 Web Worker 中的数据库管理逻辑，例如 [`impl_web/sqlite3_web/sqlite3_web_worker.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_worker.dart) 。

#### Web Worker 启动入口

```dart
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
> 用于自定义 Wasm 模块加载的 `WasmModuleLoader` 在 `sqlite3: 3.3.0` 才[被引入](https://github.com/simolus3/sqlite3.dart/issues/359)，因此 `3.3.0` 是最低版本要求。

<details>
<summary><b> 📝 <code>DefaultSimpleWasmModuleLoader</code></b> 实现</summary>

<br />

由于 Simple 涉及文件读写（`fopen`、`read`、`write` ...）等在 Web 环境中不可用的系统调用，WASI 会将其统一抽象为 `wasi_snapshot_preview1` 模块的 API（`path_open`、`fd_read`、`fd_write` 等）并要求宿主侧提供实现。`DefaultSimpleWasmModuleLoader` 通过 [`wasd`](https://github.com/medz/wasd) 实现了这些 API，为 Simple 提供了 Web 环境支持。

如果默认实现不满足要求，可以自行继承 [`SimpleBridgeCallbacks`](../../core/lib/src/web/bridge_callbacks.dart)（重写后仍需要写 `@JSExport()` ） 和 `WasmModuleLoader` 进行扩展。

</details>

#### 通过主线程传递自定义消息，加载结巴分词字典文件

如需启用结巴分词，需要通过 `DefaultSimpleWasmModuleLoader.updateFiles()` 传入结巴分词字典的 `Uint8List` 字节内容，具体而言：

1. 对于 Dart 项目，`sqlite3_simple_core` 不包含字典文件，需要自行提供，可从 [此处](https://github.com/yanyiwu/cppjieba/tree/master/dict) 下载，并将其放置到 Web 可访问的路径；

2. 对于 Flutter 项目，`sqlite3_simple` 内置了结巴分词所需的字典文件，**在主线程调用** [`JiebaDictAssets.loadPaths()`](../lib/jieba_dict_assets.dart) 即可获取其在 Flutter 资源中的路径。

获取路径后，建议直接将其从主线程传递给 Worker ，由后者读取字节内容，避免不必要的跨线程复制开销。为此，主线程发送端与 Worker 接收端各需一段自定义消息处理。接收端通过 JS 函数 `fetch` 读取字节内容并调用 `_loader.updateFiles()`，示例如下：

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
    final requestJO = request.request as JSObject;
    final type = (requestJO['type'] as JSString).toDart;
    switch(type) {
      case 'updateJiebaDict': // 自定义消息 { 'type': 'updateJiebaDict', 'path2url': 虚拟路径 → 资源 URL }
        final path2url = (requestJO['path2url'].dartify() as Map).cast<String, String>();
        final jiebaDictFiles = {
          for (final e in path2url.entries)
            e.key: await fetchFromBase(e.value),
        };
        _loader.updateFiles((it) => it..addAll(jiebaDictFiles)); // 更新结巴分词文件，其他已有文件继续保留
        break;
    }
    return null;
  }
}
```

`fetchFromBase` 来自 [`impl_web/fetch.dart`](../example/lib/data/impl_web/fetch.dart)：

```dart
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

@JS("fetch")
external JSPromise<Response> jsFetch(URL resource, [RequestInit? options]);

Future<Uint8List> fetch(String url, [String? base]) async {
  final jsURL = base != null ? URL(url, base) : URL(url);
  final response = await jsFetch(jsURL).toDart;
  return (await response.bytes().toDart).toDart;
}

Future<Uint8List> fetchFromBase(String url) => fetch(url, Uri.base.toString());
```

#### 编译为 JavaScript

在 `example` 目录下执行如下命令，编译成 `sqlite3_web_worker.dart.js` 以供后续使用：

```shell
dart compile js lib/data/impl_web/sqlite3_web/sqlite3_web_worker.dart -o web/sqlite3_web_worker.dart.js -O4
```

> [!IMPORTANT]
>
> `package:flutter/*`、`dart:ui` 等 Flutter 专属库不支持编译为 JS，注意不要被直接或间接依赖。

调试阶段建议省略 `-O4` 优化选项，以保留更清晰的错误信息和调用栈，方便问题定位。

### 4. 打开数据库

根据 [`sqlite3_web` 的说明](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_web#getting-started)，以及前面下载的 `sqlite3.wasm` 和编译的 `sqlite3_web_worker.dart.js`，参考 [`impl_web/sqlite3_web/sqlite3_web_impl.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_impl.dart)，调用 `connectToRecommended()` 或 `connect()` 打开数据库：

```dart
final webSqlite3 = WebSqlite.open(
  workers: WorkerConnector.defaultWorkers(
    Uri.parse('sqlite3_web_worker.dart.js'),
  ),
  wasmModule: Uri.parse('sqlite3.wasm'),
);
final db = (await webSqlite3.connectToRecommended('database')).database;
```

如需启用结巴分词，对应前文 Worker 接收端的处理，编写主线程发送端的逻辑，即调用 `db.customRequest()` 传递路径：

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
await db.execute("SELECT jieba_dict(?)", parameters: [jiebaDictDir]); // 修改 Simple 扩展读取字典的路径
final init = await db.select( // 推荐在正式查询前执行一次查询，提前加载
  "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
);
if (kDebugMode) print(init.result);
```

### 5. 创建主表、FTS5 虚表和触发器

根据 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和实际项目需求创表，例如 [`main_table_schema.dart`](../example/lib/data/main_table_schema.dart) ：

```dart
// final fts5Tokenizer = "simple 0";  // 关闭拼音搜索
const fts5Tokenizer = "simple";
const mainTable = "custom";
const id = "id",
    title = "title",
    content = "content",
    insertDate = "insert_date";
const fts5Table = "t1";

/// 主表、FTS5 虚表及其触发器的建表语句，供各原始 SQL 实现共用。
/// 官方说明：https://sqlite.org/fts5.html
const createMainAndFts5Statements = <String>[
  /// 主表
  '''
    CREATE TABLE $mainTable (
      $id INTEGER PRIMARY KEY AUTOINCREMENT, 
      $title TEXT, 
      $content TEXT, 
      $insertDate INTEGER
    );
  ''',

  /// FTS5 虚表
  '''
    CREATE VIRTUAL TABLE $fts5Table USING fts5(
      $title, $content, $insertDate UNINDEXED, 
      tokenize = '$fts5Tokenizer', 
      content = '$mainTable', 
      content_rowid = '$id'
    );
  ''',

  /// 触发器
  '''
    CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
      $_newInsert
    END;
  ''',
  '''
    CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
      $_deleteInsert
    END;
  ''',
  '''
    CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
      $_deleteInsert
      $_newInsert
    END;
  ''',
];

const _newInsert = '''
  INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
    VALUES (new.$id, new.$title, new.$content, new.$insertDate);
''';

const _deleteInsert = '''
  INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate) 
    VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
''';
```

在 [`impl_web/sqlite3_web/sqlite3_web_impl.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_impl.dart) 中执行：

```dart
final version = (await db.select(
  "PRAGMA user_version",
)).result.first['user_version'];
if (version == 0) {
  for (final statement in createMainAndFts5Statements) {
    await db.execute(statement);
  }
  await db.execute("PRAGMA user_version = 1");
}
```

### 6. 查询

参阅 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用 `jieba_query`、`simple_query`、`simple_highlight`、`highlight` 进行查询，例如 [`impl_web/sqlite3_web/sqlite3_web_impl.dart`](../example/lib/data/impl_web/sqlite3_web/sqlite3_web_impl.dart) ：

```dart
@override
Future<SearchResult> search(String value, Tokenizer tokenizer) async {
  final stopwatch = Stopwatch()..start();
  final tokenResult = await db.select(
    'SELECT ${tokenizer.queryFunctionName}(?) AS q',
    parameters: [value],
  );
  final tokens = '${tokenResult.result.first['q']}';
  const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
  final resultSet = await db.select(
    '''
    SELECT 
      rowid AS $id, 
      simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
      simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
      $insertDate 
    FROM $fts5Table 
    WHERE $fts5Table MATCH ${tokenizer.queryFunctionName}(?);
  ''',
    parameters: [value],
  );
  stopwatch.stop();
  return SearchResult(
    rows: _toMainTableRows(resultSet.result),
    tokens: tokens,
    elapsed: stopwatch.elapsed,
  );
}
```