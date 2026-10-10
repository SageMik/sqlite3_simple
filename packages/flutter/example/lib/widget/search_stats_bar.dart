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
TextStyle _valueStyle(Color color) => TextStyle(
  fontSize: _valueSize,
  fontWeight: FontWeight.w700,
  height: _valueHeight,
  letterSpacing: -0.3,
  fontFeatures: const [FontFeature.tabularFigures()],
  color: color,
);

/// 分词样式：空色区分词与分隔符
TextStyle _tokenStyle(Color color, FontWeight weight) =>
    TextStyle(fontSize: _tokenSize, fontWeight: weight, height: _valueHeight, color: color);

/// 匹配 | 耗时 | 总量 + 通栏分词；无关键词时匹配/耗时/分词为 —
class SearchStatsBar extends StatelessWidget {
  final bool hasQuery;
  final int matchCount;
  final Duration elapsed;
  final int? totalCount;
  final String tokens;

  const SearchStatsBar({
    super.key,
    required this.hasQuery,
    required this.matchCount,
    required this.elapsed,
    required this.totalCount,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mute = scheme.onSurfaceVariant;
    final dash = Text('—', style: _valueStyle(mute), strutStyle: _valueStrut);
    final tokenParts = _splitTokens(tokens);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: '匹配',
                  child: hasQuery ? _valueText(context, '$matchCount') : dash,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatCell(
                  label: '耗时',
                  child: hasQuery ? _valueText(context, _msText(elapsed), unit: 'ms') : dash,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatCell(
                  label: '总量',
                  child: totalCount != null ? _valueText(context, '$totalCount') : dash,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _StatCell(
            label: '分词',
            child: hasQuery && tokenParts.isNotEmpty
                ? _HFadeScroll(
                    fadeColor: scheme.surfaceContainerLow,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (var i = 0; i < tokenParts.length; i++) ...[
                            if (i > 0) TextSpan(text: ' · ', style: _tokenStyle(mute, FontWeight.w400)),
                            TextSpan(text: tokenParts[i], style: _tokenStyle(scheme.onSurface, FontWeight.w500)),
                          ],
                        ],
                      ),
                      strutStyle: _valueStrut,
                    ),
                  )
                : dash,
          ),
        ],
      ),
    );
  }

  static List<String> _splitTokens(String raw) {
    final cleaned = raw.replaceAll('"', '').trim();
    if (cleaned.isEmpty) return const [];
    return cleaned.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  }

  /// 数值文本；[unit] 以次级样式附在数值后
  static Widget _valueText(BuildContext context, String text, {String? unit}) {
    final scheme = Theme.of(context).colorScheme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: _valueStyle(scheme.onSurface)),
          if (unit != null)
            TextSpan(
              text: ' $unit',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: _valueHeight,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      strutStyle: _valueStrut,
    );
  }

  /// 毫秒文本：≥100ms 取整，否则保留一位小数
  static String _msText(Duration elapsed) {
    final ms = elapsed.inMicroseconds / 1000.0;
    return ms >= 100 ? ms.toStringAsFixed(0) : ms.toStringAsFixed(1);
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatCell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              child: Align(alignment: Alignment.centerLeft, child: child),
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
