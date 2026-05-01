import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_simple_example/widget/search_input.dart';

import 'data/db_manager_kind.dart';
import 'data/main_table_dao.dart';
import 'main_provider.dart';
import 'utils/padding.dart';
import 'widget/highlight_text.dart';
import 'widget/search_option_radio_row.dart';
import 'widget/search_result_dialog.dart';
import 'widget/search_result_list.dart';

void main() {
  runApp(
    ProviderScope(
      child: const MyApp(),
      retry: (retryCount, error) =>
          ProviderContainer.defaultRetry(retryCount, error, maxRetries: 0),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// 通过国际化设置中文环境以让 Flutter 使用正确的中文字体，主要是 Windows 平台
    const localizationsDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    const supportedLocales = [Locale('zh', 'CN')];

    /// 自定义中文字体，避免 Flutter 默认加载字体的方式导致短时间的乱码
    const fontFamily = 'HarmonyOS Sans SC';

    final theme = ThemeData(fontFamily: fontFamily);
    final colorScheme = theme.colorScheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Simple 分词器 示例',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              buildSearchBar(),
              buildSearchOptions(context),
              Expanded(child: buildSearchResult()),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索栏
  Widget buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: P.middle,
        right: P.middle,
        top: P.middle,
      ),
      child: Consumer(
        builder: (context, ref, _) {
          return SearchInput(
            onChanged: ref.read(searchQueryProvider.notifier).update,
          );
        },
      ),
    );
  }

  /// 搜索栏下方选项
  Widget buildSearchOptions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(P.middle),
      child: Consumer(
        builder: (context, ref, _) {
          return Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              SearchOptionRadioRow<Tokenizer>(
                label: "分词器：",
                value: ref.watch(tokenizerProvider),
                options: tokenizer2uiString,
                onChanged: (v) =>
                    ref.read(tokenizerProvider.notifier).update(v),
              ),
              SearchOptionRadioRow<DbManagerKind>(
                label: "数据库实现：",
                value: ref.watch(dbManagerKindProvider),
                options: kind2uiString,
                onChanged: (v) async {
                  if (ref.read(dbManagerKindProvider) == v) {
                    // 重复点击刷新为新的随机数据
                    await ref.read(dbManagerProvider).value?.dao.updateAll();
                    ref.invalidate(searchResultProvider);
                  } else {
                    if (kDebugMode) {
                      print("切换数据库至：${kind2uiString[v]}");
                    }
                    ref.read(dbManagerKindProvider.notifier).update(v);
                  }
                },
                isLast: true,
              ),
            ],
          );
        },
      ),
    );
  }

  /// 高亮文本构建器
  static final highlightTextBuilder = HighlightTextSpanBuilder(
    (src) => src.copyWith(color: Colors.red),
  );

  /// 搜索结果
  Widget buildSearchResult() {
    return Consumer(
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
                    results: results,
                    highlightTextBuilder: highlightTextBuilder,
                    onItemTap: (context, row) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            SearchResultDialog(row, highlightTextBuilder),
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
    );
  }
}
