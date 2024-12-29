import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

/// https://github.com/wangfenjin/simple/blob/ffc78ec4d5ac962d889cb68ea3691e83a699fe2c/src/simple_tokenizer.cc#L65
const _jiebaDictFileSet = {
  "jieba.dict.utf8",
  "hmm_model.utf8",
  "user.dict.utf8",
  "idf.utf8",
  "stop_words.utf8",
};

typedef OpenSimple = DynamicLibrary? Function();

extension Sqlite3SimpleEx on Sqlite3 {
  /// 加载 Simple 扩展，请在打开数据库前调用。如果需要结巴分词功能，调用 [saveJiebaDict]。
  /// 若希望自行加载 Simple 原生库，向 [overrideOpen] 传入返回值为 [DynamicLibrary] 或 null 的函数，
  /// 返回值非 null 时，优先使用返回值加载扩展，反之使用默认的加载逻辑。
  void loadSimpleExtension({OpenSimple? overrideOpen}) {
    DynamicLibrary defaultOpen() {
      String libSimple = "";
      if (Platform.isAndroid) {
        libSimple = "libsimple.so";
      } else if (Platform.isWindows) {
        libSimple = "simple.dll";
      } else if (Platform.isLinux) {
        libSimple = "${File(Platform.resolvedExecutable).parent.path}/bin/libsimple.so";
        // libSimple = "libsimple.so";
      }
      return libSimple.isNotEmpty
          ? DynamicLibrary.open(libSimple)
          : DynamicLibrary.process();
    }

    // sqlite3 库 如何加载自定义扩展：
    // https://github.com/simolus3/sqlite3.dart/blob/855bdc1ff1b6e03b60cded99dd45a107b3588009/sqlite3/test/ffi/sqlite3_test.dart#L37-L104
    ensureExtensionLoaded(SqliteExtension.inLibrary(
        overrideOpen?.call() ?? defaultOpen(), "sqlite3_simple_init"));
  }

  /// 将结巴分词所需字典文件保存到指定目录 [dir] ，
  /// 当字典文件存在时，通过 [overwriteWhenExist] 控制是否覆盖，默认不覆盖。
  /// 使用结巴分词功能务必调用该函数，并执行本方法返回的SQL语句
  Future<String> saveJiebaDict(
    String dir, {
    bool overwriteWhenExist = false,
  }) async {
    // CppJieba通过文件路径读取字典，需要将字典文件保存到本地以供读取
    // https://github.com/yanyiwu/cppjieba/blob/391121d5db0f31dd5ce9795d4d34812f20eeb25c/include/cppjieba/DictTrie.hpp#L211 )
    final jsonString = await rootBundle.loadString("AssetManifest.json");
    final pathList = Map<String, dynamic>.from(json.decode(jsonString))
        .keys
        .where((e) =>
            e.startsWith("packages/sqlite3_simple") &&
            e.contains("cpp_jieba_dict") &&
            _jiebaDictFileSet.contains(basename(e)))
        .toList();

    await Directory(dir).create(recursive: true);
    await Future.wait(pathList.map((p) async {
      final fileName = basename(p);
      final file = File(join(dir, fileName));
      if (overwriteWhenExist || !file.existsSync()) {
        final dictData = await rootBundle.load(p);
        return file.writeAsBytes(dictData.buffer.asUint8List());
      }
    }));

    return "SELECT jieba_dict('$dir');";
  }
}
