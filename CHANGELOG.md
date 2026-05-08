## 2.1.0

- **[ 原生库版本 ]** 更新至 [simple v0.7.1](https://github.com/wangfenjin/simple/releases/tag/v0.7.1) 。`Nv1.0.6` 基于当时原生库的最新提交进行构建，以修复 [结巴分词搜索 `C#` 出错](https://github.com/wangfenjin/simple/issues/176) 的问题，但 `Nv2.0.0` 又将版本降回至 [v0.5.2](https://github.com/wangfenjin/simple/releases/tag/v0.5.2) 导致问题复现，现重新升级以解决此问题。

## 2.0.0+1

- **[ 优化 ]** 将替换拼音文件的操作由 GitHub Actions 迁移至 CMakeLists.txt ，以便直接引用 CMakeLists.txt 的项目也使用替换的拼音文件，更新测试用例以验证替换生效。

## 2.0.0

- **[ 原生库版本 ]** 更新至 [simple v0.5.2](https://github.com/wangfenjin/simple/releases/tag/v0.5.2) 。
- **[ 优化 ]** 从当前版本即 `v2.0.0` 开始，本库所用拼音文件替换为 [`zdic.txt`](zdic.txt) ，以解决原拼音文件存在大量不常用读音的问题（例如输入q，会匹配到 `示(U+793A, qí)`、`客(U+5BA2, qià)` 等）。
- **[ 优化 ]** 将 `simple-native-android` 和 `simple-native-ohos` 迁移至此，增加测试代码，增加自动打包和发布流水线。