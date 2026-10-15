import 'package:flutter/material.dart';

const _labelSize = 12.0;
const _valueSize = 14.0;
const _valueHeight = 1.15;

const _valueStyle = TextStyle(
  fontSize: _valueSize,
  fontWeight: FontWeight.w700,
  height: _valueHeight,
  letterSpacing: -0.3,
  fontFeatures: [FontFeature.tabularFigures()],
);

class SearchStatCell extends StatelessWidget {
  final String label;
  final String? value;
  final TextStyle? style;
  final String? suffix;

  const SearchStatCell._({super.key, required this.label, this.value, this.style, this.suffix});

  const SearchStatCell.common({Key? key, required String label, String? value})
    : this._(key: key, label: label, value: value);

  SearchStatCell.elapsed({Key? key, required String label, Duration? elapsed})
    : this._(
        key: key,
        label: label,
        value: elapsed == null
            ? null
            : (elapsed.inMicroseconds / 1000.0).toStringAsFixed(
                elapsed.inMicroseconds >= 100000 ? 0 : 1,
              ),
        suffix: ' ms',
      );

  const SearchStatCell.token({Key? key, required String label, String? value})
    : this._(
        key: key,
        label: label,
        value: value,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueStyle = (style ?? _valueStyle).copyWith(
      color: scheme.onSurface,
      height: _valueHeight,
    );
    final text = value?.isNotEmpty == true ? value : null;

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
            style: TextStyle(
              fontSize: _labelSize,
              height: _valueHeight,
              color: scheme.onSurfaceVariant,
            ),
            strutStyle: const StrutStyle(
              fontSize: _labelSize,
              height: _valueHeight,
              forceStrutHeight: true,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              // 固定行高，避免跳动
              height: _valueSize * _valueHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _HFadeScroll(
                  fadeColor: scheme.surfaceContainerLow,
                  child: DefaultTextStyle(
                    style: valueStyle,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (text == null)
                            TextSpan(
                              text: '—',
                              style: valueStyle.copyWith(color: scheme.onSurfaceVariant),
                            )
                          else ...[
                            TextSpan(text: text),
                            if (suffix != null)
                              TextSpan(
                                text: ' $suffix',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ],
                      ),
                      strutStyle: const StrutStyle(
                        fontSize: _valueSize,
                        height: _valueHeight,
                        forceStrutHeight: true,
                      ),
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
