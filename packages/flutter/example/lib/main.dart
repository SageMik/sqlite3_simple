import 'dart:async';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_app_bar.dart';
import 'main_panel_search.dart';
import 'utils/font/font_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFontLoader.instance.loadFirstScreen();
  runApp(
    ProviderScope(
      retry: (retryCount, error) =>
          ProviderContainer.defaultRetry(retryCount, error, maxRetries: 0),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _theme,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: _supportedLocales,
        home: Scaffold(
          appBar: AppBar(),
          body: const SafeArea(child: SearchPanel()),
        ),
      ),
    ),
  );
  unawaited(AppFontLoader.instance.loadFull());
}

/// 通过国际化设置中文环境以让 Flutter 使用正确的中文字体，主要是 Windows 平台
const _localizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
const _supportedLocales = [Locale('zh', 'CN')];

ThemeData get _theme {
  const accent = Color(0xFF635BFF);
  const canvas = Color(0xFFF4F5F7);
  const surface = Colors.white;
  const surfaceElevated = Color(0xFFEDEEF2);
  const ink = Color(0xFF17171A);
  const mute = Color(0xFF6E6E73);
  final colorScheme = ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light)
      .copyWith(
        primary: accent,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: mute,
        surfaceContainerLow: canvas,
        surfaceContainerHighest: surfaceElevated,
      );
  return ThemeData(
    /// 自定义中文字体，避免 Flutter 默认加载字体的方式导致短时间的乱码
    fontFamily: HarmonyOsSansSC,
    colorScheme: colorScheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
    ),
    focusColor: accent.withValues(alpha: .10),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      strokeWidth: 2.5,
      strokeCap: StrokeCap.round,
      color: accent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(4)),
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: surface),
  );
}
