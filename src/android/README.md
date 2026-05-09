# simple-native-android

[![Maven Central](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=Maven%20Central&style=for-the-badge)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)

[Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展)](https://github.com/wangfenjin/simple) 的 Android 原生库，用于 [`sqlite3_simple`](https://github.com/SageMik/sqlite3_simple) Flutter 插件。

```gradle
implementation("io.github.sagemik:simple-native-android:2.1.0")
```

若要在 Android 项目中使用，由于 [Simple](https://github.com/wangfenjin/simple) 基于 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) ，而 Android 内置的 SQLite 并未启用 FTS5，故需要自行替换为支持的版本如 [`sqlite-android`](https://github.com/requery/sqlite-android) ，并自行加载扩展。

参考项目中的示例 [`LibSimpleTest.kt`](simple-native-android/src/androidTest/kotlin/com/sagemik/test/LibSimpleTest.kt) ，引入 `sqlite-android` 和 `simple-native-android` 依赖后，通过 [Android SQLite API](https://developer.android.google.cn/training/data-storage/sqlite?hl=zh-cn) 加载扩展并管理数据库。[Room](https://developer.android.google.cn/training/data-storage/room?hl=zh-cn) 同理，可以通过  [`RoomDatabase.Builder.openHelperFactory`](https://developer.android.google.cn/reference/kotlin/androidx/room/RoomDatabase.Builder#openHelperFactory(androidx.sqlite.db.SupportSQLiteOpenHelper.Factory)) 实现。

若要使用结巴分词 `jieba_query()`，参考 [`LibSimpleTest.kt`](simple-native-android/src/androidTest/kotlin/com/sagemik/test/LibSimpleTest.kt) 的 `testJiebaQuery()`。这个示例根据 [Simple](https://github.com/wangfenjin/simple) 的说明和 [`sqlite_simple` 的实现](https://github.com/SageMik/sqlite3_simple/blob/main/lib/src/sqlite3_simple.dart)，读写 [`cppjieba` 字典文件](https://github.com/yanyiwu/cppjieba/tree/master/dict) 并调用 `jieba_dict()` 指定字典路径，从而成功启用结巴分词。

使用结巴分词时，建议正式查询前执行一次 `SELECT jieba_query()` ，避免后续加载等待。