# simple-native

该分支用于编译和维护不含 SQLite 的 Simple 原生库，以供主分支使用。

通过 Github Actions 进行持续集成（CI），详见 [`.github/workflow/simple.yaml`](.github/workflows/simple.yml) 。

| 平台              | 持续集成                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Android** | 否，通过 Gradle & CMake 编译：[simple-android-native](https://github.com/SageMik/simple-android-native)，<br />Android 项目可从 Maven Central 引入 |
| **iOS**     | 待集成，手动编译产物在主分支                                                                                                                     |
| **Windows** | ✔                                                                                                                                               |
| **MacOS**   | 待集成                                                                                                                                           |
| **Linux**   | 待定                                                                                                                                             |
| **Web**     | 待定                                                                                                                                             |
