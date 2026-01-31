# simple-native-android

[![Maven Central](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=Maven%20Central&style=flat-square)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)

[Simple](https://github.com/wangfenjin/simple) 的 Android 原生库，用于 [sqlite3_simple](https://github.com/SageMik/sqlite3_simple) Flutter 插件。

若要在 Android 项目中使用，由于 [Simple](https://github.com/wangfenjin/simple) 基于 [SQLite FTS5 Extension](https://sqlite.org/fts5.html) ，而 Android 内置的 SQLite 并未启用 FTS5，故需要自行替换为支持的版本如 [sqlite-android](https://github.com/requery/sqlite-android) ，并自行加载扩展。

```gradle
implementation("io.github.sagemik:simple-native-android:2.0.0")
```
