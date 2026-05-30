// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:sqlite3/wasm.dart';
import 'package:web/web.dart';

import '../common/jieba_dict_type.dart';
import 'bridge_callbacks_default.dart';

/// 用于支持 Simple 扩展在 Web 上正常运行的默认加载器实现，主要职责如下：
/// 1. 在 `WebAssembly.instantiateStreaming(source, importObject)` 模块实例化时，将所需的宿主侧能力通过 `importObject` 提供给模块用于运行期调用。
/// 2. 在模块实例化后，将模块导出的线性内存交由宿主侧，以供文件读写。
final class DefaultSimpleWasmModuleLoader extends WasmModuleLoader {
  late final DefaultSimpleBridgeCallbacks _callbacks;
  Map<String, Uint8List> _files = {};

  /// 创建用于支持 `Simple` 扩展在 Web 上正常运行的默认加载器。
  ///
  /// 传入「路径 → 字节」的映射 [files] 以供 Wasm 模块进行文件读写。
  /// 例如，如果自定义了 Simple 的拼音文件 `select pinyin_dict('/path/to/pinyin.txt')` ，则需要传入 `{ "/path/to/pinyin.txt": 拼音文件字节内容 }` 供扩展使用。
  ///
  /// 如需使用结巴分词，需要提供 [JiebaDictType] 中所有结巴分词字典文件的 [Uint8List] 。可以通过 [JiebaDictAssets.loadPaths] 获取内置字典路径，然后在 Web Worker 中通过 `fetch` 函数进行读取。
  DefaultSimpleWasmModuleLoader({Map<String, Uint8List> files = const {}}) {
    _files.addAll(files);
    _callbacks = DefaultSimpleBridgeCallbacks(_files);
  }

  /// 更新 Wasm 模块读写的文件。
  ///
  /// 例如，在运行时调用 `select pinyin_dict('/path/to/new_pinyin.txt')` 更新了 Simple 的拼音文件：
  /// ```
  /// loader.updateFiles((it) {
  ///   return it..remove('/path/to/old_pinyin.txt')..addAll({ "/path/to/new_pinyin.txt": 拼音文件字节内容 });
  /// })
  /// ```
  void updateFiles(
      Map<String, Uint8List> Function(Map<String, Uint8List> files) apply,
  ) {
    _files = apply(_files);
    _callbacks.updateFiles(_files);
  }

  /// 获取当前可供 Wasm 模块读取的路径及其字节内容
  Map<String, Uint8List> get files => Map.unmodifiable(_files);

  @override
  JSObject createImportObject() {
    return super.createImportObject()
      ..["wasi_snapshot_preview1"] = createJSInteropWrapper(_callbacks);
  }

  @override
  Future<WebAssemblyInstantiatedSource> instantiateModule(
    Response response,
  ) async {
    final source = await super.instantiateModule(response);
    final memory = source.instance.exports["memory"] as Memory;
    _callbacks.bindLinearMemory(memory);
    return source;
  }
}
