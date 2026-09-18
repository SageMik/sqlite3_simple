import 'package:drift/drift.dart';

part 'database.g.dart';

class Main extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get content => text()();

  DateTimeColumn get insertDate => dateTime()();
}

@DriftDatabase(tables: [Main], include: {"table.drift"})
class AppDatabase extends _$AppDatabase {
  @override
  int schemaVersion = 1;

  AppDatabase(super.e);

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      super.allSchemaEntities + buildFts5Triggers();

  /// 触发器
  List<Trigger> buildFts5Triggers() {
    final fts5Table = t1.actualTableName;
    final mainTable = main.actualTableName;
    final id = main.id.name;
    final title = main.title.name;
    final content = main.content.name;
    final insertDate = main.insertDate.name;
    final newInsert = '''
      INSERT INTO $fts5Table(rowid, $title, $content, $insertDate) 
        VALUES (new.$id, new.$title, new.$content, new.$insertDate);
    ''';
    final deleteInsert = '''
      INSERT INTO $fts5Table($fts5Table, rowid, $title, $content, $insertDate) 
        VALUES ('delete', old.$id, old.$title, old.$content, old.$insertDate);
    ''';
    return [
      Trigger('''
        CREATE TRIGGER ${mainTable}_insert AFTER INSERT ON $mainTable BEGIN 
          $newInsert
        END;
    ''', "${mainTable}_insert"),
      Trigger('''
        CREATE TRIGGER ${mainTable}_delete AFTER DELETE ON $mainTable BEGIN 
          $deleteInsert
        END;
    ''', "${mainTable}_delete"),
      Trigger('''
        CREATE TRIGGER ${mainTable}_update AFTER UPDATE ON $mainTable BEGIN 
          $deleteInsert
          $newInsert
        END;
    ''', "${mainTable}_update")
    ];
  }
}