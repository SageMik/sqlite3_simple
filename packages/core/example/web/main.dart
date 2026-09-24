import 'dart:convert';
import 'dart:js_interop';

import 'package:http/http.dart';
import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple_core/jieba_dict_type.dart';
import 'package:sqlite3_simple_core/web.dart';
import 'package:sqlite3_simple_core_example/db_manager.dart';
import 'package:sqlite3_simple_core_example/search_result.dart';
import 'package:web/web.dart';

Future<void> main() async {
  final input = document.querySelector('#query')! as HTMLInputElement;
  final tokenizeInfo = document.querySelector('#tokenize')! as HTMLElement;
  final result = document.querySelector('#result')! as HTMLElement;
  final status = document.querySelector('#status')! as HTMLElement;

  final DbManager dbManager;
  try {
    dbManager = await DbManager.create(() async {
      /// 打开数据库
      final loader = DefaultSimpleWasmModuleLoader();
      final sqlite = await WasmSqlite3.loadFromUrl(
        Uri.parse('sqlite3.wasm'),
        loader: loader,
      );
      sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
      final db = sqlite.open('db');

      /// 将结巴分词文件加载到数据库可以访问的 WASM 内存中
      const jiebaDictDir = 'cpp_jieba_dict';
      final jiebaDictBytes = {
        for (final type in JiebaDictType.values)
          "$jiebaDictDir/${type.filename}": await readBytes(
            Uri.parse("$jiebaDictDir/${type.filename}"),
          ),
      };
      loader.updateFiles((it) => it..addAll(jiebaDictBytes));
      db.execute("SELECT jieba_dict(?)", [jiebaDictDir]);

      return db;
    });
  } catch (e) {
    status.showMessage('加载失败：$e');
    return;
  }

  input.onInput.listen((_) async {
    final query = input.value.trim();
    final SearchResult searchResult;
    try {
      searchResult = await dbManager.searchByJieba(query);
    } catch (e) {
      result.showMessage('查询失败：$e');
      return;
    }

    tokenizeInfo.textContent = '分词结果：${searchResult.tokens}';
    result.innerHTML =
        (searchResult.rows.isEmpty
                ? '<p class="empty">没有匹配的结果</p>'
                : [
                    for (final row in searchResult.rows)
                      '<article>'
                          '<h2>${row.title.highlighted}</h2>'
                          '<p>${row.content.highlighted}</p>'
                          '</article>',
                  ].join())
            .toJS;
  });

  status.remove();
  input
    ..disabled = false
    ..value = 'sqlite'
    ..dispatchEvent(Event('input'));
}

extension on HTMLElement {
  void showMessage(String text) =>
      innerHTML = '<p class="empty">${text.highlighted}</p>'.toJS;
}

extension on String {
  String get highlighted => HtmlEscape()
      .convert(this)
      .replaceAll(ZeroWidth.start, '<mark>')
      .replaceAll(ZeroWidth.end, '</mark>');
}
