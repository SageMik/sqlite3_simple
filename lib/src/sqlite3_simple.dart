import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

extension Sqlite3SimpleEx on Sqlite3 {
  /// 加载Simple扩展，请在打开数据库前调用；
  /// 如果需要结巴分词功能，调用 [writeJiebaDict]
  void loadSimpleExtension() {
    // sqlite3库如何加载自定义扩展：
    // https://github.com/simolus3/sqlite3.dart/blob/a9a379494c6b8d58a3c31cf04fe16e83b49130f1/sqlite3/test/ffi/sqlite3_test.dart#L35
    final library = Platform.isAndroid
        ? DynamicLibrary.open("libsimple.so")
        : DynamicLibrary.process();
    sqlite3.ensureExtensionLoaded(
        SqliteExtension.inLibrary(library, "sqlite3_simple_init"));
  }

  /// 将结巴分词所需字典文件保存到指定目录，
  /// 返回用于修改结巴分词字典文件目录的SQL语句。
  /// 使用结巴分词功能务必调用该函数，并执行本方法返回的SQL语句
  Future<String> writeJiebaDict(String dir) async {
    const packageName = "packages/sqlite3_simple";
    const cppJiebaPath = "cpp_jieba_dict";

    // Flutter会将Assets里的字典打包，而CppJieba里通过文件路径读取字典，
    // ( https://github.com/wangfenjin/simple/blob/ffc78ec4d5ac962d889cb68ea3691e83a699fe2c/src/simple_tokenizer.cc#L65，
    //   https://github.com/yanyiwu/cppjieba/blob/391121d5db0f31dd5ce9795d4d34812f20eeb25c/include/cppjieba/DictTrie.hpp#L211 )
    // 故需将字典文件保存到本地，以供CppJieba读取

    final jsonString = await rootBundle.loadString("AssetManifest.json");
    final pathList = Map<String, dynamic>.from(json.decode(jsonString))
        .keys
        .where((e) =>
            e.startsWith(packageName) &&
            e.contains(cppJiebaPath) &&
            e.endsWith(".utf8"))
        .toList();

    await Directory(dir).create(recursive: true);
    for (var p in pathList) {
      final fileName = basename(p);
      final file = File(join(dir, fileName));
      if (!file.existsSync()) {
        final dictData = await rootBundle.load(p);
        await file.writeAsBytes(dictData.buffer.asUint8List());
      }
    }
    return "SELECT jieba_dict('$dir');";
  }
}
