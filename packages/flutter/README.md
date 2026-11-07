# sqlite3_simple

[![Pub Package](https://img.shields.io/pub/v/sqlite3_simple?style=for-the-badge&logo=flutter)](https://pub.dev/packages/sqlite3_simple) [![simple-native](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&label=simple-native&style=for-the-badge&logo=github&logoColor=white)](https://github.com/SageMik/sqlite3_simple/tree/simple-native)

![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white) ![iOS](https://img.shields.io/badge/iOS-black?style=for-the-badge&logo=ios&logoColor=white) ![MacOS](https://img.shields.io/badge/MAC%20OS-black?style=for-the-badge&logo=apple&logoColor=white) ![Windows](https://img.shields.io/badge/Windows-0078d7?style=for-the-badge&logo=gitforwindows&logoColor=white) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![Web](https://img.shields.io/badge/Web-654FF0?style=for-the-badge&logo=webassembly&logoColor=white)

基于 [Simple](https://github.com/wangfenjin/simple) (支持中文和拼音的 SQLite FTS5 全文搜索扩展) 和 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 的 Dart / Flutter 库。

在线演示：[Simple 分词器 示例](https://sagemik.github.io/sqlite3_simple) 。

| Android ([apk](https://github.com/SageMik/sqlite3_simple/releases/download/v3.0.0/example.apk)), iOS | Windows, MacOS, Linux, Web |
|------------------------------------------------------------------------------------------------------|----------------------------|
|                                                                                                      |                            |

> [!TIP]
>
> Web 平台使用步骤与其他平台存在差异，具体请参阅 [`doc/web.md`](doc/web.md)。

## 目录

- [前置说明](#前置说明)
- [快速开始](#快速开始)
  - [1. 添加依赖](#1-添加依赖)
  - [2. 加载 Simple 扩展](#2-加载-simple-扩展)
  - [3. 打开数据库](#3-打开数据库)
  - [4. 创建主表、FTS5 虚表和触发器](#4-创建主表fts5-虚表和触发器)
  - [5. 查询](#5-查询)
  - [6. 自定义 Simple 原生库来源](#6-自定义-simple-原生库来源)
    - [构建期配置](#构建期配置)
    - [运行时加载](#运行时加载)
- [致谢](#致谢)

## 前置说明

SQLite 通过 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 提供全文搜索 (Full-Text Search) 功能；

Dart 通过 [`dart:ffi`](https://dart.cn/interop/c-interop/) 调用 SQLite、Simple 等 C/C++ 库；通过 [Hooks](https://dart.dev/tools/hooks) 统一管理各平台原生库；

请参阅相关文档或下述具体示例，以完成数据库全文搜索的功能接入：

1. [`../core/example/bin`](../core/example/bin)：Dart TUI 示例；
2. [`../core/example/web`](../core/example/web)：Dart Web 示例；
3. [`example`](example)：Flutter 示例。

> [!TIP]
>
> 本库通过 [`sqlite3`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 管理数据库，因此理论上任何依赖于 `sqlite3` 的 Flutter 库，均可通过本库实现中文和拼音全文搜索，例如 [`drift`](https://github.com/simolus3/drift)、[`sqflite_common_ffi`](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi)，可在 [`example/lib/data/impl`](example/lib/data/impl) 查看具体示例。

## 快速开始

### 1. 添加依赖

Dart 项目请添加 `sqlite3_simple_core` 依赖；Flutter 项目推荐直接添加 `sqlite3_simple` 依赖，其内置结巴分词字典文件资源，可免去自行下载配置环节。

```shell
# Dart 项目
dart pub add sqlite3 sqlite3_simple_core

# Flutter 项目
flutter pub add sqlite3 sqlite3_simple
```

### 2. 加载 Simple 扩展

```dart
import 'package:sqlite3/sqlite3.dart';


// Dart 项目
import 'package:sqlite3_simple_core/sqlite3_simple_core.dart';

// Flutter 项目
import 'package:sqlite3_simple/sqlite3_simple.dart';


sqlite3.loadSimpleExtension();
```

如需启用结巴分词 (由 [cppjieba](https://github.com/yanyiwu/cppjieba) 驱动) ，需要确保本地路径存在可访问的结巴字典文件。

Dart 项目需要自行提供，可从 [此处](https://github.com/yanyiwu/cppjieba/tree/master/dict) 下载；Flutter 项目可直接调用 `sqlite3.saveJiebaDict()` 将内置字典文件保存到本地，例如：

```dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final docDir = await getApplicationDocumentsDirectory();
final jiebaDictPath = join(docDir.path, "cpp_jieba");

final jiebaDictSql = await sqlite3.saveJiebaDict(jiebaDictPath); // 返回值即 SELECT jieba_dict('$jiebaDictPath');
```

已存在的字典文件默认不覆盖，如需覆盖可传入 `overwriteWhenExist: true`。

> [!IMPORTANT]
>
> 受 Flutter 资源管理机制限制，`sqlite3.saveJiebaDict()` 只能在主隔离 (Main Isolate) 中调用。

| `sqlite3_simple` 结巴字典其他相关 API | 说明                                                          |
|---------------------------------------|---------------------------------------------------------------|
| `JiebaDictAssets.loadPaths()`         | 获取内置字典的资产路径，可通过 `rootBundle.load` 读取字典字节 |
| `sqlite3.saveJiebaDictFromBytes()`    | 将内存中的字典字节保存到本地                                  |
| `JiebaDictType`                       | 结巴字典文件枚举，自行提供字典文件时，务必覆盖定义的五个文件  |

### 3. 打开数据库

参阅 [`sqlite3`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 的说明，通过 `sqlite3.open()` 或 `sqlite3.openInMemory()` 打开数据库。

``dart
final db = sqlite.open('$filename');
```

如需启用结巴分词，Dart 和 Flutter 项目都请执行 `"SELECT jieba_dict('$jiebaDictPath')"` 语句，以修改 Simple 扩展读取结巴分词字典的路径：

```dart
// Dart 项目
db.execute("SELECT jieba_dict('$jiebaDictPath')");

// Flutter，上一步 `saveJiebaDict()` 的返回值
db.execute(jiebaDictSql);
```

推荐在正式查询前的空闲时间执行一次查询，提前加载，例如：

```dart
db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
```

### 4. 创建主表、FTS5 虚表和触发器

根据 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 的说明和实际项目需求，创建主表、FTS5 虚表和触发器，例如 [`createMainAndFts5Statements`](./example/lib/data/main_table_schema.dart)：

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

在 [`example/lib/data/impl/sqlite3/sqlite3_impl.dart`](./example/lib/data/impl/sqlite3/sqlite3_impl.dart) 中执行：

```dart
final version = db.select("PRAGMA user_version").first['user_version'];
if (version == 0) {
  for (final statement in createMainAndFts5Statements) {
    db.execute(statement);
  }
  db.execute("PRAGMA user_version = 1");
}
```

### 5. 查询

参阅 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用 `jieba_query`、`simple_query`、`highlight`、`simple_highlight` 进行查询，例如 [`Sqlite3Dao.search()`](./example/lib/data/impl/sqlite3/sqlite3_dao.dart)：

```dart
/// 根据 [value] 和 指定分词器 [tokenizer] 搜索， [tokenizer] 取值：[Tokenizer.jieba], [Tokenizer.simple]
Future<SearchResult> search(String value, Tokenizer tokenizer) async {
  final stopwatch = Stopwatch()..start();
  final tokens =
      '${db.select('SELECT ${tokenizer.queryFunctionName}(?) AS q', [value]).first['q']}';
  const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
  final resultSet = db.select('''
    SELECT 
      rowid AS $id, 
      simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
      simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
      $insertDate 
    FROM $fts5Table 
    WHERE $fts5Table MATCH ${tokenizer.queryFunctionName}(?);
  ''', [value]);
  stopwatch.stop();
  return SearchResult(
    rows: _toMainTableRows(resultSet),
    tokens: tokens,
    elapsed: stopwatch.elapsed,
  );
}
```

### 6. 自定义 Simple 原生库来源

> [!IMPORTANT]
>
> 本库默认使用 [`simple-native` 分支](https://github.com/SageMik/sqlite3_simple/tree/simple-native) 通过 GitHub Actions 编译的 Simple 原生库（`libsimple.dart.zip`），与上游存在一定差异，详见该分支的文档说明。

如需更换来源，Dart 和 Flutter 项目都可通过如下两种方式配置：

#### 构建期配置

基于 Dart Hooks 的配置机制，可在 `pubspec.yaml` 的 `hooks.user_defines` 下为 `sqlite3_simple_core` 指定原生库来源，例如 [`../core/example/pubspec.yaml`](../core/example/pubspec.yaml) ：

```yaml
hooks:
  user_defines:
    sqlite3_simple_core:
      source: local
      path: libsimple.dart.zip
```

`source` 有如下取值：

| 取值       | 说明                                                                                                                                             |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `download` | 从 `url` 指定的地址下载，可用 `sha256` 校验，默认地址 `https://github.com/SageMik/sqlite3_simple/releases/download/NvX.Y.Z/libsimple.dart.zip`。 |
| `local`    | 使用 `path` 指定的压缩包、目录或单个原生库文件，可使用绝对或相对路径（相对于 `pubspec.yaml` 所在目录）                                           |
| `none`     | 不在构建期打包原生库                                                                                                                             |

原生库需要按照 `(lib)simple.<平台>.<架构>.<后缀>` 的方式命名，例如：

```text
libsimple.dart.zip
  ├── libsimple.android.arm.so
  ├── libsimple.android.arm64.so
  ├── libsimple.android.x64.so
  ├── libsimple.ios.arm64.dylib
  ├── libsimple.ios_sim.arm64.dylib
  ├── libsimple.ios_sim.x64.dylib
  ├── libsimple.linux.arm64.so
  ├── libsimple.linux.x64.so
  ├── libsimple.macos.arm64.dylib
  ├── libsimple.macos.x64.dylib
  └── simple.windows.x64.dll
```

这也是本库在非 Web 平台默认支持的平台与架构。如有需要，可根据 [`OS`](https://github.com/dart-lang/native/blob/code_assets-v2.1.0/pkgs/code_assets/lib/src/code_assets/os.dart) 和 [`Architecture`](https://github.com/dart-lang/native/blob/code_assets-v2.1.0/pkgs/code_assets/lib/src/code_assets/architecture.dart) 自行替换或提供其他原生库如 `libsimple.fuchsia.x64.so`。

此外，还可以通过 `skip_targets` 跳过部分平台：

```yaml
hooks:
  user_defines:
    sqlite3_simple_core:
      skip_targets:
        - windows
        - ios_sim-arm64
```

被跳过的平台，构建产物里不会包含原生库。因此务必在运行时自行加载原生库，否则无法正常使用，详见下文。

#### 运行时加载

`sqlite3.loadSimpleExtension()` 提供了 `override` 参数用于在运行时覆盖默认的加载方式。例如让 Android 使用原生依赖提供的 Simple 原生库：

`build.gradle(.kts)`：

```gradle
dependencies {
    implementation("io.github.sagemik:simple-native-android:3.0.0")
}
```

`pubspec.yaml`：

```yaml
hooks:
  user_defines:
    sqlite3_simple_core:
      skip_targets:
        - android
```

加载时：

```dart
final SqliteExtension? simpleExtension;
if (Platform.isAndroid) {
  simpleExtension = SqliteExtension.inLibrary(
    DynamicLibrary.open('libsimple.so'),
    simpleInitSymbol, // sqlite3_simple_init
  );
} else {
  simpleExtension = null;
}
sqlite3.loadSimpleExtension(override: simpleExtension);
```

如此，Android 就会使用由 `simple-native-android` 提供的原生库，其他平台继续使用 Dart Hooks 打包的原生库，`skip_targets` 使 Dart Hooks 跳过 Android 的打包避免出现多份原生库。

## 致谢

| 项目                                                             | 说明                                                      |
|------------------------------------------------------------------|-----------------------------------------------------------|
| [Simple](https://github.com/wangfenjin/simple)                   | 支持中文和拼音的 SQLite FTS5 全文搜索扩展                 |
| [sqlite3.dart](https://github.com/simolus3/sqlite3.dart)         | SQLite3 的 Dart FFI 绑定                                  |
| [extended_text](https://github.com/fluttercandies/extended_text) | Flutter Text 的扩展组件，支持特殊文本效果                 |
| [wasd](https://github.com/medz/wasd)                             | 面向 Dart 和 Flutter 生态系统的纯 Dart WebAssembly 运行时 |
| [Riverpod](https://github.com/rrousselGit/riverpod)              | 响应式缓存与数据绑定框架，用于应用的状态管理              |
| [Squadron](https://github.com/d-markey/squadron)                 | Dart 多线程管理框架                                       |