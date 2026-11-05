import 'package:code_assets/code_assets.dart';

final class SimpleTargetOS {
  const SimpleTargetOS._(this.hookOS, {String? name}) : _name = name;

  final OS hookOS;

  final String? _name;

  /// 产物文件名中使用的操作系统标识
  String get name => _name ?? hookOS.name;

  static const android = SimpleTargetOS._(OS.android);
  static const ios = SimpleTargetOS._(OS.iOS);
  static const iosSimulator = SimpleTargetOS._(OS.iOS, name: 'ios_sim');
  static const linux = SimpleTargetOS._(OS.linux);
  static const macos = SimpleTargetOS._(OS.macOS);
  static const windows = SimpleTargetOS._(OS.windows);

  /// 未在默认列表中的平台，产物文件名沿用 [OS.name]
  factory SimpleTargetOS.other(OS os) => SimpleTargetOS._(os);

  static SimpleTargetOS forConfig(CodeConfig config) {
    return switch (config.targetOS) {
      OS.android => android,
      OS.iOS when config.iOS.targetSdk == IOSSdk.iPhoneOS => ios,
      OS.iOS when config.iOS.targetSdk == IOSSdk.iPhoneSimulator => iosSimulator,
      OS.linux => linux,
      OS.macOS => macos,
      OS.windows => windows,
      final os => SimpleTargetOS.other(os),
    };
  }
}
