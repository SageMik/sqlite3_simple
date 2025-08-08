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
