import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../data/main_table_row.dart';
import '../../utils/padding.dart';
import 'common_dialog.dart';
import '../highlight_text.dart';

/// 搜索结果详情对话框
class SearchResultDialog extends StatelessWidget {
  final MainTableRowUiModel row;
  final HighlightTextSpanBuilder highlightTextBuilder;

  const SearchResultDialog(this.row, this.highlightTextBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            row.idFormatted,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1,
              letterSpacing: -1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: P.small),
          ExtendedText(
            row.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            specialTextSpanBuilder: highlightTextBuilder,
          ),
          const SizedBox(height: P.extraSmall),
          ExtendedText(
            row.content,
            specialTextSpanBuilder: highlightTextBuilder,
            style: const TextStyle(fontSize: 18, height: 1.3),
          ),
        ],
      ),
    );
  }
}
