// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

import 'bridge_callbacks_default.dart';
import 'loader_default.dart';

/// 宿主侧对 `wasm_snapshot_preview1` 导入模块的部分实现（与 [DartBridgeCallbacks](https://github.com/simolus3/sqlite3.dart/blob/e008b3295673955d4d83bd3bc2c99f22d9e6015c/sqlite3/lib/src/wasm/injected_values.dart#L18) 相似），Simple 扩展需要依赖这些实现才能在 Web 上正常运行。
///
/// 若需要自定义实现，重写这些方法并标记为 [JSExport]，再通过加载器挂载到 `wasi_snapshot_preview1` 上，具体可参考 [DefaultSimpleBridgeCallbacks] 和 [DefaultSimpleWasmModuleLoader]。
abstract class SimpleBridgeCallbacks {
  int environ_get(int environPtr, int environBufPtr);

  int environ_sizes_get(int environCountPtr, int environBufSizePtr);

  int clock_time_get(int clockId, Object? precision, int timePtr);

  int fd_close(int fd);

  int fd_fdstat_get(int fd, int fdstatPtr);

  int fd_fdstat_set_flags(int fd, int flags);

  int fd_prestat_get(int fd, int prestatPtr);

  int fd_prestat_dir_name(int fd, int pathPtr, int pathLen);

  int fd_read(int fd, int iovs, int iovsLen, int nreadPtr);

  int fd_seek(int fd, Object? offset, int whence, int newOffsetPtr);

  int fd_write(int fd, int iovs, int iovsLen, int nwrittenPtr);

  int path_open(
    int fd,
    int dirflags,
    int pathPtr,
    int pathLen,
    int oflags,
    Object? rightsBase,
    Object? rightsInheriting,
    int fdflags,
    int openedFdPtr,
  );

  void proc_exit(int code);
}
