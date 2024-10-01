import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:path/path.dart';
import 'package:sqlite3_simple_example/util/custom_text.dart';
import 'package:sqlite3_simple_example/util/zero_width_text.dart';

import 'dao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  late final Dao dao;
  List<MainTableRow>? results;

  Future<void> initPlatformState() async {
    final docDir = await getApplicationDocumentsDirectory();
    final jiebaDictPath = join(docDir.path, "cpp_jieba");
    dao = Dao(() => sqlite3.openInMemory());
    await dao.init(jiebaDictPath);
    setState(() {
      dao.insertRandomData(30);
      results = dao.selectAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
              children: [
                TapRegion(
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  child: SearchBar(
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.search),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(height: 16),
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

  Widget buildListView() {
    final highlightTextBuilder = CustomTextBuilder([
      ZeroWidthText(
        const TextStyle(color: Colors.red),
      )
    ]);
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
                  fontFeatures: [FontFeature.tabularFigures()]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExtendedText(
                      r.title,
                      style: const TextStyle(fontSize: 20),
                      specialTextSpanBuilder: highlightTextBuilder,
                    ),
                    ExtendedText(
                      r.content,
                      specialTextSpanBuilder: highlightTextBuilder,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onSearchChanged(String value) {
    value = value.trim();
    setState(() {
      if (value.isEmpty) {
        results = dao.selectAll();
        return;
      }
      results = dao.selectJieba(value);
    });
  }
}
