import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../data/main_table_row.dart';
import '../utils/padding.dart';
import 'highlight_text.dart';

/// 搜索结果列表
class SearchResultList extends StatelessWidget {
  final List<MainTableRowUiModel> results;
  final HighlightTextSpanBuilder highlightTextBuilder;
  final void Function(BuildContext context, MainTableRowUiModel row) onItemTap;

  const SearchResultList({
    super.key,
    required this.results,
    required this.highlightTextBuilder,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        return Material(
          // 水波纹特效超出列表：https://github.com/flutter/flutter/issues/73315
          child: InkWell(
            onTap: () => onItemTap(context, r),
            child: Padding(
              padding: const EdgeInsets.only(
                left: P.middle,
                right: P.middle,
                top: P.extraSmall,
                bottom: P.extraSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    r.idFormatted,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      letterSpacing: -1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: P.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExtendedText(
                                r.title,
                                specialTextSpanBuilder: highlightTextBuilder,
                                style: const TextStyle(fontSize: 20),
                              ),
                              ExtendedText(
                                r.content,
                                specialTextSpanBuilder: highlightTextBuilder,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${r.insertDate}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
