import 'package:flutter/material.dart';


const _labelSize = 12.0;
const _valueSize = 14.0;
const _tokenSize = 11.0;
const _valueHeight = 1.15;

/// 数值行固定行盒，避免 — / 数字 / 分词切换时高度跳动
const _valueLineBox = _valueSize * _valueHeight;

const _valueStrut = StrutStyle(fontSize: _valueSize, height: _valueHeight, forceStrutHeight: true);
const _labelStrut = StrutStyle(fontSize: _labelSize, height: _valueHeight, forceStrutHeight: true);

/// 数值/占位样式：等宽数字 + 紧字距
const _valueStyle = TextStyle(
  fontSize: _valueSize,
  fontWeight: FontWeight.w700,
  height: _valueHeight,
  letterSpacing: -0.3,
  fontFeatures: [FontFeature.tabularFigures()],
);

class SearchStatCell extends StatelessWidget {
  /// 分词样式：空色区分词与分隔符
  static const tokenStyle = TextStyle(fontSize: _tokenSize, fontWeight: FontWeight.w500);

  final String label;
  final InlineSpan? value;
  final TextStyle? style;

  const SearchStatCell({super.key, required this.label, this.value, this.style});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueStyle = (style ?? _valueStyle).copyWith(color: scheme.onSurface, height: _valueHeight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: _labelSize, height: _valueHeight, color: scheme.onSurfaceVariant),
            strutStyle: _labelStrut,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: _valueLineBox,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _HFadeScroll(
                  fadeColor: scheme.surfaceContainerLow,
                  child: DefaultTextStyle(
                    style: valueStyle,
                    child: Text.rich(
                      value ?? TextSpan(text: '—', style: valueStyle.copyWith(color: scheme.onSurfaceVariant)),
                      strutStyle: _valueStrut,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 横向可滚时右侧淡出，滚到尽头消失
class _HFadeScroll extends StatefulWidget {
  final Widget child;
  final Color fadeColor;

  const _HFadeScroll({required this.child, required this.fadeColor});

  @override
  State<_HFadeScroll> createState() => _HFadeScrollState();
}

class _HFadeScrollState extends State<_HFadeScroll> {
  final _controller = ScrollController();
  var _showFade = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFade);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void didUpdateWidget(covariant _HFadeScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFade() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    final show = pos.maxScrollExtent > 0.5 && pos.pixels < pos.maxScrollExtent - 0.5;
    if (show != _showFade) setState(() => _showFade = show);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _updateFade();
        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: widget.child,
          ),
          if (_showFade)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 24,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.fadeColor.withValues(alpha: 0), widget.fadeColor],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
