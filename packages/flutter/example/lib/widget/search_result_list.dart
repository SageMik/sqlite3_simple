import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/main_table_row.dart';
import '../utils/padding.dart';
import 'highlight_text_span_builder.dart';

typedef OnItemTap = void Function(BuildContext context, MainTableRowUiModel row);

/// 搜索结果列表
class SearchResultList extends StatelessWidget {
  final List<MainTableRowUiModel> items;
  final OnItemTap onItemTap;

  const SearchResultList({super.key, required this.items, required this.onItemTap});

  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final highlightTextBuilder = HighlightTextSpanBuilder.Default;
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final r = items[index];
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.surface,
          child: InkWell(
            onTap: () => onItemTap(context, r),
            hoverColor: Theme.of(context).hoverColor,
            highlightColor: Colors.transparent,
            splashColor: Theme.of(context).splashColor,
            splashFactory: InkRipple.splashFactory,
            child: Padding(
              padding: const EdgeInsets.only(
                left: P.middle,
                right: P.middle,
                top: P.extraSmall,
                bottom: P.extraSmall,
              ),
              child: Row(
                spacing: P.small,
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
                              ExtendedText(r.content, specialTextSpanBuilder: highlightTextBuilder),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _dateFormat.format(r.insertDate),
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
