import 'dart:typed_data';

import 'package:sqlite3_simple_example/data/impl_web/fetch.dart';

import 'font_loader.dart';

AppFontLoader createFontLoader() => WebFontLoader();

class WebFontLoader extends AppFontLoader {
  Future<ByteData> _fetch(String path) {
    return fetchFromBase(path).then((it) => ByteData.sublistView(it));
  }

  @override
  Future<void> loadFirstScreen() =>
      load(_fetch('fonts/HarmonyOS_Sans_SC_Regular.first_screen.woff2'));

  @override
  Future<void> loadFull() =>
      load(_fetch('fonts/HarmonyOS_Sans_SC_Regular.subset.woff2'));
}
