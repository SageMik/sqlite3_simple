import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../jieba_dict_type.dart';
import 'ffi.dart';

const String simpleInitSymbol = 'sqlite3_simple_init';

extension Sqlite3SimpleCoreEx on Sqlite3 {
  /// 加载 Simple 扩展，请在打开数据库前调用。
  ///
  /// 如需结巴分词功能，请确保结巴分词文件本地可读，可参考或直接调用 [saveJiebaDictFromBytes] 。
  /// 若使用 [`package:sqlite3_simple`](https://pub.dev/packages/sqlite3_simple) Flutter 库，还可参考或直接调用 [saveJiebaDict] 。
  ///
  /// 若希望自行加载 Simple 原生库，可传入 [override] 进行覆盖，例如:
  /// ```dart
  /// final SqliteExtension? simpleExtension;
  /// if (Platform.isAndroid) {
  ///   simpleExtension = SqliteExtension.inLibrary(
  ///     DynamicLibrary.open('libsimpleNew.so'),
  ///     simpleInitSymbol,
  ///   );
  /// } else {
  ///   simpleExtension = null;
  /// }
  /// sqlite3.loadSimpleExtension(override: simpleExtension);
  /// ```
  void loadSimpleExtension({SqliteExtension? override}) {
    // sqlite3 库如何加载自定义扩展：
    // https://github.com/simolus3/sqlite3.dart/blob/main/sqlite3/example/custom_extension
    ensureExtensionLoaded(
      override ??
          SqliteExtension(
            Native.addressOf<NativeFunction<Sqlite3SimpleInit>>(
              sqlite3_simple_init,
            ).cast(),
          ),
    );
  }

  /// 将结巴分词字典文件保存到指定目录 [dir] 。
  ///
  /// 当字典文件存在时，通过 [overwriteWhenExist] 控制是否覆盖，默认不覆盖。
  ///
  /// 使用结巴分词功能需要执行本方法返回的 SQL 语句，或自行实现相似逻辑。
  Future<String> saveJiebaDictFromBytes(
    String dir, {
    required Map<JiebaDictType, Uint8List> dict,
    bool overwriteWhenExist = false,
  }) async {
    // CppJieba 通过文件路径读取字典，需要将字典文件保存到本地以供读取：
    // https://github.com/yanyiwu/cppjieba/blob/391121d5db0f31dd5ce9795d4d34812f20eeb25c/include/cppjieba/DictTrie.hpp#L211
    await Directory(dir).create(recursive: true);
    await Future.wait(
      dict.entries.map((e) async {
        final file = File(p.join(dir, e.key.filename));
        if (overwriteWhenExist || !file.existsSync()) {
          await file.writeAsBytes(e.value);
        }
      }),
    );
    return "SELECT jieba_dict('$dir');";
  }
}