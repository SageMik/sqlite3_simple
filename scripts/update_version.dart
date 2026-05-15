import 'dart:io';

const projectRoot = '..';
const toVersion = '2.2.0';

void main() {
  final changes = <VersionChange>[
    VersionChange(
      path: '$projectRoot/pubspec.yaml',
      pattern: RegExp(r'^version:\s+\d+\.\d+\.\d+', multiLine: true),
      replacement: 'version: $toVersion',
    ),
    VersionChange(
      path: '$projectRoot/android/build.gradle',
      pattern: RegExp(r'^version\s*=\s*"\d+\.\d+\.\d+"', multiLine: true),
      replacement: 'version = "$toVersion"',
    ),
    VersionChange(
      path: '$projectRoot/darwin/sqlite3_simple.podspec',
      pattern: RegExp(r"^\s*s\.version\s*=\s*'\d+\.\d+\.\d+'", multiLine: true),
      replacement: "  s.version          = '$toVersion'",
    ),
    VersionChange(
      path: '$projectRoot/README.md',
      pattern: RegExp(r'releases/download/v\d+\.\d+\.\d+/example\.apk'),
      replacement: 'releases/download/v$toVersion/example.apk',
    ),
  ];

  for (final change in changes) {
    final file = File(change.path);
    if (!file.existsSync()) continue;

    final content = file.readAsStringSync();
    final match = change.pattern.firstMatch(content);
    if (match == null) continue;

    file.writeAsStringSync(content.replaceFirst(change.pattern, change.replacement));
  }
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
