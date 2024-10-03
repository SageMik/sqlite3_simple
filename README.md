# sqlite3_simple

基于 [Simple](https://github.com/wangfenjin/simple) (SQLite Fts5扩展) 和 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 的 Dart/Flutter 库，用于 SQLite 数据库中文和拼音的全文搜索。

![示例](example/example.jpg)

## 平台支持

| Android | iOS |
| ------- | --- |
| ✔      | ✔  |

## 前置准备

SQLite 通过 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 提供全文搜索功能；

Dart 提供 FFI 以调用 SQLite、Simple 等 C/C++ 库；

本库通过 [Simple](https://github.com/wangfenjin/simple) 实现中文拼音全文搜索，通过 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 连接数据库。

请参阅相关文档，或 `example` 的具体示例，以构建和操作数据库。

## 快速开始

### 1. 添加 SQLite 依赖

执行如下命令行：

```shell
flutter pub add sqlite3 sqlite3_flutter_libs
```

其中 `sqlite3_flutter_libs` 包含了 SQLite 的原生库(Native Library)。若需 自定义和自行编译SQLite 或 环境中已存在SQLite ，可通过 `DynamicLibrary` 加载，具体请参考 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3#manually-providing-sqlite3-libraries)、[sqlite3_flutter_libs](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3_flutter_libs) 的做法。

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

返回值 `jiebaDictSql` 是 `"SELECT jieba_dict('$jiebaDictPath')"`。

### 4. 打开数据库

参阅 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 相关说明，通过 `sqlite3.open()` 或 `sqlite3.openInMemory()` 打开数据库。

```dart
final db = sqlite3.open('$filename');
```

如需启用结巴分词，请让数据库执行上一步的 `jiebaDictSql` 语句，以修改 Simple 扩展中结巴分词字典的位置：

```dart
db.execute(jiebaDictSql);
```

推荐在正式查询前执行一次查询，提前加载，例如：

```dart
final init = db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
print(init);
```

> 打印结果：
>
> `I/flutter ( 8795): [{jieba_query('Jieba分词初始化（提前加载避免后续等待）'): ( j+i+e+b+a* OR ji+e+ba* OR jie+ba* OR jieba* ) AND "分词" AND "初始化" AND "（" AND "提前" AND "加载" AND "避免" AND "后续" AND "等待" AND "）"}]`

### 5. 查询

请参阅 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用相应函数如 `jieba_query`、`simple_query`、`highlight`、  `simple_highlight` 等，执行所需的查询，例如 (  `./expample/lib/dao.dart` )：

```dart
  List<MainTableRow> searchByJieba(String value) {
    const wrapperSql = "'${ZeroWidth.start}', '${ZeroWidth.end}'";
    final resultSet = db.select(
        "SELECT "
        "rowid AS $id, "
        "simple_highlight($fts5Table, 0, $wrapperSql) AS $title, "
        "simple_highlight($fts5Table, 1, $wrapperSql) AS $content, "
        "$insertDate "
        "FROM $fts5Table "
        "WHERE $fts5Table MATCH jieba_query(?);",
        [value]);
    return _toMainTableRows(resultSet);
  }
```

## 待办

- [ ] 添加其他平台的适配。
  - [ ] Windows
  - [ ] Linux
  - [ ] MacOS
- [ ] 添加用户自定义字典。

## 致谢

[Simple](https://github.com/wangfenjin/simple)：支持中文和拼音的 SQLite FTS5 全文搜索扩展。

[sqlite3.dart](https://github.com/simolus3/sqlite3.dart)：SQLite3 的 Dart FFI 绑定。

[extended_text](https://github.com/fluttercandies/extended_text/)：Flutter Text 的扩展组件，支持特殊文本效果。
