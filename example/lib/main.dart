import 'dart:async';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

class _MyAppState extends State<MyApp> {
  late final Sqlite3DbManger dbManager;

  Sqlite3Dao get dao => dbManager.dao;

  List<MainTableRow>? results;

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
    dbManager = Sqlite3DbManger()
      ..init().then((_) {
        setState(() {
          dao.insertRandomData(30);
          results = dao.selectAll();
        });
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
      supportedLocales: const [
        Locale('zh', 'CN'), // 通过国际化设置中文环境以让 Flutter 使用正确的中文字体
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('测试'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildSearchBar(),
                buildSearchFilter(),
                const SizedBox(height: 8),
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
      ),
    );
  }

  static const tokenizer2uiString = {
    Tokenizer.jieba: "结巴",
    Tokenizer.simple: "Simple"
  };
  Tokenizer tokenizer = tokenizer2uiString.keys.first;

  void onSearchChanged() {
    setState(() {
      final value = searchController.text.trim();
      showClearButton = value.isNotEmpty;
      results =
          showClearButton ? dao.search(value, tokenizer) : dao.selectAll();
    });
  }

  Future<void> onUpdatePressed() async {
    setState(() {
      results = null;
    });
    dao.updateAll();
    onSearchChanged();
  }

  final searchController = SearchController();
  var showClearButton = false;

  Widget buildSearchBar() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
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
                      onPressed: () {
                        searchController.text = "";
                      },
                      icon: const Icon(Icons.clear))
              ],
              elevation: const WidgetStatePropertyAll(0),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSearchFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text(
              "分词器：",
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<Tokenizer>(
              value: tokenizer,
              items: tokenizer2uiString.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  tokenizer = value!;
                  onSearchChanged();
                });
              },
            ),
          ],
        ),
        const SizedBox(width: 8),
        const Expanded(child: SizedBox()),
        IconButton(
          style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)))),
          onPressed: onUpdatePressed,
          icon: const Icon(Icons.refresh),
        )
      ],
    );
  }

  final highlightTextBuilder =
      HighlightTextSpanBuilder((src) => src.copyWith(color: Colors.red));

  Widget buildListView() {
    return ListView.builder(
      itemCount: results!.length,
      itemBuilder: (context, index) {
        final r = results![index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${r.id}".padLeft("${dao.selectCount()}".length, "0"),
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()]), // 数字等宽
            ),
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
                              style: const TextStyle(fontSize: 20),
                              specialTextSpanBuilder: highlightTextBuilder,
                            ),
                          ],
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
                        r.insertDate.toString(),
                        textAlign: TextAlign.end,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
