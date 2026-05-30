import 'package:drift/drift.dart';

extension DatabaseConnectionUserEx on DatabaseConnectionUser {
  Fts5InsertStatement<T, D> intoFts5<T extends VirtualTableInfo, D>(
      VirtualTableInfo<T, D> table,
      ) => Fts5InsertStatement(this, table);
}

class Fts5InsertStatement<T extends VirtualTableInfo, D>
    extends InsertStatement<T, D> {
  Fts5InsertStatement(super.database, super.table);

  /// 重建索引
  Future<int> rebuild() {
    final tableName = table.actualTableName;
    return database.customInsert(
      "INSERT INTO $tableName($tableName) VALUES('rebuild');",
    );
  }
}