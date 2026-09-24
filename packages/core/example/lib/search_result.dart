class ZeroWidth {
  ZeroWidth._();

  static const start = "\u200B";
  static const end = "\u200C";
}

class SearchRow {
  final String title;
  final String content;
  const SearchRow({required this.title, required this.content});
}

class SearchResult {
  final String tokens;
  final List<SearchRow> rows;

  const SearchResult({required this.tokens, required this.rows});
}