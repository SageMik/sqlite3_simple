# simple-native

[![simple-native](https://img.shields.io/github/actions/workflow/status/SageMik/sqlite3_simple/simple.yml?branch=simple-native&label=simple-native)](https://github.com/SageMik/sqlite3_simple/tree/simple-native)

该分支编译和维护用于主分支的 Simple 原生库。

通过 Github Actions 进行持续集成（CI），详见 [`.github/workflow/simple.yml`](.github/workflows/simple.yml) 。

| 平台              | 持续集成                                                                                                          | 架构                                      | 备注                        |
| ----------------- | ----------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | --------------------------- |
| **Android** | 无，通过 Gradle mavenCentral() 导入：<br />[simple-native-android](https://github.com/SageMik/simple-native-android) | armeabi-v7a, arm64-v8a,<br />x86, x86_64 | Flutter Android 不支持 x86 |
| **iOS**     | 待集成，手动编译产物在主分支                                                                                      | x86_64, arm64 (模拟器)                    |                             |
| **Windows** | simple.dll                                                                                                        | x64                                       | Flutter Windows 仅支持 x64 |
| **MacOS**   | libsimple.dylib                                                                                                   | x86_64, arm64                             |                             |
| **Linux**   | 待定                                                                                                              |                                           |                             |
| **Web**     | 待定                                                                                                              |                                           |                             |
