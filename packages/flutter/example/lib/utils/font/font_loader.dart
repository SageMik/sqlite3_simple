// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'font_loader_io.dart'
    if (dart.library.html) 'font_loader_web.dart'
    show createFontLoader;

const String HarmonyOsSansSC = 'HarmonyOS Sans SC';

abstract class AppFontLoader {
  static AppFontLoader instance = createFontLoader();

  @protected
  Future<void> load(Future<ByteData> bytes) async {
    final loader = FontLoader(HarmonyOsSansSC)..addFont(bytes);
    await loader.load();
  }

  /// 加载首屏字体
  Future<void> loadFirstScreen();

  /// 加载完整字体，用于 Web ，非 Web 不做任何操作
  Future<void> loadFull();
}
