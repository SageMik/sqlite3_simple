import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

class CustomText extends SpecialText {
  CustomText(
    super.startFlag,
    super.endFlag,
    super.textStyle, {
    this.start = 0,
    super.onTap,
  });

  final int start;

  @override
  InlineSpan finishText() {
    final String text = toString();
    return SpecialTextSpan(
      text: text,
      actualText: text,
      start: start,
      style: textStyle,
    );
  }
}

class CustomTextBuilder extends SpecialTextSpanBuilder {
  final List<CustomText> customs;

  CustomTextBuilder(this.customs);

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    if (flag == '') {
      return null;
    }

    for (var t in customs) {
      if (isStart(flag, t.startFlag)) {
        return CustomText(
          t.startFlag,
          t.endFlag,
          t.textStyle,
          start: index - (t.startFlag.length - 1),
          onTap: t.onTap,
        );
      }
    }
    return null;
  }
}
