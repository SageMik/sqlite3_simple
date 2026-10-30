import 'package:code_assets/code_assets.dart';

enum SimpleTargetOS {
  android(OS.android),
  ios(OS.iOS),
  iosSimulator(OS.iOS, name: 'ios_sim'),
  linux(OS.linux),
  macos(OS.macOS),
  windows(OS.windows);

  const SimpleTargetOS(this.hookOS, {String? name}) : _name = name;

  final OS hookOS;

  final String? _name;

  /// 产物文件名中使用的操作系统标识
  String get name => _name ?? hookOS.name;

  static SimpleTargetOS? forConfig(CodeConfig config) {
    return switch (config.targetOS) {
      OS.android => android,
      OS.iOS when config.iOS.targetSdk == IOSSdk.iPhoneOS => ios,
      OS.iOS when config.iOS.targetSdk == IOSSdk.iPhoneSimulator =>
        iosSimulator,
      OS.linux => linux,
      OS.macOS => macos,
      OS.windows => windows,
      _ => null,
    };
  }
}
