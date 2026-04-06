// ignore_for_file: experimental_member_use

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple/src/jieba_dict.dart';
import 'package:web/web.dart';

import 'bridge_callbacks_default.dart';

/// 用于支持 Simple 扩展在 Web 上正常运行的默认加载器实现，主要职责如下：
/// 1. 在 `WebAssembly.instantiateStreaming(source, importObject)` 模块实例化时，将所需的宿主侧能力通过 `importObject` 提供给模块用于运行期调用。
/// 2. 在模块实例化后，将模块导出的线性内存交由宿主侧，以供文件读写。
final class DefaultSimpleWasmModuleLoader extends WasmModuleLoader {
  DefaultSimpleWasmModuleLoader._(this._callbacks);

  final DefaultSimpleBridgeCallbacks _callbacks;

  /// 创建用于支持 `Simple` 扩展在 Web 上正常运行的默认加载器。
  ///
  /// 传入「路径 → 字节」的映射 [files] 以供 Wasm 模块进行文件读写。
  /// 例如，如果自定义了 Simple 的拼音文件 `select pinyin_dict('/path/to/pinyin.txt')` ，则需要传入 `{ "/path/to/pinyin.txt": 拼音文件字节内容 }` 供扩展使用。
  ///
  /// 如需使用结巴分词，传入非空 [jiebaDictBundle] 以提供结巴分词字典文件，默认为 `null` 不提供字典文件以降低内存占用。
  static Future<DefaultSimpleWasmModuleLoader> create({
    Map<String, Uint8List> files = const {},
    JiebaDictBundle? jiebaDictBundle,
  }) async {
    return DefaultSimpleWasmModuleLoader._(
      DefaultSimpleBridgeCallbacks(await _merge(files, jiebaDictBundle)),
    );
  }

  /// 需要更新 Wasm 模块读写的文件时调用此函数。
  ///
  /// 例如，在运行时调用 `select pinyin_dict('/path/to/new_pinyin.txt')` 更新了 Simple 的拼音文件，需要向 [files] 传入 `{ "/path/to/new_pinyin.txt": 拼音文件字节内容 }`，[jiebaDictBundle] 同理。
  Future<void> updateFiles({
    required Map<String, Uint8List> files,
    required JiebaDictBundle? jiebaDictBundle,
  }) async {
    _callbacks.updateFiles(await _merge(files, jiebaDictBundle));
  }

  static Future<Map<String, Uint8List>> _merge(
    Map<String, Uint8List> files,
    JiebaDictBundle? jiebaDictBundle,
  ) async {
    final jiebaFiles = await jiebaDictBundle?.resolvePath2Bytes();
    return {...files, if (jiebaFiles != null) ...jiebaFiles};
  }

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
