## 2.0.0+1

- 将替换拼音文件的操作由 GitHub Actions 迁移至最外层 CMakeLists.txt ，以便直接引用 CMakeLists.txt 的项目也使用替换的拼音文件，更新测试用例以验证替换生效

## 2.0.0

- 更换字典文件为 [`zdic.txt`](https://github.com/SageMik/sqlite3_simple/blob/Nv2.0.0/zdic.txt)，原拼音文件包含大量非常用读音。
- 增加 [resolveLibSimplePath()]，提供 Simple 原生库路径。

## 1.0.3

- [修改编译选项，静态链接 `libc++_static.a`](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/build-with-ndk-overview-V5) ，使之成功通过 [@ohos.data.relationalStore (关系型数据库)](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-data-relationalstore-V5#storeconfig)
加载到数据库中使用。
- 更新原生库，与 [`simple-native-android`](https://github.com/SageMik/simple-native-android/tree/v1.0.3) 保持同步。

## 1.0.2

- 首次提交，与 [`simple-native-android`](https://github.com/SageMik/simple-native-android/tree/v1.0.2) 保持同步。