class MainTableRow {
  /// ID
  final int id;

  /// 标题
  final String title;

  /// 内容
  final String content;

  /// 插入时间
  final DateTime insertDate;

  const MainTableRow({
    required this.id,
    required this.title,
    required this.content,
    required this.insertDate,
  });
}


extension IntEx on int {
  DateTime get toEntity => DateTime.fromMicrosecondsSinceEpoch(this);
}

extension DateTimeEx on DateTime {
  int get toDb => microsecondsSinceEpoch;
}

