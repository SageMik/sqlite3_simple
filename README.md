# sqlite3_simple

基于 [Simple](https://github.com/wangfenjin/simple) (支持中文和拼音的 SQLite FTS5 全文搜索扩展) 和 [sqlite3.dart](https://github.com/simolus3/sqlite3.dart) 的 Dart 和 Flutter 库。

阅读 [`sqlite_simple`(`packages/flutter`)](packages/flutter) 的[文档](packages/flutter/README.md)了解详细使用方法。

| 路径                                   | 包名                  | Pub                                                                                                                                            | 说明                                                                                                                    |
|----------------------------------------|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| [`packages/core`](packages/core)       | `sqlite3_simple_core` | [![Pub Package](https://img.shields.io/pub/v/sqlite3_simple_core?style=for-the-badge&logo=dart)](https://pub.dev/packages/sqlite3_simple_core) | Dart 库                                                                                                                 |
| [`packages/flutter`](packages/flutter) | `sqlite3_simple`      | [![Pub Package](https://img.shields.io/pub/v/sqlite3_simple?style=for-the-badge&logo=flutter)](https://pub.dev/packages/sqlite3_simple)        | Flutter 库，基于 `sqlite3_simple_core`，内置了 [结巴字典文件资源](https://github.com/yanyiwu/cppjieba/tree/master/dict) |
