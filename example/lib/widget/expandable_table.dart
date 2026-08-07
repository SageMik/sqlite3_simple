import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpandableTable extends StatefulWidget {
  const ExpandableTable({
    super.key,
    required this.expanded,
    required this.child,
    required this.trailing,
    this.pinnedRowCount = 1,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeInOut,
  });

  final bool expanded;
  final Widget child;
  final Widget trailing;
  final int pinnedRowCount;
  final Duration duration;
  final Curve curve;

  @override
  State<ExpandableTable> createState() => _ExpandableTableState();
}

class _ExpandableTableState extends State<ExpandableTable>
    with SingleTickerProviderStateMixin {
  final GlobalKey _hostKey = GlobalKey();
  late final AnimationController _controller;
  double _pinnedHeight = 0.0;
  double _fullHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.expanded ? 1.0 : 0.0,
    );
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(ExpandableTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (widget.child != oldWidget.child ||
        widget.pinnedRowCount != oldWidget.pinnedRowCount) {
      _scheduleMeasure();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  RenderTable? _findRenderTable() {
    final ctx = _hostKey.currentContext;
    if (ctx == null) return null;
    final root = ctx.findRenderObject();
    if (root == null) return null;

    RenderTable? found;
    void visit(RenderObject node) {
      if (found != null) return;
      if (node is RenderTable) {
        found = node;
        return;
      }
      node.visitChildren(visit);
    }

    visit(root);
    return found;
  }

  void _measure() {
    if (!mounted) return;
    final table = _findRenderTable();
    if (table == null || !table.hasSize || table.rows == 0) return;

    final fullHeight = table.size.height;
    if (fullHeight <= 0) return;

    final count = widget.pinnedRowCount.clamp(1, table.rows);
    final pinnedHeight = table.getRowBox(count - 1).bottom;

    if ((pinnedHeight - _pinnedHeight).abs() > 0.0001 ||
        (fullHeight - _fullHeight).abs() > 0.0001) {
      setState(() {
        _pinnedHeight = pinnedHeight;
        _fullHeight = fullHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = widget.curve.transform(_controller.value);
            final hasMeasure = _fullHeight > 0 && _pinnedHeight > 0;
            if (!hasMeasure) {
              return child!;
            }

            final dpr = MediaQuery.devicePixelRatioOf(context);
            var height = lerpDouble(_pinnedHeight, _fullHeight, t)!;
            if (t < 1.0) {
              height = (height * dpr).floor() / dpr;
            }

            return ClipRect(
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: height.clamp(0.0, _fullHeight),
                width: double.infinity,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: _fullHeight,
                  maxHeight: _fullHeight,
                  child: child,
                ),
              ),
            );
          },
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (_) {
              _scheduleMeasure();
              return false;
            },
            child: SizeChangedLayoutNotifier(
              key: _hostKey,
              child: widget.child,
            ),
          ),
        ),
        widget.trailing,
      ],
    );
  }
}
