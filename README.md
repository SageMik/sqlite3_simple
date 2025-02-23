# simple-native

[![Build](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&style=for-the-badge&logo=github)](https://github.com/SageMik/sqlite3_simple/actions)
[![simple-native-ohos](https://img.shields.io/badge/v1.0.2-007ec6?label=simple-native-ohos&style=for-the-badge&logo=harmonyos)](https://ohpm.openharmony.cn/#/cn/detail/simple-native-ohos)
[![simple-native-android](https://img.shields.io/maven-central/v/io.github.sagemik/simple-native-android?label=simple-native-android&style=for-the-badge&logo=android&logoColor=white)](https://central.sonatype.com/artifact/io.github.sagemik/simple-native-android)

该分支编译和维护用于主分支的 Simple 原生库。

通过 Github Actions 进行持续集成（CI），详见 [`.github/workflow/simple.yml`](.github/workflows/simple.yml) 。

| 平台            | 持续集成                                                                                                          | 架构                                       | 备注                             |
|---------------|---------------------------------------------------------------------------------------------------------------|------------------------------------------|--------------------------------|
| **HarmonyOS** | [simple-native-ohos](https://github.com/SageMik/simple-ohos/tree/main/simple_native_ohos)                     | arm64-v8a, x86_64                        |                                |
| **Android**   | [simple-native-android](https://github.com/SageMik/simple-native-android)                                     | armeabi-v7a, arm64-v8a,<br />x86, x86_64 | Flutter Android 不支持 x86        |
| **iOS**       | [`libsimple.a`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple.a)                     | arm64                                    |                                |
| **iOS 模拟器**   | [`libsimple-simulator.a`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple-simulator.a) | arm64, x86_64                            | arm64 为 Apple Silicon M 系列芯片架构 |
| **Windows**   | [`simple.dll`](https://github.com/SageMik/sqlite3_simple/blob/master/windows/simple.dll)                      | x64                                      | Flutter Windows 仅支持 x64        |
| **MacOS**     | [`libsimple.dylib`](https://github.com/SageMik/sqlite3_simple/blob/master/darwin/libsimple.dylib)             | arm64, x86_64                            | arm64 为 Apple Silicon M 系列芯片架构 |
| **Linux**     | [CMakeLists.txt](https://github.com/SageMik/sqlite3_simple/blob/master/linux/CMakeLists.txt)                  |                                          |                                |

## GIT TAG
1. `NvX.Y.Z` 表示对应 `sqlite_simple: X.Y.Z` 版本所使用的原生库 。
2. `NvX.Y.Z` 中的子模块总是滞后一个版本，故 `NvX.Y.Zx` 专门用于更新子模块到使用对应 `NvX.Y.Z` 原生库的版本。