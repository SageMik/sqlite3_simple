import 'main_table_row.dart';

class SearchResult {
  /// 匹配行
  final List<MainTableRow> rows;

  /// 分词结果
  final String tokens;

  /// 搜索耗时
  final Duration elapsed;

  const SearchResult({required this.rows, required this.tokens, required this.elapsed});
}

class SearchResultUiModel {
  /// 匹配行
  final List<MainTableRowUiModel> rows;

  /// 分词结果
  final String tokens;

  /// 搜索耗时
  final Duration elapsed;

  /// 实际执行的查询词，空串表示列出全部
  final String query;

  /// 主表总行数
  final int totalCount;

  const SearchResultUiModel({
    required this.rows,
    required this.tokens,
    required this.elapsed,
    required this.query,
    required this.totalCount,
  });

  /// 是否有关键词
  bool get hasQuery => query.isNotEmpty;

  /// 匹配数量
  int get matchCount => rows.length;

  /// 耗时的展示文本：≥100ms 取整，否则保留一位小数
  String get elapsedText {
    final ms = elapsed.inMicroseconds / 1000.0;
    return ms >= 100 ? ms.toStringAsFixed(0) : ms.toStringAsFixed(1);
  }
}
