import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart' hide Table;

extension VT<TableDsl extends Table, D> on VirtualTableInfo<TableDsl, D> {
  Expression<int> get fts5RowId => const CustomExpression("rowid");

  Expression<bool> match<T extends Object>(Expression<T> expr) =>
      VirtualTableMatch(this, expr);
}

class VirtualTableMatch<TableDsl extends Table, D, T extends Object>
    extends Expression<bool> {
  final VirtualTableInfo<TableDsl, D> table;
  final Expression<T> expr;

  @protected
  VirtualTableMatch(this.table, this.expr);

  @override
  void writeInto(GenerationContext context) {
    context.buffer.write("${table.actualTableName} MATCH ");
    expr.writeInto(context);
  }
}

abstract class AbstractQuery extends Expression<String> {
  @protected
  abstract final String queryPrefix;
  final String value;

  AbstractQuery(this.value);

  @override
  void writeInto(GenerationContext context) {
    context.buffer.write("${queryPrefix}_query(");
    Variable.withString(value).writeInto(context);
    context.buffer.write(")");
  }
}

class SimpleQuery extends AbstractQuery {
  @override
  String queryPrefix = "simple";

  SimpleQuery(super.value);
}

class JiebaQuery extends AbstractQuery {
  @override
  String queryPrefix = "jieba";

  JiebaQuery(super.value);
}

class Highlight<TableDsl extends Table, D> extends Expression<String> {
  @protected
  final String highlightPrefix = "";

  final TableInfo<TableDsl, D> table;
  final int columnIndex;
  final String start;
  final String end;

  Highlight({
    required this.table,
    required this.columnIndex,
    required this.start,
    required this.end,
  });

  @override
  void writeInto(GenerationContext context) {
    if (highlightPrefix.isNotEmpty) {
      context.buffer.write("${highlightPrefix}_");
    }
    context.buffer.write("highlight(${table.actualTableName}, $columnIndex, ");
    Constant(start).writeInto(context);
    context.buffer.write(", ");
    Constant(end).writeInto(context);
    context.buffer.write(")");
  }
}

class SimpleHighlight<TableDsl extends Table, D>
    extends Highlight<TableDsl, D> {
  @override
  String get highlightPrefix => "simple";

  SimpleHighlight({
    required super.table,
    required super.columnIndex,
    required super.start,
    required super.end,
  });
}
