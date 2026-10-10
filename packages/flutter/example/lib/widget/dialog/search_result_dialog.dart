import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../data/main_table_row.dart';
import 'common_dialog.dart';
import '../highlight_text_span_builder.dart';

/// 搜索结果详情对话框
class SearchResultDialog extends StatelessWidget {
  final MainTableRowUiModel row;

  const SearchResultDialog(this.row, {super.key});

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
          const SizedBox(height: 8),
          ExtendedText(
            row.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            specialTextSpanBuilder: HighlightTextSpanBuilder.Default,
          ),
          const SizedBox(height: 4),
          ExtendedText(
            row.content,
            specialTextSpanBuilder: HighlightTextSpanBuilder.Default,
            style: const TextStyle(fontSize: 18, height: 1.3),
          ),
        ],
      ),
    );
  }
}
