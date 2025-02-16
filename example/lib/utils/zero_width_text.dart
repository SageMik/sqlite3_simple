import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ZeroWidth {
  ZeroWidth._();

  static const start = "\u200B";
  static const end = "\u200C";
}

class HighlightText extends RegExpSpecialText {
  TextStyle Function(TextStyle normalTextStyle) highLightTextStyle;

  HighlightText(this.highLightTextStyle);

  @override
  InlineSpan finishText(int start, Match match,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    final value = match[0] ?? "";
    return SpecialTextSpan(
      text: value.replaceAll('[${ZeroWidth.start}${ZeroWidth.end}]', ''),
      actualText: value,
      style: highLightTextStyle(textStyle ?? const TextStyle()),
      recognizer: (TapGestureRecognizer()
        ..onTap = () {
          onTap?.call(value);
        }),
      mouseCursor: SystemMouseCursors.text,
    );
  }

  @override
  RegExp get regExp => RegExp("${ZeroWidth.start}(.*?)${ZeroWidth.end}");
}

class HighlightTextSpanBuilder extends RegExpSpecialTextSpanBuilder {
  TextStyle Function(TextStyle src) highLightTextStyle;

  HighlightTextSpanBuilder(this.highLightTextStyle);

  @override
  List<RegExpSpecialText> get regExps =>
      [HighlightText(highLightTextStyle)];
}
