import 'package:flutter/material.dart';

import '../../utils/padding.dart';

/// 通用对话框
class CommonDialog extends StatelessWidget {
  static const double width = 420;

  final Widget child;
  final String closeLabel;

  const CommonDialog({
    super.key,
    required this.child,
    this.closeLabel = '确定',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rounded = MediaQuery.sizeOf(context).width > width;
    final borderRadius = rounded
        ? BorderRadius.circular(P.small)
        : BorderRadius.zero;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      content: Container(
        width: width,
        padding: const EdgeInsets.all(P.middle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            const SizedBox(height: P.middle),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(P.small),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(closeLabel),
            ),
          ],
        ),
      ),
    );
  }
}
