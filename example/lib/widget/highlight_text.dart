import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/zero_width.dart';

class HighlightText extends RegExpSpecialText {
  TextStyle Function(TextStyle normalTextStyle) highLightTextStyle;

  HighlightText(this.highLightTextStyle);

  @override
  InlineSpan finishText(int start, Match match,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    final actualText = match[0] ?? "";
    // 使用正则表达式清除零宽字符，避免实际渲染零宽字符导致文本宽高发生微小的变动
    final showingText = actualText.replaceAll(RegExp('[${ZeroWidth.start}${ZeroWidth.end}]'), '');
    return SpecialTextSpan(
      text: showingText,
      actualText: actualText,
      style: highLightTextStyle(textStyle ?? const TextStyle()),
      recognizer: (TapGestureRecognizer()
        ..onTap = () {
          onTap?.call(actualText);
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
  List<RegExpSpecialText> get regExps => [HighlightText(highLightTextStyle)];
}
