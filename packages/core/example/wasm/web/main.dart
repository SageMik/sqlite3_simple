import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_simple_core/web.dart';
import 'package:web/web.dart';

const _demoData = [
  (
    'Simple',
    '由 @wangfenjin 开发的 SQLite FTS5 全文搜索扩展，支持中文和拼音搜索，'
        '提供 simple_query、jieba_query、simple_highlight 等查询辅助函数，开箱即用。',
  ),
  (
    'FTS5',
    'SQLite 内置的第五代全文检索引擎，是一个为数据库应用提供全文搜索功能的虚拟表模块。'
        '基于倒排索引实现高效的文本匹配，并支持通过 tokenize 选项接入自定义分词器。',
  ),
  (
    'Dart Hooks',
    'Dart 官方的构建钩子机制，允许包在应用构建期通过 build hook 编译或获取'
        '原生资产（native assets），并在构建产物中自动打包分发。',
  ),
  (
    'sqlite3_web',
    'sqlite3.dart 官方仓库提供的 Web 适配库，基于 WebAssembly 构建，'
        '通过 Web Worker 提供异步数据库 API，并支持 OPFS、IndexedDB 等持久化文件系统。',
  ),
];

const markStart = '<mark>';
const markEnd = '</mark>';
final markPattern = RegExp(
  '${RegExp.escape(markStart)}|${RegExp.escape(markEnd)}',
);

Future<void> main() async {
  final input = document.querySelector('#query')! as HTMLInputElement;
  final tokenizeInfo = document.querySelector('#tokenize')! as HTMLElement;
  final result = document.querySelector('#result')! as HTMLElement;
  final status = document.querySelector('#status')! as HTMLElement;

  /// 打开内存数据库
  final CommonDatabase db;
  try {
    final sqlite = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
      loader: DefaultSimpleWasmModuleLoader(),
    );
    sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
    db = sqlite.open('/demo.db');
  } catch (e) {
    status.textContent = '加载失败：$e';
    return;
  }

  /// 插入示例数据
  db.execute(
    "CREATE VIRTUAL TABLE demo USING fts5(title, content, tokenize = 'simple');",
  );
  final insert = db.prepare('INSERT INTO demo(title, content) VALUES (?, ?);');
  for (final (title, content) in _demoData) {
    insert.execute([title, content]);
  }
  insert.close();

  /// 监听输入，渲染搜索结果
  input.onInput.listen((_) {
    final query = input.value.trim();
    try {
      final rows = query.isEmpty
          ? db.select('SELECT title, content FROM demo')
          : db.select(
              '''
              SELECT
                simple_highlight(demo, 0, '$markStart', '$markEnd') AS title,
                simple_highlight(demo, 1, '$markStart', '$markEnd') AS content
              FROM demo
              WHERE demo MATCH simple_query(?);
              ''',
              [query],
            );
      final tokens = query.isEmpty
          ? ''
          : '${db.select('SELECT simple_query(?) AS q', [query]).first['q']}';

      tokenizeInfo.textContent = '分词结果：$tokens';
      result.textContent = '';
      if (rows.isEmpty) {
        message(result, '没有匹配的结果');
        return;
      }
      for (final row in rows) {
        final article = document.createElement('article');
        final title = document.createElement('h2');
        final content = document.createElement('p');
        highlight(title, row['title'] as String);
        highlight(content, row['content'] as String);
        article.append(title);
        article.append(content);
        result.append(article);
      }
    } catch (e) {
      message(result, '查询失败：$e');
    }
  });

  /// 初始搜索
  status.remove();
  input.disabled = false;
  input.value = 'sqlite';
  input.dispatchEvent(Event('input'));
}

void message(HTMLElement target, String text) {
  target.textContent = '';
  target.append(
    document.createElement('p')
      ..className = 'empty'
      ..textContent = text,
  );
}

/// 用 DOM 节点渲染高亮片段，避免 `innerHTML` 带来的注入风险。
///
/// 按标签切开后，偶数段是普通文本，奇数段是命中片段。
void highlight(Element target, String text) {
  final parts = text.split(markPattern);
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    if (i.isOdd) {
      target.append(document.createElement('mark')..textContent = parts[i]);
    } else {
      target.append(document.createTextNode(parts[i]));
    }
  }
}
