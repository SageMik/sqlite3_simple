# [Simple](https://github.com/wangfenjin/simple) WebAssembly 编译指南

本指南基于 Flutter 库 [`sqlite3`](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3) 编译内置 Simple 扩展的 `sqlite3.wasm`，在线演示：[Simple 分词器 示例](https://sagemik.github.io/sqlite3_simple) 。

由于 `sqlite3` [采用特定的编译方式](https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3#wasm-web-support)，**生成的 WASM 文件并不适用于 [`sql.js`](https://github.com/sql-js/sql.js) 等 Web 库**。不过，本指南阐述的原理仍具有一定的通用性，可以作为 Simple WebAssembly 编译的技术参考。

## 使用方法

确保 [`../../simple`](../../simple) 和 [`sqlite3.dart`](sqlite3.dart) 子模块已经检出：
```shell
git submodule update --init --recursive
```

安装 Dart/Flutter、CMake，并下载好 [`wasi-sdk`](https://github.com/WebAssembly/wasi-sdk) 和 [`binaryen`](https://github.com/WebAssembly/binaryen) 工具，执行如下命令，即可编译出**内置 Simple 扩展的 SQLite WASM 文件**：

```shell
dart run build_wasm.dart --wasi-sdk=[wasi-sdk 所在路径] --binaryen=[binaryen 所在路径]
```

编译产物会输出到 [`out`](out) 目录下，其中 `sqlite3.debug.wasm` 为调试版本，`sqlite3.wasm` 和 `sqlite3mc.wasm` (内置 [SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) 扩展) 则面向生产环境部署。

编译产物可通过 [`sqlite3_simple`](https://github.com/SageMik/sqlite3_simple/blob/main/doc/web.md) 集成到 Flutter Web 项目中，从而在浏览器上使用 Simple 分词功能。

## 基本原理

### SQLite WebAssembly

SQLite 是用 C 语言实现的嵌入式数据库，支持[编译成 WebAssembly (WASM) 加载到 Web 中运行](https://sqlite.org/wasm/doc/trunk/index.md)。然而，WASM 本质上只是一个纯计算沙箱，并不提供 SQLite 所需的文件读写、内存映射、路径操作等与操作系统交互的能力。因此，**这些能力必须由承载 WASM 的宿主环境提供**——Node.js 等运行时原生支持系统调用，浏览器则需要在 JavaScript/Dart 层主动补齐这些缺失的能力。

SQLite 早在 2007 年的 [3.5.0](https://www.sqlite.org/34to35.html) 版本就将操作系统相关的能力抽离为 VFS（Virtual File System，虚拟文件系统）抽象接口层。这一颇具前瞻性的设计不仅赋予了 SQLite 良好的跨平台可移植性，也为其在现代 WebAssembly 环境中的顺畅运行提供了便捷的实现路径。

`sqlite3` 为支持 SQLite 在 Web 上运行，主要完成了以下工作：

1. 在 C 语言侧增加了和 Dart 交互的胶水代码，负责 WASM 初始化引导、VFS 文件读写桥接等功能。
2. 在 Dart 宿主侧提供了 VFS 接口等功能的具体实现。
3. 通过 [`wasi-sdk`](https://github.com/WebAssembly/wasi-sdk) 将 SQLite 编译为 WASM 文件。

### Simple WebAssembly

在原生平台上，Simple 这类自定义扩展可以作为独立编译的原生库（ `.so` / `.dylib` / `.dll` ）由 SQLite [在运行时动态加载使用](https://sqlite.org/loadext.html)；但在 Web 平台上，SQLite [因 WASM 缺少可用的 `dlopen` 实现而无法使用该机制](https://sqlite.org/forum/forumpost/9273e6c9159502a1842287f4c20aec964a81c01057bdecf0e8137dd8b5c44dd1) 。因此目前只能将 Simple 以静态链接的方式集成到 SQLite 中，联合编译为单一 WASM 文件。

在 `sqlite3.dart` 目录下执行 `git apply ../sqlite3_wasm_build.patch` 应用 Patch ，可以看到为集成 Simple 扩展在 `sqlite3_wasm_build` 中所做的调整，具体而言：

| 操作 | 文件                      | 说明                                                                     |
| ---- | ------------------------- | ------------------------------------------------------------------------ |
| 新增 | `simple_wasm.cmake`       | 引入 Simple 源码、cppjiba 结巴分词依赖、cmrc 内嵌资源依赖                |
| 新增 | `cpp_exceptions_stubs.cc` | 提供 C++ 异常处理的桩函数                                                |
| 修改 | `CMakeLists.txt`          | 启用 C/C++ 分步编译 和 libc++ 链接，引入 `simple_wasm.cmake`         |
| 修改 | `os_web.c`                | 注册 `sqlite3_auto_extension` 自动初始化 Simple                          |
| 修改 | `sqlite_cfg.h`            | 取消 `SQLITE_OMIT_LOAD_EXTENSION` 宏，解除 SQLite 扩展加载接口的禁用限制 |

<details>
<summary><b> 💡 为何不启用 <code>wasi-sdk</code> 的 C++ 异常支持？</b></summary>

<br />

`wasi-sdk` 支持 [启用 C++ 异常处理](https://github.com/WebAssembly/wasi-sdk/blob/main/CppExceptions.md) ，会将 C++ 异常处理为新版异常类型 `exnref` 。该类型需要高版本浏览器内核支持（详见 WASM 3.0 发布说明的 [Exception handling 部分](https://webassembly.org/news/2025-09-17-wasm-3.0/) ），因此本项目还是通过 `cpp_exceptions_stubs.cc` 桩函数的方式确保兼容性。

</details>

### 提供操作系统交互能力

如前所述，涉及操作系统交互的能力需要由宿主侧提供。`sqlite3` 已为 SQLite 完成了这一工作，而引入的 Simple 扩展同样涉及文件读写等操作系统能力，因此也需要相同的处理。

不过，与 `sqlite3_wasm_build` 必须手写胶水代码桥接 VFS 等自定义接口不同的是，Simple 扩展使用标准 C/C++ 库的 IO 函数，`wasi-sdk` 能在编译时自动将其映射为 `wasi_snapshot_preview1` 模块的导入声明（`path_open`、`fd_read`、`fd_write` 等），因而无需手动编写胶水代码，只需要在宿主侧提供对应的实现即可。

按照 [使用方法](#使用方法) 编译后，在 [`out`](out) 目录下通过 `binaryen` 提供的工具执行反编译命令，即查看模块依赖的宿主侧实现：

```shell
wasm-dis sqlite3.wasm -o sqlite3.wat
```

```wasm
...

 (import "dart" "xClose" (func $fimport$1 (param externref) (result i32)))
 (import "dart" "xRead" (func $fimport$2 (param externref i32 i32 i64) (result i32)))

...

 (import "wasi_snapshot_preview1" "fd_read" (func $fimport$38 (param i32 i32 i32 i32) (result i32)))
 (import "wasi_snapshot_preview1" "fd_seek" (func $fimport$39 (param i32 i64 i32 i32) (result i32)))

```

`dart` 模块的导入声明源自 `sqlite3_wasm_build` 中 [`bridge.h`](sqlite3.dart/sqlite3_wasm_build/src/bridge.h) 的显式定义；`wasi_snapshot_preview1` 则是由 `wasi-sdk` 在编译时根据 Simple 所需自动生成的。这些导入要求在 WASM 模块实例化时 [`WebAssembly.instantiateStreaming(source, importObject)`](https://developer.mozilla.org/zh-CN/docs/WebAssembly/Reference/JavaScript_interface/instantiateStreaming_static) 将宿主侧能力通过 `importObject` 参数传入，传入格式类似于：

```json
{
  "dart": {
    "xClose": [宿主侧实现],
    "xRead": [宿主侧实现],
    ...
  },
  "wasi_snapshot_preview1": {
    "fd_read": [宿主侧实现],
    "fd_seek": [宿主侧实现],
    ...
  },
}
```

因此，任何能按此格式注入具体实现的宿主环境，都可以运行本项目的 SQLite WASM 文件，而不必局限于 Dart （实际上 Dart 的具体实现也是通过导出为 JavaScript 函数提供）。

SQLite 所需 `dart` 模块的宿主侧实现由 `sqlite3` 的 [`DartBridgeCallbacks`](https://github.com/simolus3/sqlite3.dart/blob/main/sqlite3/lib/src/wasm/injected_values.dart) 提供，而  Simple 额外所需的 `wasi_snapshot_preview1` 模块的宿主侧实现，则由 `sqlite3_simple` 的 [`DefaultSimpleBridgeCallbacks`](https://github.com/SageMik/sqlite3_simple/blob/main/lib/src/web/bridge_callbacks_default.dart) 提供。如 [使用方法](#使用方法) 所述，可以通过 [`sqlite3_simple`](https://github.com/SageMik/sqlite3_simple/blob/main/doc/web.md) 在 Flutter Web 上使用 Simple 扩展，具体使用细节可移步其说明文档，此处不再展开。