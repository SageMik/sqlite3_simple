# sqlite3_simple

[![Pub Package](https://img.shields.io/pub/v/sqlite3_simple?style=for-the-badge&logo=flutter)](https://pub.dev/packages/sqlite3_simple)
[![simple-native](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&label=simple-native&style=for-the-badge&logo=github&logoColor=white)](https://github.com/SageMik/sqlite3_simple/tree/simple-native)

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-black?style=for-the-badge&logo=harmonyos)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-black?style=for-the-badge&logo=ios&logoColor=white)
![MacOS](https://img.shields.io/badge/MAC%20OS-black?style=for-the-badge&logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078d7?style=for-the-badge&logo=gitforwindows&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

基于 [Simple](https://github.com/wangfenjin/simple) (支持中文和拼音的 SQLite fts5 全文搜索扩展) 和 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 的 Flutter 库，用于 SQLite 中文和拼音全文搜索。

| 支持平台                                                                                                             | 示例                          |
|------------------------------------------------------------------------------------------------------------------|-----------------------------|
| **HarmonyOS<br />([详见此处](#x-修改依赖版本以启用-harmonyos-支持可选))**                                                         | ![HarmonyOS](img/ohos.png)  |
| **Android<br />([example.apk](https://github.com/SageMik/sqlite3_simple/releases/download/v1.0.4/example.apk))** | ![Android](img/android.png) |
| **iOS**                                                                                                          | ![iOS](img/ios.png)         |
| **Windows**                                                                                                      | ![Windows](img/windows.jpg) |
| **MacOS**                                                                                                        | ![MacOS](img/macos.png)     |
| **Linux**                                                                                                        | ![Linux](img/linux.png)     |

## 目录

- [前置准备](#前置准备)
- [快速开始](#快速开始)
  - [1. 添加 SQLite 依赖](#1-添加-sqlite-依赖)
  - [2. 添加本库并导入依赖](#2-添加本库并导入依赖)
  - [X. 修改依赖版本以启用 HarmonyOS 支持（可选）](#x-修改依赖版本以启用-harmonyos-支持可选)
  - [3. 加载 Simple 扩展](#3-加载-simple-扩展)
  - [4. 打开数据库](#4-打开数据库)
  - [5. 查询](#5-查询)
- [待办](#待办)
- [致谢](#致谢)

## 前置准备

> [!TIP]
>
> 本库通过 Github Actions 编译 Simple 原生库，具体请参阅 [simple-native](https://github.com/SageMik/sqlite3_simple/tree/simple-native) 分支。

SQLite 通过 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 提供 全文搜索 (Full-Text Search) 功能；

Dart 提供 FFI 以调用 SQLite、Simple 等 C/C++ 库；

本库通过 [Simple](https://github.com/wangfenjin/simple) 实现 中文拼音全文搜索，通过 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 操作数据库和加载自定义扩展。如果您使用 [Drift](https://github.com/simolus3/drift) 操作数据库，由于 [Drift](https://github.com/simolus3/drift) 基于 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) ，同样可以使用本库实现中文拼音全文搜索（理论上，也适用于任何依赖于 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 的 Flutter 库）。

请参阅相关文档，或 [`example`](./example) 的具体示例，以构建和操作数据库。

> [!IMPORTANT]
> 
> 本库基于 [鸿蒙先锋队 / Flutter 3.22.0](https://gitee.com/harmonycommando_flutter/flutter/tree/oh-3.22.0) 实现 HarmonyOS 适配，示例项目使用的 `extended_text` 版本是 `13.1.0` 。
> 
> 由于官方的破坏性变更，使用 Flutter 3.24 以及更高版本运行示例时会遇到兼容性问题，请将 [`pubspec.yaml` 中的 `extended_text` 升级到 `14.1.0` 或更高版本](example/pubspec.yaml#L38-L47) 以解决不兼容报错。

## 快速开始

### 1. 添加 SQLite 依赖

执行如下命令行：

```shell
flutter pub add sqlite3 sqlite3_flutter_libs
```

其中 `sqlite3` 包含了 SQLite 的 Dart FFI 绑定， `sqlite3_flutter_libs` 包含了 SQLite 的原生库 (Native Library) ，源码均在 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 。

> [!TIP]
>  
> 若希望自行编译 SQLite 原生库，或环境已存在 SQLite 原生库，可不引入 `sqlite3_flutter_libs` ，自行通过 `DynamicLibrary`、`open.overrideFor` 加载和覆盖。您可以从下述位置获取相关信息：
> 1. [sqlite.dart](https://github.com/simolus3/sqlite3.dart) 中 [Manually providing sqlite3 libraries](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3#manually-providing-sqlite3-libraries) 。
> 2. [sqlite-ohos.dart](https://github.com/SageMik/sqlite3-ohos.dart) 中 [自行提供 SQLite 原生库](https://github.com/SageMik/sqlite3-ohos.dart/tree/main/sqlite3#%E8%87%AA%E8%A1%8C%E6%8F%90%E4%BE%9B-sqlite-%E5%8E%9F%E7%94%9F%E5%BA%93) 。
> 3. [`example`](example) 中带有 **Android SQLite 覆盖** 标识的简单示例（可以全局搜索该标识）。

### 2. 添加本库并导入依赖

```shell
flutter pub add sqlite3_simple
```

```dart
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple/sqlite3_simple.dart';
```

### X. 修改依赖版本以启用 HarmonyOS 支持（可选）

本库基于 [鸿蒙先锋队 / Flutter 3.22.0](https://gitee.com/harmonycommando_flutter/flutter/tree/oh-3.22.0) 实现 HarmonyOS 适配，已在 Mac Arm HarmonyOS 模拟器上经过测试。

若需在 HarmonyOS 上使用，请修改项目 `pubspec.yaml` 文件中 `sqlite3`、`sqlite3_flutter_libs` 的版本：

```yaml
# 修改项目使用的版本为支持 HarmonyOS 的分支版本
dependencies:
  sqlite3:
    git:
      url: https://github.com/SageMik/sqlite3-ohos.dart
      path: sqlite3
      ref: sqlite3-2.4.7-ohos
  sqlite3_flutter_libs:
    git:
      url: https://github.com/SageMik/sqlite3-ohos.dart
      path: sqlite3_flutter_libs
      ref: sqlite3_flutter_libs-0.5.25-ohos

# 覆盖本库和其他库使用的版本为支持 HarmonyOS 的分支版本
dependency_overrides:
  sqlite3:
    git:
      url: https://github.com/SageMik/sqlite3-ohos.dart
      path: sqlite3
      ref: sqlite3-2.4.7-ohos
  sqlite3_flutter_libs:
    git:
      url: https://github.com/SageMik/sqlite3-ohos.dart
      path: sqlite3_flutter_libs
      ref: sqlite3_flutter_libs-0.5.25-ohos
```

### 3. 加载 Simple 扩展

```dart
sqlite3.loadSimpleExtension();
```

如需启用 结巴分词 (Jieba) ，请调用 `sqlite3.saveJiebaDict()` 将字典保存到可访问的路径，例如：

```dart
import 'package:path_provider/path_provider.dart';

final docDir = await getApplicationDocumentsDirectory();
final jiebaDictPath = join(docDir.path, "cpp_jieba");

final jiebaDictSql = await sqlite3.saveJiebaDict(jiebaDictPath);
```

返回值 `jiebaDictSql` 是 `"SELECT jieba_dict('$jiebaDictPath')"` 。

### 4. 打开数据库

参阅 [sqlite3](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 相关说明，通过 `sqlite3.open()` 或 `sqlite3.openInMemory()` 打开数据库。

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

请参阅 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和 [Simple](https://github.com/wangfenjin/simple) 的说明，根据需要调用相应函数如 `jieba_query`、`simple_query`、`highlight`、  `simple_highlight` 等，执行所需的查询，例如 (  [`./expample/lib/dao.dart`](./example/lib/dao.dart) )：

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

- [X] 添加其他平台的适配。
  - [X] Windows
  - [X] MacOS
  - [X] HarmonyOS
  - [X] Linux
- [ ] 添加用户自定义字典。

## 致谢

[Simple](https://github.com/wangfenjin/simple)：支持中文和拼音的 SQLite FTS5 全文搜索扩展。

[sqlite3.dart](https://github.com/simolus3/sqlite3.dart)：SQLite3 的 Dart FFI 绑定。

[extended_text](https://github.com/fluttercandies/extended_text)：Flutter Text 的扩展组件，支持特殊文本效果。
