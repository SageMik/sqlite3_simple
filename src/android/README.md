# simple-native-android

[![Maven Central](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=Maven%20Central&style=for-the-badge)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)

[Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展)](https://github.com/wangfenjin/simple) 的 Android 原生库，用于 [sqlite3_simple](https://github.com/SageMik/sqlite3_simple) Flutter 插件。

```gradle
implementation("io.github.sagemik:simple-native-android:2.0.0")
```

若要在 Android 项目中使用，由于 [Simple](https://github.com/wangfenjin/simple) 基于 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) ，而 Android 内置的 SQLite 并未启用 FTS5，故需要自行替换为支持的版本如 [sqlite-android](https://github.com/requery/sqlite-android) ，并自行加载扩展。

以 [sqlite-android](https://github.com/requery/sqlite-android) 为例：

1. 引入 `sqlite-android` 和 `simple-native-android` 依赖。
2. 创建 `SupportSQLiteOpenHelper`：
    ```kotlin
    fun createSQLiteOpenHelper(): SupportSQLiteOpenHelper {
            val extensionConfigs = mutableListOf(
                RequerySQLiteOpenHelperFactory.ConfigurationOptions {
                    it.apply {
                        customExtensions.add(
                            SQLiteCustomExtension("libsimple.so", "sqlite3_simple_init") // 加载 Simple 扩展
                        )
                    }
                }
            )
            return RequerySQLiteOpenHelperFactory(extensionConfigs).create(
                SupportSQLiteOpenHelper.Configuration( // 根据需要调整数据库配置
                    this, ":memory:", object : SupportSQLiteOpenHelper.Callback(1) {
                        override fun onCreate(db: SupportSQLiteDatabase) {
                            db.execSQL(
                                "CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple');" +
                                        "INSERT INTO t1 VALUES ('人工智能正在改变我们的生活方式');"
                            )
                        }
    
                        override fun onUpgrade(
                            db: SupportSQLiteDatabase,
                            oldVersion: Int,
                            newVersion: Int
                        ) {}
                    }
                )
            )
        }
    ```
3. 进行查询：
   ```kotlin
   val dbHelper = createSQLiteOpenHelper()
   val db = dbHelper.readableDatabase
   val result = db.query("SELECT simple_highlight(t1, 0, '[', ']') FROM t1 WHERE text MATCH simple_query('z s');")
   result.moveToFirst()
   println(result.getString(0)) // 打印结果：人工[智]能[正在]改变我们的[生]活方[式]
   ```
4. 若要使用结巴分词 `jieba_query()`，请参考 [Simple](https://github.com/wangfenjin/simple) 的说明和 [sqlite_simple 的实现](https://github.com/SageMik/sqlite3_simple/blob/main/lib/src/sqlite3_simple.dart)，自行获取 [cppjieba 字典文件](https://github.com/yanyiwu/cppjieba/tree/master/dict) 并调用 `jieba_dict()` 指定字典文件路径。