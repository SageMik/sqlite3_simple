import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

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