# sqlite3_simple_core

[![Pub Package](https://img.shields.io/pub/v/sqlite3_simple_core?style=for-the-badge&logo=dart)](https://pub.dev/packages/sqlite3_simple_core) [![simple-native](https://img.shields.io/github/v/tag/SageMik/sqlite3_simple?filter=Nv%2A&label=simple-native&style=for-the-badge&logo=cmake&logoColor=white)](https://github.com/SageMik/sqlite3_simple/releases)

![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white) ![iOS](https://img.shields.io/badge/iOS-black?style=for-the-badge&logo=ios&logoColor=white) ![Windows](https://img.shields.io/badge/Windows-0078d7?style=for-the-badge&logo=gitforwindows&logoColor=white) ![macOS](https://img.shields.io/badge/MAC%20OS-black?style=for-the-badge&logo=apple&logoColor=white) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![Web](https://img.shields.io/badge/Web-654FF0?style=for-the-badge&logo=webassembly&logoColor=white)

基于 [Simple](https://github.com/wangfenjin/simple) (支持中文和拼音的 SQLite FTS5 全文搜索扩展) 和 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 的 Dart 库，用于 SQLite 中文和拼音全文搜索。

> [!TIP]
>
> 本库是通过 [Dart Hooks](https://dart.dev/tools/hooks) 管理 Simple 原生库的纯 Dart 核心库，不包含结巴字典文件和 Flutter 依赖。Flutter 场景下建议直接使用 [`sqlite3_simple`](https://github.com/SageMik/sqlite3_simple) 。

## 快速开始

### 非 Web 平台

#### 1. 添加依赖

添加 `sqlite3` 和本库：

```shell
flutter pub add sqlite3 sqlite3_simple_core
```

#### 2. 加载 Simple 扩展

```dart
sqlite3.loadSimpleExtension();
```

如需使用结巴分词，请确保 [结巴分词字典文件](https://github.com/yanyiwu/cppjieba/tree/master/dict) 位于应用可访问的本地路径，并在打开数据库后执行 `SELECT jieba_dict('path/to/cppjieba_dict')` 。

若持有字典文件的字节内容，可通过 [`sqlite3.saveJiebaDictFromBytes`](lib/src/io/extension.dart) 一步到位保存到本地，例如：

```dart

```

其中 [`JiebaDictType`](lib/jieba_dict_type.dart) 定义了结巴分词所需的所有字典文件类型，可通过类型的方式确保字典文件的存在：

```dart
enum JiebaDictType {
  jiebaDict("jieba.dict.utf8"),
  hmmModel("hmm_model.utf8"),
  userDict("user.dict.utf8"),
  idf("idf.utf8"),
  stopWords("stop_words.utf8");

  const JiebaDictType(this.filename);

  /// 文件名
  final String filename;

  /// [filename] 到 [JiebaDictType] 的映射
  static final Map<String, JiebaDictType> byFilename = Map.unmodifiable({
    for (final k in values) k.filename: k,
  });
}
```

#### 3. 打开数据库

根据 [`sqlite3`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 的说明，通过 `sqlite3.open()` 或 `sqlite3.openInMemory()` 打开数据库。

```dart 
final db = sqlite3.open('$filename');
```

如需使用结巴分词，如上一步所言，确保执行修改 Simple 扩展读取结巴分词字典的路径的 SQL 语句：

```dart
db.execute("SELECT jieba_dict('path/to/cppjieba_dict')");
// 或上一步是通过 `saveJiebaDictFromBytes` 保存字典文件的，执行返回的语句即可：
// db.execute(jiebaDictSql);
```

推荐在正式查询前执行一次查询，提前加载，例如：

```dart
db.select("SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')");
```

#### 4. 创建主表、FTS5 虚表和触发器

根据 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) 和 [Simple](https://github.com/wangfenjin/simple#%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%BD%BF%E7%94%A8) 的说明和实际项目需求，创建主表、FTS5 虚表和触发器，例如：

```dart

```

#### 5. 查询 

根据 [Simple](https://github.com/wangfenjin/simple#%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%BD%BF%E7%94%A8) 的说明和实现需求，调用 `jieba_query`、`simple_query`、`highlight`、`simple_highlight` 进行查询，例如：

```dart

```

### Web 平台

## 致谢
