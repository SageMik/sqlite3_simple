import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple_core/sqlite3_simple_core.dart';
import 'package:sqlite3_simple_core_example/db_manager.dart';
import 'package:sqlite3_simple_core_example/search_result.dart';
import 'package:termui/termui.dart';

import 'marked_text.dart';

/// 在 example 目录下执行如下命令以启动 TUI 示例
/// ```
/// dart run bin/main.dart
/// ```
Future<void> main() async {
  final DbManager dbManager;
  try {
    dbManager = await DbManager.create(() async {
      sqlite3.loadSimpleExtension();
      final db = sqlite3.openInMemory();

      const jiebaDictDir = '../../flutter/assets/cpp_jieba_dict';
      db.execute("SELECT jieba_dict(?)", [jiebaDictDir]);
      db.execute(
        "SELECT jieba_query('Jieba分词初始化（提前加载避免后续等待）')",
      );

      return db;
    });
  } catch (e) {
    stderr.writeln('加载失败：$e');
    return;
  }

  final scrollController = DiscreteScrollController();
  await Terminal.runGuarded((terminal) async {
    await PromptRunner<void>(
      terminal: terminal,
      alternateScreen: true,
      widget: SearchView(
        terminal: terminal,
        dbManager: dbManager,
        scrollController: scrollController,
      ),
      exitConditions: const {
        PromptExitTrigger.escape: PromptExitAction.cancel,
        PromptExitTrigger.controlC: PromptExitAction.cancel,
      },
      onKeyEvent: (event) {
        final delta = switch (event.type) {
          KeyType.up => -1,
          KeyType.down => 1,
          KeyType.pageUp => -10,
          KeyType.pageDown => 10,
          _ => null,
        };
        if (delta == null) return false;
        scrollController.scrollOffset += delta;
        return true;
      },
    ).run();
  });

  await dbManager.close();
  exit(0);
}

class SearchView extends StatefulWidget {
  final Terminal terminal;
  final DbManager dbManager;
  final DiscreteScrollController scrollController;

  const SearchView({
    required this.terminal,
    required this.dbManager,
    required this.scrollController,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  ({SearchResult? result, String? error}) _state = (result: null, error: null);

  @override
  void initState() {
    super.initState();
    widget.terminal.hideCursor(); // 隐藏末尾自带的光标
    _controller.addListener(_search);
    _search();
  }

  @override
  void dispose() {
    _controller.removeListener(_search);
    super.dispose();
  }

  Future<void> _search() async {
    try {
      final result = await widget.dbManager.searchByJieba(
        _controller.text.trim(),
      );
      if (!mounted) return;
      widget.scrollController.scrollOffset = 0;
      setState(() => _state = (result: result, error: null));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = (result: null, error: '查询失败：$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (:result, :error) = _state;

    final text = _controller.text;
    final empty = text.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Column([
        const Text(
          'sqlite3_simple_core · 终端 TUI 示例',
          style: Style(foreground: Colors.white, modifiers: Modifier.bold),
        ),
        const SizedBox(height: 1),
        SizedBox.shrink(child: TextField(controller: _controller)),
        MarkedText(
          empty ? '输入关键词或拼音进行搜索' : text,
          style: empty
              ? const Style(foreground: Color(128, 128, 128))
              : Style.empty,
          caret: empty ? 0 : _controller.value.selection.cursorColumn,
        ),
        const SizedBox(height: 1),
        Text(
          '分词结果：${result?.tokens ?? ''}',
          style: const Style(foreground: Colors.green),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (error != null) {
                return Text(error, style: const Style(foreground: Colors.red));
              }
              if (result == null || result.rows.isEmpty) {
                return const Text('没有匹配的结果');
              }

              final width = constraints.maxWidth;
              final cards = <Widget>[];
              var total = 0;
              for (final row in result.rows) {
                final title = MarkedText(
                  row.title,
                  style: const Style(modifiers: Modifier.bold),
                );
                final content = MarkedText(row.content);
                total +=
                    title.getIntrinsicHeight(width) +
                    content.getIntrinsicHeight(width) +
                    2;
                cards.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Column([title, content]),
                  ),
                );
              }

              return SingleChildScrollView(
                controller: widget.scrollController,
                childLength: total,
                child: Column(cards),
              );
            },
          ),
        ),
        const SizedBox(height: 1),
        const Text('[↑/↓] 滚动 · [Esc] 退出', style: Style(modifiers: Modifier.dim)),
      ]),
    );
  }
}
