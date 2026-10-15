import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/impl/kind.dart';
import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'data/pinyin_dict_kind.dart';
import 'main_provider.dart';
import 'widget/common_dialog.dart';
import 'widget/highlight_text_span_builder.dart';
import 'widget/search_input.dart';
import 'widget/search_options.dart';
import 'widget/search_result_list.dart';
import 'widget/search_stats_cell.dart';

class SearchPanel extends ConsumerStatefulWidget {
  const SearchPanel({super.key});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> {
  final _inputFocused = ValueNotifier(false);

  @override
  void dispose() {
    _inputFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _Header(
            inputFocused: _inputFocused,
            input: SearchInput(
              hintText: '搜索中文、拼音或英文',
              onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
              onFocusChanged: (focused) => _inputFocused.value = focused,
            ),
            options: Consumer(
              builder: (context, ref, _) {
                final dbManagerKind = ref.watch(dbManagerKindProvider);
                final tokenizer = ref.watch(tokenizerProvider);
                final pinyinDictKind = ref.watch(pinyinDictKindProvider);
                return SearchOptions(
                  rows: [
                    SearchOptionRow<DbManagerKind>(
                      label: '数据库实现：',
                      value: dbManagerKind,
                      options: dbManagerKind2uiLabel,
                      onChanged: (v) {
                        if (v == dbManagerKind) {
                          refreshDbData(ref); // 选中后再次点击重灌数据
                        } else {
                          ref.read(dbManagerKindProvider.notifier).update(v);
                        }
                      },
                    ),
                    SearchOptionRow<Tokenizer>(
                      label: '分词器：',
                      value: tokenizer,
                      options: tokenizer2uiLabel,
                      onChanged: (v) => ref.read(tokenizerProvider.notifier).update(v),
                    ),
                    SearchOptionRow<PinyinDictKind>(
                      label: '拼音文件：',
                      value: pinyinDictKind,
                      options: pinyinDictKind2uiLabel,
                      onChanged: (v) => ref.read(pinyinDictKindProvider.notifier).update(v),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final searchResult = ref.watch(searchResultProvider);
              return searchResult.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                data: (results) {
                  final hasQuery = results != null && results.hasQuery;
                  return Listener(
                    onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Column(
                      spacing: 16,
                      children: [
                        _StatBar(
                          cells: [
                            SearchStatCell.common(
                              label: '匹配',
                              value: hasQuery ? results.matchCount.toString() : null,
                            ),
                            SearchStatCell.elapsed(
                              label: '耗时',
                              elapsed: hasQuery ? results.elapsed : null,
                            ),
                            SearchStatCell.common(
                              label: '总量',
                              value: results?.totalCount.toString(),
                            ),
                          ],
                          wideCell: SearchStatCell.token(
                            label: '分词',
                            value: hasQuery ? results.tokens : null,
                          ),
                        ),
                        Expanded(
                          child: results == null
                              ? const Center(child: CircularProgressIndicator())
                              : SearchResultList(
                                  items: results.rows,
                                  onItemTap: (context, row) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _ResultDialog(row),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: SelectionArea(child: Text('错误: $error\n\n堆栈：$stack')),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ValueListenable<bool> inputFocused;
  final Widget input;
  final Widget options;

  const _Header({required this.inputFocused, required this.input, required this.options});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(8);
    return TextFieldTapRegion(
      child: ValueListenableBuilder<bool>(
        valueListenable: inputFocused,
        builder: (context, focused, child) => AnimatedContainer(
          duration: kThemeChangeDuration,
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: focused ? scheme.primary : Colors.transparent, width: 1.5),
          ),
          child: child,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: scheme.surfaceContainerLow, child: input),
              options,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final List<Widget> cells;
  final Widget wideCell;

  const _StatBar({required this.cells, required this.wideCell});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 6,
        children: [
          Row(spacing: 6, children: [for (final cell in cells) Expanded(child: cell)]),
          wideCell,
        ],
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final MainTableRowUiModel row;

  const _ResultDialog(this.row);

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
