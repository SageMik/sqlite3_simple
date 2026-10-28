import 'dart:async';

import 'package:sqlite3_simple_core_example/search_result.dart';
import 'package:termui/termui.dart';

/// 命中片段与光标的样式：叠加在基础样式之上。
const _markedStyle = Style(modifiers: Modifier.reverse);

/// 一行里的一段同色文本，`marked` 表示它是否被 [ZeroWidth] 标记为高亮。
typedef _Run = (String text, bool marked);

/// 按显示宽度折行、命中片段反色绘制的文本，可选在 [caret] 处显示闪烁光标。
///
/// [Text] 不支持行内样式，[RichText] 又把字符数当列宽（中文会溢出、被后一个字覆盖），
/// 所以这里自己按 [graphemeWidth] 累计列数折行，再交给 [Buffer.writeString] 绘制
/// （它负责宽字符占两格、零宽字符不占格）。
class MarkedText extends StatefulWidget {
  final String text;
  final Style style;

  /// 光标位置（按 rune 计）：落在该字符上并闪烁；等于长度时显示在末尾；
  /// 为 null 则不显示光标、也不启动定时器。
  final int? caret;

  const MarkedText(
    this.text, {
    super.key,
    this.style = Style.empty,
    this.caret,
  });

  @override
  State<MarkedText> createState() => _MarkedTextState();

  @override
  int getIntrinsicHeight(int width) => _wrap(text, width).length;
}

class _MarkedTextState extends State<MarkedText> {
  Timer? _blink;
  var _caretVisible = true;

  @override
  void initState() {
    super.initState();
    _syncBlink();
  }

  @override
  void didUpdateWidget(MarkedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 内容或光标变了，让光标立刻可见，避免正好落在“暗”的半秒里
    if (widget.caret != oldWidget.caret || widget.text != oldWidget.text) {
      _caretVisible = true;
    }
    _syncBlink();
  }

  @override
  void dispose() {
    _blink?.cancel();
    super.dispose();
  }

  /// 只有需要光标时才跑定时器，纯文本不会触发重建。
  void _syncBlink() {
    if (widget.caret == null) {
      _blink?.cancel();
      _blink = null;
      return;
    }
    _blink ??= Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() => _caretVisible = !_caretVisible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caret = widget.caret?.clamp(0, widget.text.runes.length);
    if (caret == null || !_caretVisible) {
      return _MarkedTextRender(widget.text, widget.style);
    }

    final runes = widget.text.runes.toList();
    final marked = caret < runes.length
        ? '${String.fromCharCodes(runes.take(caret))}'
              '${ZeroWidth.start}${String.fromCharCode(runes[caret])}${ZeroWidth.end}'
              '${String.fromCharCodes(runes.skip(caret + 1))}'
        : '${widget.text}${ZeroWidth.start} ${ZeroWidth.end}';
    return _MarkedTextRender(marked, widget.style);
  }
}

/// 真正负责绘制的部分：把带标记的文本交给 [_MarkedTextElement]。
class _MarkedTextRender extends Widget {
  final String text;
  final Style style;

  const _MarkedTextRender(this.text, this.style);

  @override
  Element createElement() => _MarkedTextElement(this);

  @override
  int getIntrinsicHeight(int width) => _wrap(text, width).length;
}

class _MarkedTextElement extends Element {
  _MarkedTextElement(_MarkedTextRender super.widget);

  /// 布局时算好的行，绘制直接复用，避免每帧重新折行。
  var _lines = const <List<_Run>>[];

  @override
  Size performLayout(BoxConstraints constraints) {
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0;
    _lines = _wrap((widget as _MarkedTextRender).text, width);
    return constraints.constrain(Size(width, _lines.length));
  }

  @override
  void performPaint(Buffer buffer, Offset offset) {
    final view = widget as _MarkedTextRender;
    var y = offset.dy.toInt();
    for (final line in _lines) {
      var x = offset.dx.toInt();
      for (final (text, marked) in line) {
        buffer.writeString(
          x,
          y,
          text,
          marked ? view.style.merge(_markedStyle) : view.style,
        );
        x += measureStringWidth(text);
      }
      y++;
    }
  }
}

/// 按显示宽度折行，命中标记本身不进入结果。
List<List<_Run>> _wrap(String text, int width) {
  final lines = <List<_Run>>[];
  var line = <_Run>[];
  final run = StringBuffer();
  var marked = false;
  var used = 0;

  void endRun() {
    if (run.isEmpty) return;
    line.add((run.toString(), marked));
    run.clear();
  }

  void endLine() {
    endRun();
    lines.add(line);
    line = [];
    used = 0;
  }

  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    switch (char) {
      case ZeroWidth.start:
        endRun();
        marked = true;
      case ZeroWidth.end:
        endRun();
        marked = false;
      case '\n':
        endLine();
      default:
        final charWidth = graphemeWidth(char);
        if (used + charWidth > width && line.isNotEmpty) endLine();
        run.write(char);
        used += charWidth;
    }
  }
  endLine();

  return lines;
}
