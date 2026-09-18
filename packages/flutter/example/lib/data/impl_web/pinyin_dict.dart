import 'dart:ui_web';

import '../pinyin_dict_kind.dart';

extension PinyinDictExt on List<PinyinDictKind> {
  /// 获取拼音文件在 Web 上的 URL，`dart:ui_web` 无法编译为 JavaScript ，只能在主线程中调用。
  Map<PinyinDictKind, String> resolveUrl() => {
    for (final kind in this)
      kind: (kind.isBundled ? '' : assetManager.getAssetUrl(kind.assetPath!)),
  };
}
