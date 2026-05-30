import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db_manager.dart';
import '../pinyin_dict_kind.dart';

mixin PinyinDictSaver<TDb> on IDbManager<TDb> {
  @override
  Future<Map<PinyinDictKind, String>> savePinyinDict() async {
    final docDir = await getApplicationDocumentsDirectory();
    final pinyinDictDir = join(docDir.path, "sqlite3_simple_example/pinyin_dict");
    await Directory(pinyinDictDir).create(recursive: true);
    final entries = await Future.wait(
      PinyinDictKind.values.map((k) async {
        if (k.isBundled) {
          return MapEntry(k, '');
        }
        final f = File(join(pinyinDictDir, k.assetName!));
        if (!await f.exists()) {
          await f.writeAsBytes(
            (await rootBundle.load(k.assetPath!)).buffer.asUint8List(),
          );
        }
        return MapEntry(k, f.path);
      }),
    );
    return Map.fromEntries(entries);
  }
}
