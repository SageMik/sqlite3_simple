import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db_manager_kind.dart';
import 'data/main_table_dao.dart';
import 'data/pinyin_dict_kind.dart';
import 'main_provider.dart';
import 'utils/padding.dart';
import 'widget/expand_collapse_strip.dart';
import 'widget/highlight_text.dart';
import 'widget/search_input.dart';
import 'widget/search_option_radio_row.dart';
import 'widget/search_result_dialog.dart';
import 'widget/search_result_list.dart';
import 'widget/size_transition_expand_column.dart';

void main() {
  runApp(
    ProviderScope(
      retry: (retryCount, error) =>
          ProviderContainer.defaultRetry(retryCount, error, maxRetries: 0),
      child: const MyApp(),
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
          centerTitle: true,
          title: const Text(
            'Simple 分词器 示例',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actionsPadding: const EdgeInsetsDirectional.only(end: P.small),
          actions: buildActions(),
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

  /// 右上角功能按钮
  List<Widget> buildActions() {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(
            builder: (context, ref, _) => IconButton(
              tooltip: '刷新数据',
              onPressed: () => refreshDbData(ref),
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    ];
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
      padding: const EdgeInsets.fromLTRB(P.middle, P.middle, P.middle, 0),
      child: Consumer(
        builder: (context, ref, _) {
          final moreOpen = ref.watch(searchOptionsMoreOpenProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Table(
                columnWidths: searchOptionTableColumnWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  SearchOptionRadioRow<DbManagerKind>(
                    label: "数据库实现：",
                    value: ref.watch(dbManagerKindProvider),
                    options: dbManagerKind2uiString,
                    onChanged: (v) async {
                      if (ref.read(dbManagerKindProvider) == v) {
                        // 重复点击刷新为新的随机数据
                        await refreshDbData(ref);
                      } else {
                        if (kDebugMode) {
                          print("切换数据库至：${dbManagerKind2uiString[v]}");
                        }
                        ref.read(dbManagerKindProvider.notifier).update(v);
                      }
                    },
                  ),
                ],
              ),
              SizeTransitionExpandColumn(
                expanded: moreOpen,
                expandingChild: Padding(
                  padding: const EdgeInsets.only(top: P.extraSmall),
                  child: Table(
                    columnWidths: searchOptionTableColumnWidths,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      SearchOptionRadioRow<Tokenizer>(
                        label: "分词器：",
                        value: ref.watch(tokenizerProvider),
                        options: tokenizer2uiString,
                        onChanged: (v) =>
                            ref.read(tokenizerProvider.notifier).update(v),
                      ),
                      SearchOptionRadioRow<PinyinDictKind>(
                        label: "拼音文件：",
                        value: ref.watch(pinyinDictKindProvider),
                        options: pinyinDictKind2uiString,
                        isLast: true,
                        onChanged: (v) =>
                            ref.read(pinyinDictKindProvider.notifier).update(v),
                      ),
                    ],
                  ),
                ),
                trailing: ExpandCollapseStrip(
                  expanded: moreOpen,
                  onTap: () => ref
                      .read(searchOptionsMoreOpenProvider.notifier)
                      .update(!ref.read(searchOptionsMoreOpenProvider)),
                ),
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

  static const searchOptionTableColumnWidths = <int, TableColumnWidth>{
    0: IntrinsicColumnWidth(),
    1: FlexColumnWidth(),
  };

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

  /// 刷新数据库数据
  Future<void> refreshDbData(WidgetRef ref) async {
    final dbManager = await ref.read(dbManagerProvider.future);
    await dbManager.dao.updateAll();
    ref.invalidate(searchResultProvider);
    await ref.read(searchResultProvider.future);
  }
}
