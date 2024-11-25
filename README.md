> [!TIP]
>
> 基于 [Flutter 鸿蒙适配版](https://gitee.com/harmonycommando_flutter/flutter) 的开发正在努力推进中，目前已经成功在 HarmonyOS 模拟器上正常运行，详见 [ohos](https://github.com/SageMik/sqlite3_simple/tree/ohos) 分支。

# sqlite3_simple

[![Pub Package](https://img.shields.io/pub/v/sqlite3_simple)](https://pub.dev/packages/sqlite3_simple)  [![simple-native-android](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=simple-native-android)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)  [![simple-native](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&label=simple-native)](https://github.com/SageMik/sqlite3_simple/tree/simple-native)

基于 [Simple](https://github.com/wangfenjin/simple) (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。

| 支持平台                                                                                                                            | 示例                                            |
|---------------------------------------------------------------------------------------------------------------------------------| ----------------------------------------------- |
| **Android<br />([example.apk](https://github.com/SageMik/sqlite3_simple/releases/download/v1.0.3/example.apk))<br /><br />iOS** | ![Android, iOS 示例](img/example/android-ios.jpg) |
| **Windows**                                                                                                                     | ![Windows 示例](img/example/windows.jpg)          |
| **MacOS**                                                                                                                       | ![MacOS 示例](img/example/macos.png)              |

## 前置准备

> [!TIP]
>
> 本库通过 Github Actions 编译 Simple 原生库，具体请参阅 [simple-native](https://github.com/SageMik/sqlite3_simple/tree/simple-native) 分支。

SQLite 通过 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 提供 全文搜索 (Full-Text Search) 功能；

Dart 提供 FFI 以调用 SQLite、Simple 等 C/C++ 库；

本库通过 [Simple](https://github.com/wangfenjin/simple) 实现 中文拼音全文搜索，通过 [sqlite3.dart/sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 操作数据库和加载自定义扩展。

（如果你使用 [drift](https://github.com/simolus3/drift) 操作数据库，由于 [drift](https://github.com/simolus3/drift) 基于 [sqlite3.dart/sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) ，同样可以使用本库实现中文拼音全文搜索）

请参阅相关文档，或 [`example`](./example) 的具体示例，以构建和操作数据库。

## 快速开始

### 1. 添加 SQLite 依赖

执行如下命令行：

```shell
flutter pub add sqlite3 sqlite3_flutter_libs
```

其中 `sqlite3` 包含了 SQLite 的 Dart FFI 绑定， `sqlite3_flutter_libs` 包含了 SQLite 的 原生库(Native Library)，源码均在 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 。

> [!TIP]
>
> 若需要自定义和自行编译 SQLite 原生库，或环境已存在 SQLite 原生库，可不引入 `sqlite3_flutter_libs` ，自行通过 `DynamicLibrary`、`open.overrideFor` 加载和覆盖，具体请参考 [sqlite3.dart/sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3#manually-providing-sqlite3-libraries) 的说明，或 `example` 中带有 *Android SQLite 覆盖* 标识的简单示例（可以全局搜索该标识）。

### 2. 添加本库并导入依赖

```shell
flutter pub add sqlite3_simple
```

```dart
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';
```

### 3. 加载 Simple 扩展

```dart
sqlite3.loadSimpleExtension();
```

如需启用结巴分词(Jieba)，请调用 `sqlite3.saveJiebaDict()` 将字典保存到可访问的路径，例如：

```dart
import 'package:path_provider/path_provider.dart';

final docDir = await getApplicationDocumentsDirectory();
final jiebaDictPath = join(docDir.path, "cpp_jieba");

final jiebaDictSql = await sqlite3.saveJiebaDict(jiebaDictPath);
```

返回值 `jiebaDictSql` 是 `"SELECT jieba_dict('$jiebaDictPath')"` 。

### 4. 打开数据库

参阅 [sqlite3.dart/sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 相关说明，通过 `sqlite3.open()` 或 `sqlite3.openInMemory()` 打开数据库。

```dart
final db = sqlite3.open('$filename');
```

如需启用结巴分词，请让数据库执行上一步的 `jiebaDictSql` 语句，以修改 Simple 扩展读取结巴分词字典的路径：

```dart
db.execute(jiebaDictSql);
```

推荐在正式查询前执行一次查询，提前加载，例如：

```dart
db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
```

### 5. 查询

请参阅 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用相应函数如 `jieba_query`、`simple_query`、`highlight`、  `simple_highlight` 等，执行所需的查询，例如 (  `./expample/lib/dao.dart` )：

```dart
/// 通过指定分词器 [tokenizer] 搜索， [tokenizer] 取值：jieba, simple
List<MainTableRow> search(String value, String tokenizer) {
  const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
  final resultSet = db.select('''
      SELECT 
        rowid AS $id, 
        simple_highlight($fts5Table, 0, $wrapperSql) AS $title, 
        simple_highlight($fts5Table, 1, $wrapperSql) AS $content, 
        $insertDate 
      FROM $fts5Table 
      WHERE $fts5Table MATCH ${tokenizer}_query(?);
    ''', [value]);
  return _toMainTableRows(resultSet);
}
```

## 待办

- [ ] 添加其他平台的适配。
  - [X] Windows
  - [X] MacOS
  - [ ] Linux
  - [ ] HarmonyOS
- [ ] 添加用户自定义字典。

## 致谢

[Simple](https://github.com/wangfenjin/simple)：支持中文和拼音的 SQLite FTS5 全文搜索扩展。

[sqlite3.dart](https://github.com/simolus3/sqlite3.dart)：SQLite3 的 Dart FFI 绑定。

[extended_text](https://github.com/fluttercandies/extended_text/)：Flutter Text 的扩展组件，支持特殊文本效果。
