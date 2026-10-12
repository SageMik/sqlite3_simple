import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3_simple_example/data/db_manager_kind.dart';
import 'package:sqlite3_simple_example/widget/highlight_text_span_builder.dart';

import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'data/pinyin_dict_kind.dart';
import 'main_provider.dart';
import 'widget/dialog/search_result_dialog.dart';
import 'widget/search_input.dart';
import 'widget/search_options.dart';
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            spacing: 6,
                            children: [
                              Row(
                                spacing: 6,
                                children: [
                                  Expanded(
                                    child: SearchStatCell(
                                      label: '匹配',
                                      value: hasQuery
                                          ? TextSpan(text: results.matchCount.toString())
                                          : null,
                                    ),
                                  ),
                                  Expanded(
                                    child: SearchStatCell(
                                      label: '耗时',
                                      value: hasQuery
                                          ? TextSpan(
                                              children: [
                                                TextSpan(text: results.elapsedText),
                                                TextSpan(
                                                  text: ' ms',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : null,
                                    ),
                                  ),
                                  Expanded(
                                    child: SearchStatCell(
                                      label: '总量',
                                      value: results != null
                                          ? TextSpan(text: results.totalCount.toString())
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SearchStatCell(
                                label: '分词',
                                value: hasQuery ? TextSpan(text: results.tokens) : null,
                                style: SearchStatCell.tokenStyle,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: results == null
                              ? const Center(child: CircularProgressIndicator())
                              : _ResultList(
                                  items: results.rows,
                                  onItemTap: (context, row) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SearchResultDialog(row),
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

class _ResultList extends StatelessWidget {
  final List<MainTableRowUiModel> items;
  final void Function(BuildContext context, MainTableRowUiModel row) onItemTap;

  const _ResultList({required this.items, required this.onItemTap});

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
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                spacing: 8,
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
