import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_simple_example/data/db_manager_kind.dart';

import 'data/main_table_dao.dart';
import 'data/pinyin_dict_kind.dart';
import 'main_provider.dart';
import 'widget/dialog/search_result_dialog.dart';
import 'widget/search_input.dart';
import 'widget/search_options.dart';
import 'widget/search_result_list.dart';
import 'widget/search_stats_bar.dart';

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
              return ref
                  .watch(searchResultProvider)
                  .when(
                    skipLoadingOnRefresh: true,
                    skipLoadingOnReload: true,
                    data: (results) {
                      return Listener(
                        onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        child: Column(
                          spacing: 16,
                          children: [
                            SearchStatsBar(
                              hasQuery: results?.hasQuery ?? false,
                              matchCount: results?.matchCount ?? 0,
                              elapsed: results?.elapsed ?? Duration.zero,
                              totalCount: results?.totalCount,
                              tokens: results?.tokens ?? '',
                            ),
                            Expanded(
                              child: results == null
                                  ? const Center(child: CircularProgressIndicator())
                                  : SearchResultList(
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
    return ValueListenableBuilder<bool>(
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
    );
  }
}
