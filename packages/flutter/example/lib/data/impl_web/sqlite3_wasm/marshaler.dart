import 'package:squadron/squadron.dart';

import '../../main_table_dao.dart';
import '../../main_table_row.dart';

/// [MainTableRow] 的 Web Worker 传输序列化
extension MainTableRowSquadronMarshaling on MainTableRow {
  List<dynamic> marshal() => <dynamic>[
        id,
        title,
        content,
        insertDate.toDb(),
      ];

  static MainTableRow unmarshal(List data, [MarshalingContext? context]) {
    final id = context?.converter.value<int>()(data[0]) ?? data[0] as int;
    final title = data[1] as String;
    final content = data[2] as String;
    final insertDate =
        context?.converter.value<int>()(data[3]) ?? data[3] as int;
    return MainTableRow(
      id: id,
      title: title,
      content: content,
      insertDate: insertDate.toEntity(),
    );
  }
}

/// [SearchResult] 的 Web Worker 传输序列化：`[tokens, rows, elapsedMicros]`
extension SearchResultSquadronMarshaling on SearchResult {
  List<dynamic> marshal() => <dynamic>[
        tokens,
        [for (final row in rows) row.marshal()],
        elapsed.inMicroseconds,
      ];

  static SearchResult unmarshal(List data, [MarshalingContext? context]) {
    final tokens =
        context?.converter.value<String>()(data[0]) ?? data[0] as String;
    final elapsedMicros =
        context?.converter.value<int>()(data[2]) ?? data[2] as int;
    return SearchResult(
      tokens: tokens,
      rows: [
        for (final row in data[1] as List)
          MainTableRowSquadronMarshaling.unmarshal(row as List, context),
      ],
      elapsed: Duration(microseconds: elapsedMicros),
    );
  }
}
