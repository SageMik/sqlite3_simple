# simple-native

[![simple-native](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&label=simple-native)](https://github.com/SageMik/sqlite3_simple/actions/workflows/simple.yml)

该分支编译和维护用于主分支的 Simple 原生库。

通过 Github Actions 进行持续集成（CI），详见 [`.github/workflow/simple.yml`](.github/workflows/simple.yml) 。


| 平台            | 持续集成                                                                                             | 架构                                       | 备注                             |
|---------------|--------------------------------------------------------------------------------------------------|------------------------------------------|--------------------------------|
| **HarmonyOS** | [simple-native-ohos](https://github.com/SageMik/simple-native-ohos/tree/main/simple_native_ohos) | arm64-v8a, x86_64                        |                                |
| **Android**   | [simple-native-android](https://github.com/SageMik/simple-native-android)                        | armeabi-v7a, arm64-v8a,<br />x86, x86_64 | Flutter Android 不支持 x86        |
| **iOS**       | `libsimple.a`                                                                                    | arm64                                    |                                |
| **iOS 模拟器**   | `libsimple-simulator.a`                                                                          | arm64, x86_64                            | arm64 为 Apple Silicon M 系列芯片架构 |
| **Windows**   | `simple.dll`                                                                                     | x64                                      | Flutter Windows 仅支持 x64        |
| **MacOS**     | `libsimple.dylib`                                                                                | arm64, x86_64                            | arm64 为 Apple Silicon M 系列芯片架构 |
| **Linux**     | [CMakeLists.txt](https://github.com/SageMik/sqlite3_simple/blob/master/linux/CMakeLists.txt)     |                                          |                                |
