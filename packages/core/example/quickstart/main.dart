import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_simple_core/sqlite3_simple_core.dart';

void main() {
  sqlite3.loadSimpleExtension();
  final db = sqlite3.openInMemory();
  final tokens = db.select("SELECT simple_query('拼音全文搜索测试')");
  print('分词结果: $tokens');
  db.close();
}
