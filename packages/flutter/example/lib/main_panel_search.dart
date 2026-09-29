import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_simple_example/widget/search_input.dart';

import 'main_provider.dart';
import 'utils/padding.dart';
import 'widget/dialog/search_result_dialog.dart';
import 'widget/search_result_list.dart';

class SearchPanel extends ConsumerWidget {
  const SearchPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: P.middle,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: P.middle),
          child: SearchInput(
            hintText: '搜索中文、拼音或英文',
            onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final result = ref.watch(searchResultProvider);
              return result.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                data: (results) => AnimatedSwitcher(
                  duration: kThemeAnimationDuration,
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
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: P.middle),
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
