# simple-native

[![Build](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&style=for-the-badge&logo=github)](https://github.com/SageMik/sqlite3_simple/actions)
[![simple-native-android](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=simple-native-android&style=for-the-badge&logo=android&logoColor=white)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)
[![simple-native-ohos](https://img.shields.io/badge/dynamic/json?label=simple-native-ohos&style=for-the-badge&logo=harmonyos&url=https%3A%2F%2Fohpm.openharmony.cn%2Fohpmweb%2Fregistry%2Foh-package%2Fopenapi%2Fv1%2Fdetail%2Fsimple-native-ohos&query=%24.body.version&prefix=v)](https://ohpm.openharmony.cn/#/cn/detail/simple-native-ohos)

该分支编译和维护用于主分支的 Simple 原生库。

标签 `NvX.Y.Z`。自 `Nv2.0.0` 开始，本分支所用拼音文件替换为 [`zdic.txt`](zdic.txt) ，以解决原拼音文件存在大量不常用读音的问题。

通过 Github Actions 进行持续集成（CI），详见 [`.github/workflow/simple.yml`](.github/workflows/simple.yml) 。


| 平台               | 持续集成                                                                                                      | 架构                                | 备注                                  |
| ------------------ | ------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ------------------------------------- |
| **Android**        | [src/android](src/android)                                                                                    | armeabi-v7a, arm64-v8a, x86, x86_64 | Flutter Android 不支持 x86            |
| **iOS**            | [`libsimple.a`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple.a)                     | arm64                               |                                       |
| **iOS 模拟器**     | [`libsimple-simulator.a`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple-simulator.a) | arm64, x86_64                       | arm64 为 Apple Silicon M 系列芯片架构 |
| **HarmonyOS NEXT** | [src/ohos](src/ohos)                                                                                          | arm64-v8a, x86_64                   |                                       |
| **Windows**        | [`simple.dll`](https://github.com/SageMik/sqlite3_simple/blob/master/windows/simple.dll)                      | x64                                 | Flutter Windows 仅支持 x64            |
| **MacOS**          | [`libsimple.dylib`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple.dylib)             | arm64, x86_64                       | arm64 为 Apple Silicon M 系列芯片架构 |
| **Linux**          | [CMakeLists.txt](https://github.com/SageMik/sqlite3_simple/blob/master/linux/CMakeLists.txt)                  |                                     |                                       |
