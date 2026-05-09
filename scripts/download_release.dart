// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive.dart';

const version = "2.0.0+1";

void main() async {
  Directory.current = File(Platform.script.toFilePath()).parent.parent.path;

  final file2versionUpdated = {
    File('android/build.gradle'): (
      RegExp(r'simple-native-android:[^"]+'),
      'simple-native-android:$version',
    ),
    File('linux/CMakeLists.txt'): (
      RegExp(r'GIT_TAG Nv.*'),
      'GIT_TAG Nv$version',
    ),
  };
  for (final entry in file2versionUpdated.entries) {
    final f = entry.key;
    await f.writeAsString(
      (await f.readAsString()).replaceFirst(entry.value.$1, entry.value.$2),
    );
  }

  final releaseUrl = Uri.parse(
    'https://github.com/SageMik/sqlite3_simple/releases/download/Nv$version/libsimple.zip',
  );
  print("开始下载 Simple 原生库：$releaseUrl");
  final remote2local = {
    'windows/simple.dll': File('windows/simple.dll'),
    'macos/libsimple.dylib': File('darwin/libsimple.dylib'),
    'ios/libsimple.a': File('darwin/libsimple.a'),
    'ios/libsimple-simulator.a': File('darwin/libsimple-simulator.a'),
  };
  final client = HttpClient()..findProxy = HttpClient.findProxyFromEnvironment;
  try {
    final request = await client.getUrl(releaseUrl);
    final response = await request.close();
    if (response.statusCode == 200) {
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (!file.isFile) {
          continue;
        }
        final localFile = remote2local[file.name.replaceAll('\\', '/')];
        if (localFile != null) {
          await localFile.parent.create(recursive: true);
          await localFile.writeAsBytes(file.content as List<int>);
        }
      }
    }
    print("更新完成");
  } catch (e) {
    print("更新失败：$e");
  } finally {
    client.close();
  }
}
