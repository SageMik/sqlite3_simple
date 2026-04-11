// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:wasd/wasd.dart' as wasd;
import 'package:web/web.dart';

import 'bridge_callbacks.dart';

/// [SimpleBridgeCallbacks] 的默认实现，基于 [wasd.WASI] 。
final class DefaultSimpleBridgeCallbacks extends SimpleBridgeCallbacks {
  /// 创建 [SimpleBridgeCallbacks] 的默认实现。
  ///
  /// 传入「路径 → 字节」的映射 [files] 以供 Wasm 模块进行文件读写。
  DefaultSimpleBridgeCallbacks(Map<String, Uint8List> files)
    : _wasi = wasd.WASI(preopens: const {'.': '.'}, files: files);

  /// 将 Wasm 模块导出的线性内存交由宿主，供内部 [_wasi] 进行文件读写，一般在 [WebAssembly.instantiateStreaming] 模块实例化后调用。
  void bindLinearMemory(Memory memory) {
    _memory = memory;
    _wasi.finalizeBindings(
      _EmptyInstance.instance,
      memory: _MemoryFromJsToWasd(memory),
    );
  }

  /// 需要更新文件时调用此函数以进行全量更新。例如在运行时调用 `select pinyin_dict('/path/to/new_pinyin.txt')` 更新了 Simple 的拼音文件，需要向 [files] 传入 `{ "/path/to/new_pinyin.txt": 拼音文件字节内容 }` 。
  void updateFiles(Map<String, Uint8List> files) {
    _wasi = wasd.WASI(preopens: const {'.': '.'}, files: files);
    bindLinearMemory(_memory);
  }

  /// 与 [errnoNosys](https://github.com/medz/wasd/blob/7e80c132c466b86409ce5bd110ad5b719d16b715/lib/src/wasi/preview1/common/constants.dart#L7) 保持一致。
  static const int _kWasiErrnoNosys = 52;

  late Memory _memory;

  wasd.WASI _wasi;

  int _call(String name, List<Object?> args) {
    final func = _wasi.imports['wasi_snapshot_preview1']![name];
    if (func is! wasd.FunctionImportExportValue) {
      return _kWasiErrnoNosys;
    }
    var result = func.ref(args);
    return switch (result) {
      null => 0,
      final int i => i,
      final BigInt b => b.toInt(),
      final num n => n.toInt(),
      _ => _kWasiErrnoNosys,
    };
  }

  @override
  @JSExport()
  int environ_get(int environPtr, int environBufPtr) =>
      _call('environ_get', [environPtr, environBufPtr]);

  @override
  @JSExport()
  int environ_sizes_get(int environCountPtr, int environBufSizePtr) =>
      _call('environ_sizes_get', [environCountPtr, environBufSizePtr]);

  @override
  @JSExport()
  int clock_time_get(int clockId, Object? precision, int timePtr) =>
      _call('clock_time_get', [clockId, precision, timePtr]);

  @override
  @JSExport()
  int fd_close(int fd) => _call('fd_close', [fd]);

  @override
  @JSExport()
  int fd_fdstat_get(int fd, int fdstatPtr) =>
      _call('fd_fdstat_get', [fd, fdstatPtr]);

  @override
  @JSExport()
  int fd_fdstat_set_flags(int fd, int flags) =>
      _call('fd_fdstat_set_flags', [fd, flags]);

  @override
  @JSExport()
  int fd_prestat_get(int fd, int prestatPtr) =>
      _call('fd_prestat_get', [fd, prestatPtr]);

  @override
  @JSExport()
  int fd_prestat_dir_name(int fd, int pathPtr, int pathLen) =>
      _call('fd_prestat_dir_name', [fd, pathPtr, pathLen]);

  @override
  @JSExport()
  int fd_read(int fd, int iovs, int iovsLen, int nreadPtr) =>
      _call('fd_read', [fd, iovs, iovsLen, nreadPtr]);

  @override
  @JSExport()
  int fd_seek(int fd, Object? offset, int whence, int newOffsetPtr) =>
      _call('fd_seek', [fd, offset, whence, newOffsetPtr]);

  @override
  @JSExport()
  int fd_write(int fd, int iovs, int iovsLen, int nwrittenPtr) =>
      _call('fd_write', [fd, iovs, iovsLen, nwrittenPtr]);

  @override
  @JSExport()
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
  ) => _call('path_open', [
    fd,
    dirflags,
    pathPtr,
    pathLen,
    oflags,
    rightsBase,
    rightsInheriting,
    fdflags,
    openedFdPtr,
  ]);

  @override
  @JSExport()
  void proc_exit(int code) => _call('proc_exit', [code]);
}

final class _EmptyInstance implements wasd.Instance {
  _EmptyInstance._();

  @override
  wasd.Exports get exports => wasd.Exports();

  static _EmptyInstance instance = _EmptyInstance._();
}

final class _MemoryFromJsToWasd implements wasd.Memory {
  _MemoryFromJsToWasd(this._jsMemory);

  final Memory _jsMemory;

  @override
  ByteBuffer get buffer => _jsMemory.buffer.toDart;

  @override
  int grow(int delta) => _jsMemory.grow(delta);
}
