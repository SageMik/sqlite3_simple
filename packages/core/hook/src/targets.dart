import 'package:code_assets/code_assets.dart';

enum SimpleTargetOS {
  android(OS.android),
  ios(OS.iOS),
  iosSimulator(OS.iOS, name: 'ios_sim', fat: true),
  linux(OS.linux),
  macos(OS.macOS, fat: true),
  windows(OS.windows);

  const SimpleTargetOS(this.hookOS, {String? name, this.fat = false})
    : _name = name;

  final OS hookOS;

  final String? _name;

  /// 是否以合并多架构的 fat 产物分发（发布包中使用无架构段的文件名）
  final bool fat;

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

const Map<SimpleTargetOS, Set<Architecture>> supportedArchitectures = {
  SimpleTargetOS.android: {
    Architecture.arm,
    Architecture.arm64,
    Architecture.x64,
  },
  SimpleTargetOS.ios: {Architecture.arm64},
  SimpleTargetOS.iosSimulator: {Architecture.arm64, Architecture.x64},
  SimpleTargetOS.linux: {Architecture.arm64, Architecture.x64},
  SimpleTargetOS.macos: {Architecture.arm64, Architecture.x64},
  SimpleTargetOS.windows: {Architecture.x64},
};

bool isSupported(SimpleTargetOS os, Architecture arch) {
  return supportedArchitectures[os]?.contains(arch) ?? false;
}
