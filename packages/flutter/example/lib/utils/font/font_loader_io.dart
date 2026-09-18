import 'package:flutter/services.dart';

import 'font_loader.dart';

AppFontLoader createFontLoader() => IoFontLoader();

class IoFontLoader extends AppFontLoader {
  @override
  Future<void> loadFirstScreen() =>
      load(rootBundle.load('assets/font/HarmonyOS_Sans_SC_Regular.subset.ttf'));

  @override
  Future<void> loadFull() async {}
}
