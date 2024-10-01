import 'package:flutter/material.dart';

import 'custom_text.dart';

class ZeroWidth {
  ZeroWidth._();

  static const start = "\u200B";
  static const end = "\u200C";
}

class ZeroWidthText extends CustomText {
  ZeroWidthText(TextStyle textStyle, {super.onTap})
      : super(ZeroWidth.start, ZeroWidth.end, textStyle);
}
