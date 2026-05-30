import 'package:flutter/material.dart';

import '../utils/padding.dart';

class ExpandCollapseStrip extends StatelessWidget {
  const ExpandCollapseStrip({
    super.key,
    required this.expanded,
    required this.onTap,
    this.iconSize = 16,
    this.stripHeight = 18,
    this.iconTurnDuration = const Duration(milliseconds: 220),
    this.iconTurnCurve = Curves.easeInOut,
  });

  final bool expanded;
  final VoidCallback onTap;
  final double iconSize;
  final double stripHeight;
  final Duration iconTurnDuration;
  final Curve iconTurnCurve;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: expanded ? P.small + P.extraSmall : P.extraSmall,
        bottom: 2,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: stripHeight,
            width: double.infinity,
            child: Center(
              child: AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: iconTurnDuration,
                curve: iconTurnCurve,
                child: Icon(Icons.expand_more, size: iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
