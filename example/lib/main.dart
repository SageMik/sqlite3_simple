import 'dart:async';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlite3_simple_example/data/impl/sqflite_common_ffi_impl.dart';
import 'package:sqlite3_simple_example/search_dropdown.dart';

import 'data/impl/sqlite3_impl.dart';
import 'data/main_table_dao.dart';
import 'data/main_table_row.dart';
import 'utils/zero_width_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState<T> extends State<MyApp> {
  late final SqfliteCommonFfiDbManager dbManager;

  SqfliteCommonFfiDao get dao => dbManager.dao;

  List<MainTableRow>? results;

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchValueChanged);
    dbManager = SqfliteCommonFfiDbManager()
      ..init().then((_) async {
        await dao.insertRandomData(30);
        results = await dao.selectAll();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN')],
      // 通过国际化设置中文环境以让 Flutter 使用正确的中文字体
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple 分词器 示例'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              buildSearchBar(),
              buildSearchOption(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: kThemeChangeDuration,
                  child: results != null
                      ? buildListView()
                      : const CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索栏
  Widget buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.only(left: P.middle, right: P.middle, top: P.middle),
      child: TapRegion(
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: SearchBar(
          controller: searchController,
          leading: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.search),
          ),
          trailing: [
            if (showClearButton)
              IconButton(
                  onPressed: () => searchController.text = "",
                  icon: const Icon(Icons.clear))
          ],
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
    );
  }

  var showClearButton = false;

  final searchController = SearchController();

  Future<void> onSearchValueChanged() async {
    final value = searchController.text.trim();
    showClearButton = value.isNotEmpty;
    results = await (showClearButton
        ? dao.search(value, tokenizer)
        : dao.selectAll());
    setState(() {});
  }

  /// 搜索栏下方选项
  Widget buildSearchOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: P.middle),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: P.middle),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownFromMap<Tokenizer>(
                    label: "分词器：",
                    initValue: tokenizer,
                    map: tokenizer2uiString,
                    onChanged: (value) => setState(() {
                      tokenizer = value!;
                      onSearchValueChanged();
                    }),
                  ),
                  const SizedBox(width: 8),
                  DropdownFromMap<DbImplement>(
                    label: "数据库实现：",
                    initValue: dbImplement,
                    map: implement2uiString,
                    onChanged: (value) => setState(() {
                      dbImplement = value!;
                      // onSearchValueChanged();
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
            onPressed: () => setState(() {
              results = null;
              dao.updateAll().then((_) => onSearchValueChanged());
            }),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
    );
  }

  static const tokenizer2uiString = {
    Tokenizer.jieba: "结巴",
    Tokenizer.simple: "Simple"
  };
  Tokenizer tokenizer = tokenizer2uiString.keys.first;

  static const implement2uiString = {
    DbImplement.sqlite3: "sqlite3",
    DbImplement.sqfliteCommonFfi: "sqflite_common_ffi",
  };
  DbImplement dbImplement = implement2uiString.keys.first;

  /// 搜索结果
  Widget buildListView() {
    return ListView.builder(
      itemCount: results!.length,
      itemBuilder: (context, index) {
        final r = results![index];
        return InkWell(
          onTap: () => showDialog(
              context: context, builder: (context) => buildDialog(context, r)),
          child: Ink(
            padding: const EdgeInsets.only(
                left: P.middle,
                right: P.middle,
                top: P.extraSmall,
                bottom: P.extraSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: dao.selectCount(),
                    builder: (context, snapshot) => snapshot.data == null
                        ? const SizedBox()
                        : Text(
                            "${r.id}".padLeft("${snapshot.data}".length, "0"),
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                fontFeatures: [
                                  FontFeature.tabularFigures()
                                ]), // 数字等宽
                          )),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ExtendedText(
                                  r.title,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                  specialTextSpanBuilder: highlightTextBuilder,
                                ),
                              ],
                            ),
                            ExtendedText(
                              r.content,
                              specialTextSpanBuilder: highlightTextBuilder,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${r.insertDate}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 对话框
  AlertDialog buildDialog(BuildContext context, MainTableRow r) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(P.middle),
    );
  }

  final highlightTextBuilder =
      HighlightTextSpanBuilder((src) => src.copyWith(color: Colors.red));
}

enum DbImplement { sqlite3, sqfliteCommonFfi }

class P {
  static const middle = 16.0;
  static const small = 8.0;
  static const extraSmall = 4.0;
}
