// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive.dart';

const version = "2.1.0";

void main(List<String> args) async {
  const r = "../";
  final localZipPath = args.isNotEmpty ? args.first : null;

  final file2versionUpdated = {
    File('$r/android/build.gradle'): (
      RegExp(r'simple-native-android:[^"]+'),
      'simple-native-android:$version',
    ),
    File('$r/linux/CMakeLists.txt'): (
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
    'windows/simple.dll': File('$r/windows/simple.dll'),
    'macos/libsimple.dylib': File('$r/darwin/libsimple.dylib'),
    'ios/libsimple.a': File('$r/darwin/libsimple.a'),
    'ios/libsimple-simulator.a': File('$r/darwin/libsimple-simulator.a'),
  };
  final client = HttpClient()..findProxy = HttpClient.findProxyFromEnvironment;
  try {
    final bytes = <int>[];
    if (localZipPath != null) {
      final localZip = File(localZipPath);
      if (!await localZip.exists()) {
        throw Exception("本地文件不存在：$localZipPath");
      }
      print("使用本地文件：$localZipPath");
      bytes.addAll(await localZip.readAsBytes());
    } else {
      print("开始下载 Simple 原生库：$releaseUrl");
      final request = await client.getUrl(releaseUrl);
      final response = await request.close();
      if (response.statusCode == 200) {
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
      } else {
        throw Exception("响应状态码错误：${response.statusCode}");
      }
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
    print("更新完成");
  } catch (e) {
    print("更新失败：$e");
  } finally {
    client.close();
  }
}
