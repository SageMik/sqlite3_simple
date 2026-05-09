# simple-native-ohos

[![OpenHarmony 三方库中心仓](https://img.shields.io/badge/dynamic/json?label=OpenHarmony%20%E4%B8%89%E6%96%B9%E5%BA%93%E4%B8%AD%E5%BF%83%E4%BB%93&style=for-the-badge&logo=harmonyos&url=https%3A%2F%2Fohpm.openharmony.cn%2Fohpmweb%2Fregistry%2Foh-package%2Fopenapi%2Fv1%2Fdetail%2Fsimple-native-ohos&query=%24.body.version)](https://ohpm.openharmony.cn/#/cn/detail/simple-native-ohos)

[Simple (支持中文和拼音的 SQLite fts5 全文搜索扩展)](https://github.com/wangfenjin/simple) 的 HarmonyOS NEXT 原生库。

```shell
ohpm install simple-native-ohos
```

将 [`resolveLibSimplePath()`](src/main/ets/lib.ets) 的返回值作为 [@ohos.data.relationalStore (关系型数据库)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-data-relationalstore) 中 [`StoreConfig.pluginLibs`](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-data-relationalstore-i#pluginlibs%E7%9A%84%E4%BD%BF%E7%94%A8%E7%BA%A6%E6%9D%9F%E5%92%8C%E7%A4%BA%E4%BE%8B) 配置项传入即可使用本扩展，具体示例见 [`LibSimple.test.ets`](src/ohosTest/ets/test/LibSimple.test.ets) 。

若要使用结巴分词 `jieba_query()`，参考 [`LibSimple.test.ets`](src/ohosTest/ets/test/LibSimple.test.ets) 的 `testJiebaQuery()`。这个示例根据 [Simple](https://github.com/wangfenjin/simple) 的说明和 [`sqlite_simple` 的实现](https://github.com/SageMik/sqlite3_simple/blob/main/lib/src/sqlite3_simple.dart)，读写 [`cppjieba` 字典文件](https://github.com/yanyiwu/cppjieba/tree/master/dict) 并调用 `jieba_dict()` 指定字典路径，从而成功启用结巴分词。

使用结巴分词时，建议正式查询前执行一次 `SELECT jieba_query()` ，避免后续加载等待。