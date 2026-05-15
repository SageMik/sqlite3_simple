## 2.2.0

- **[新增]** Web 平台支持。
- **[优化]** 增加 `SELECT pinyin_dict()` 切换拼音文件示例，优化示例代码。

## 2.1.0

- **[ 原生库版本 ]** 更新至 [simple v0.7.1](https://github.com/wangfenjin/simple/releases/tag/v0.7.1) 。`Nv1.0.6` 基于当时原生库的最新提交进行构建，以修复 [结巴分词搜索 `C#` 出错](https://github.com/wangfenjin/simple/issues/176) 的问题，但 `Nv2.0.0` 又将版本降回至 [v0.5.2](https://github.com/wangfenjin/simple/releases/tag/v0.5.2) 导致问题复现，现重新升级以解决此问题。
- **[修复]** 修复示例程序高亮文本相比原文本有宽高上有微小变化的问题，正确替换零宽字符（[#20](https://github.com/SageMik/sqlite3_simple/issues/20)）。
- **[修复]** 修复错误依赖 `package:archive` 的问题，该依赖只用于开发时下载原生库（[#22](https://github.com/SageMik/sqlite3_simple/issues/22)）。

## 2.0.0

* 迁移至 sqlite3: ^3.0.0 即 v3 版本，使用 Dart Hooks 构建 SQLite 原生库。
* 更新 Simple 原生库至 [v0.5.2](https://github.com/wangfenjin/simple/tree/v0.5.0) 。自当前版本即 `2.0.0` 起，本库所用拼音文件替换为 [`zdic.txt`](https://github.com/SageMik/sqlite3_simple/blob/simple-native/zdic.txt) ，以解决原拼音文件存在大量不常用读音的问题（例如输入q，会匹配到 `示(U+793A, qí)`、`客(U+5BA2, qià)` 等）

## 1.0.7

* 增加 [drift](https://github.com/simolus3/drift) 示例 (#13)
* 更换 AssetManifest API (#14)

## 1.0.6

* 增加 [sqflite_common_ffi](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi) 示例 (#7) 。
* 更新 Simple 原生库至 [最新提交](https://github.com/wangfenjin/simple/tree/2d950e132028fcdb5718e78a79dd9d5213f13c73)，修复结巴分词搜索 `C#` 错误。
* 清理鸿蒙适配代码。

## 1.0.5

* 更新 Simple 原生库至 [v0.5.0](https://github.com/wangfenjin/simple/tree/v0.5.0) 。
* 由于 [sqlite-ohos.dart](https://github.com/SageMik/sqlite3-ohos.dart) 崩溃问题，暂时停止 HarmonyOS NEXT 适配，删除相关说明。

## 1.0.4

* 新增 HarmonyOS 和 Linux 支持。
* 通过 [`sharedDarwinSource`](https://docs.flutter.cn/packages-and-plugins/developing-packages#shared-ios-and-macos-implementations) 共享 iOS 和 MacOS 实现。

## 1.0.3

* 新增 `overrideOpen` 参数，允许用户自行加载 Simple 原生库。
* 更新 Simple 原生库至 [最新提交](https://github.com/wangfenjin/simple/tree/632fd7ba710ff54b8c6de1220bb47253132b94e5) 。
* 更新 `sqlite3` 至 `2.4.7` 。

## 1.0.2

* 更新 iOS 编译工具链。
* 补充 M芯片 iOS 模拟器 支持 (#3) 。
* 修复最新版本 Android Studio Ladybug | 2024.2.1 Patch 2 (JDK 21) 无法运行 Android 示例的问题 (#4)。

## 1.0.1

* 新增 Windows、MacOS 支持。

## 1.0.0

* 首次提交，实现 Android 和 iOS 适配。
