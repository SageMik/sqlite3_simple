# sqlite3_simple_core 示例

一个示例跑两端：native（FFI + native assets）与 web（WASM）共享同一份查询逻辑
（`lib/demo_db.dart`），UI 各自实现——

- `bin/example.dart`：终端交互，命中片段以 ANSI 反色高亮；
- `web/main.dart`：浏览器页面，命中片段渲染为 `<mark>`。

## 运行

native（首次运行会经 build hook 从 `libsimple.dart.zip` 准备原生扩展）：

```sh
dart run
```

web（编译 JS 并起本地静态服务）：

```sh
dart run tool/serve.dart
```

## 结构

| 路径 | 说明 |
| --- | --- |
| `lib/demo_db.dart` | 共享层：示例数据、建表灌数据、`simple_query` / `simple_highlight` 查询封装（基于 `package:sqlite3/common.dart`） |
| `bin/example.dart` | native 入口：`sqlite3.loadSimpleExtension()` + 终端 REPL |
| `web/main.dart` | web 入口：`WasmSqlite3.loadFromUrl` + `DefaultSimpleWasmModuleLoader` + DOM 渲染 |
| `web/sqlite3.wasm` | 内置 Simple 分词器的 sqlite3.wasm |
| `tool/serve.dart` | 开发脚本：`dart compile js` + 本地静态服务 |

如需结巴分词等更多能力，参见包根 README。
