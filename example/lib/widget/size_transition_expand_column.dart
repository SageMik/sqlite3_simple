import 'package:flutter/material.dart';

class SizeTransitionExpandColumn extends StatefulWidget {
  const SizeTransitionExpandColumn({
    super.key,
    required this.expanded,
    required this.expandingChild,
    required this.trailing,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeInOut,
  });

  final bool expanded;
  final Widget expandingChild;
  final Widget trailing;
  final Duration duration;
  final Curve curve;

  @override
  State<SizeTransitionExpandColumn> createState() =>
      _SizeTransitionExpandColumnState();
}

class _SizeTransitionExpandColumnState extends State<SizeTransitionExpandColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _sizeFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.expanded ? 1.0 : 0.0,
    );
    _sizeFactor = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(SizeTransitionExpandColumn oldWidget) {
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
  }

  @override
  void dispose() {
    _sizeFactor.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizeTransition(
          axis: Axis.vertical,
          axisAlignment: -1,
          sizeFactor: _sizeFactor,
          child: widget.expandingChild,
        ),
        widget.trailing,
      ],
    );
  }
}
