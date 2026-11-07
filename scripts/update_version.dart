import 'dart:io';

final projectRoot = File.fromUri(Platform.script).parent.parent.path;

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('用法：dart update_version.dart <core 版本> <flutter 版本>');
    exitCode = 64;
    return;
  }

  final coreVersion = args[0];
  final flutterVersion = args[1];

  final changes = <VersionChange>[
    VersionChange(
      path: '$projectRoot/packages/core/pubspec.yaml',
      pattern: RegExp(r'^version:.*$', multiLine: true),
      replacement: 'version: $coreVersion',
    ),
    VersionChange(
      path: '$projectRoot/packages/flutter/pubspec.yaml',
      pattern: RegExp(r'^version:.*$', multiLine: true),
      replacement: 'version: $flutterVersion',
    ),
    VersionChange(
      path: '$projectRoot/packages/flutter/pubspec.yaml',
      pattern: RegExp(r'sqlite3_simple_core:\s*\^?\d+\.\d+\.\d+'),
      replacement: 'sqlite3_simple_core: ^$coreVersion',
    ),
    VersionChange(
      path: '$projectRoot/packages/flutter/README.md',
      pattern: RegExp(r'releases/download/[^/]+/example\.apk'),
      replacement: 'releases/download/v$flutterVersion/example.apk',
    ),
  ];

  var failed = false;
  for (final change in changes) {
    final file = File(change.path);
    if (!file.existsSync()) {
      stderr.writeln('未更新：${change.path} 不存在');
      failed = true;
      continue;
    }

    final content = file.readAsStringSync();
    if (!change.pattern.hasMatch(content)) {
      stderr.writeln('未更新：${change.path} 中没匹配到版本号，请手工确认');
      failed = true;
      continue;
    }

    file.writeAsStringSync(
      content.replaceFirst(change.pattern, change.replacement),
    );
    stdout.writeln('已更新：${change.path}');
  }

  if (failed) exitCode = 1;
}

class VersionChange {
  final String path;
  final RegExp pattern;
  final String replacement;

  VersionChange({
    required this.path,
    required this.pattern,
    required this.replacement,
  });
}
