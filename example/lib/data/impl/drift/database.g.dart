// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class T1 extends Table
    with TableInfo<T1, T1Data>, VirtualTableInfo<T1, T1Data> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  T1(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  static const VerificationMeta _insertDateMeta =
      const VerificationMeta('insertDate');
  late final GeneratedColumn<String> insertDate = GeneratedColumn<String>(
      'insert_date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [title, content, insertDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't1';
  @override
  VerificationContext validateIntegrity(Insertable<T1Data> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('insert_date')) {
      context.handle(
          _insertDateMeta,
          insertDate.isAcceptableOrUnknown(
              data['insert_date']!, _insertDateMeta));
    } else if (isInserting) {
      context.missing(_insertDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  T1Data map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return T1Data(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      insertDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}insert_date'])!,
    );
  }

  @override
  T1 createAlias(String alias) {
    return T1(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, content, insert_date UNINDEXED, tokenize = \'simple\', content = \'main\', content_rowid = \'id\')';
}

class T1Data extends DataClass implements Insertable<T1Data> {
  final String title;
  final String content;
  final String insertDate;
  const T1Data(
      {required this.title, required this.content, required this.insertDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['insert_date'] = Variable<String>(insertDate);
    return map;
  }

  T1Companion toCompanion(bool nullToAbsent) {
    return T1Companion(
      title: Value(title),
      content: Value(content),
      insertDate: Value(insertDate),
    );
  }

  factory T1Data.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return T1Data(
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      insertDate: serializer.fromJson<String>(json['insert_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'insert_date': serializer.toJson<String>(insertDate),
    };
  }

  T1Data copyWith({String? title, String? content, String? insertDate}) =>
      T1Data(
        title: title ?? this.title,
        content: content ?? this.content,
        insertDate: insertDate ?? this.insertDate,
      );
  T1Data copyWithCompanion(T1Companion data) {
    return T1Data(
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      insertDate:
          data.insertDate.present ? data.insertDate.value : this.insertDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('T1Data(')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('insertDate: $insertDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, content, insertDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is T1Data &&
          other.title == this.title &&
          other.content == this.content &&
          other.insertDate == this.insertDate);
}

class T1Companion extends UpdateCompanion<T1Data> {
  final Value<String> title;
  final Value<String> content;
  final Value<String> insertDate;
  final Value<int> rowid;
  const T1Companion({
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.insertDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  T1Companion.insert({
    required String title,
    required String content,
    required String insertDate,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        content = Value(content),
        insertDate = Value(insertDate);
  static Insertable<T1Data> custom({
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? insertDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (insertDate != null) 'insert_date': insertDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  T1Companion copyWith(
      {Value<String>? title,
      Value<String>? content,
      Value<String>? insertDate,
      Value<int>? rowid}) {
    return T1Companion(
      title: title ?? this.title,
      content: content ?? this.content,
      insertDate: insertDate ?? this.insertDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (insertDate.present) {
      map['insert_date'] = Variable<String>(insertDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('T1Companion(')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('insertDate: $insertDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MainTable extends Main with TableInfo<$MainTable, MainData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MainTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _insertDateMeta =
      const VerificationMeta('insertDate');
  @override
  late final GeneratedColumn<DateTime> insertDate = GeneratedColumn<DateTime>(
      'insert_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, content, insertDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'main';
  @override
  VerificationContext validateIntegrity(Insertable<MainData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('insert_date')) {
      context.handle(
          _insertDateMeta,
          insertDate.isAcceptableOrUnknown(
              data['insert_date']!, _insertDateMeta));
    } else if (isInserting) {
      context.missing(_insertDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MainData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MainData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      insertDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}insert_date'])!,
    );
  }

  @override
  $MainTable createAlias(String alias) {
    return $MainTable(attachedDatabase, alias);
  }
}

class MainData extends DataClass implements Insertable<MainData> {
  final int id;
  final String title;
  final String content;
  final DateTime insertDate;
  const MainData(
      {required this.id,
      required this.title,
      required this.content,
      required this.insertDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['insert_date'] = Variable<DateTime>(insertDate);
    return map;
  }

  MainCompanion toCompanion(bool nullToAbsent) {
    return MainCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      insertDate: Value(insertDate),
    );
  }

  factory MainData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MainData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      insertDate: serializer.fromJson<DateTime>(json['insertDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'insertDate': serializer.toJson<DateTime>(insertDate),
    };
  }

  MainData copyWith(
          {int? id, String? title, String? content, DateTime? insertDate}) =>
      MainData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        insertDate: insertDate ?? this.insertDate,
      );
  MainData copyWithCompanion(MainCompanion data) {
    return MainData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      insertDate:
          data.insertDate.present ? data.insertDate.value : this.insertDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MainData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('insertDate: $insertDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, content, insertDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MainData &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.insertDate == this.insertDate);
}

class MainCompanion extends UpdateCompanion<MainData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime> insertDate;
  const MainCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.insertDate = const Value.absent(),
  });
  MainCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    required DateTime insertDate,
  })  : title = Value(title),
        content = Value(content),
        insertDate = Value(insertDate);
  static Insertable<MainData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? insertDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (insertDate != null) 'insert_date': insertDate,
    });
  }

  MainCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? content,
      Value<DateTime>? insertDate}) {
    return MainCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      insertDate: insertDate ?? this.insertDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (insertDate.present) {
      map['insert_date'] = Variable<DateTime>(insertDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MainCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('insertDate: $insertDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final T1 t1 = T1(this);
  late final $MainTable main = $MainTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [t1, main];
}

typedef $T1CreateCompanionBuilder = T1Companion Function({
  required String title,
  required String content,
  required String insertDate,
  Value<int> rowid,
});
typedef $T1UpdateCompanionBuilder = T1Companion Function({
  Value<String> title,
  Value<String> content,
  Value<String> insertDate,
  Value<int> rowid,
});

class $T1FilterComposer extends Composer<_$AppDatabase, T1> {
  $T1FilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => ColumnFilters(column));
}

class $T1OrderingComposer extends Composer<_$AppDatabase, T1> {
  $T1OrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => ColumnOrderings(column));
}

class $T1AnnotationComposer extends Composer<_$AppDatabase, T1> {
  $T1AnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => column);
}

class $T1TableManager extends RootTableManager<
    _$AppDatabase,
    T1,
    T1Data,
    $T1FilterComposer,
    $T1OrderingComposer,
    $T1AnnotationComposer,
    $T1CreateCompanionBuilder,
    $T1UpdateCompanionBuilder,
    (T1Data, BaseReferences<_$AppDatabase, T1, T1Data>),
    T1Data,
    PrefetchHooks Function()> {
  $T1TableManager(_$AppDatabase db, T1 table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $T1FilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $T1OrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $T1AnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> insertDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              T1Companion(
            title: title,
            content: content,
            insertDate: insertDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String content,
            required String insertDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              T1Companion.insert(
            title: title,
            content: content,
            insertDate: insertDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $T1ProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    T1,
    T1Data,
    $T1FilterComposer,
    $T1OrderingComposer,
    $T1AnnotationComposer,
    $T1CreateCompanionBuilder,
    $T1UpdateCompanionBuilder,
    (T1Data, BaseReferences<_$AppDatabase, T1, T1Data>),
    T1Data,
    PrefetchHooks Function()>;
typedef $$MainTableCreateCompanionBuilder = MainCompanion Function({
  Value<int> id,
  required String title,
  required String content,
  required DateTime insertDate,
});
typedef $$MainTableUpdateCompanionBuilder = MainCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> content,
  Value<DateTime> insertDate,
});

class $$MainTableFilterComposer extends Composer<_$AppDatabase, $MainTable> {
  $$MainTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => ColumnFilters(column));
}

class $$MainTableOrderingComposer extends Composer<_$AppDatabase, $MainTable> {
  $$MainTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => ColumnOrderings(column));
}

class $$MainTableAnnotationComposer
    extends Composer<_$AppDatabase, $MainTable> {
  $$MainTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get insertDate => $composableBuilder(
      column: $table.insertDate, builder: (column) => column);
}

class $$MainTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MainTable,
    MainData,
    $$MainTableFilterComposer,
    $$MainTableOrderingComposer,
    $$MainTableAnnotationComposer,
    $$MainTableCreateCompanionBuilder,
    $$MainTableUpdateCompanionBuilder,
    (MainData, BaseReferences<_$AppDatabase, $MainTable, MainData>),
    MainData,
    PrefetchHooks Function()> {
  $$MainTableTableManager(_$AppDatabase db, $MainTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MainTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MainTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MainTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> insertDate = const Value.absent(),
          }) =>
              MainCompanion(
            id: id,
            title: title,
            content: content,
            insertDate: insertDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String content,
            required DateTime insertDate,
          }) =>
              MainCompanion.insert(
            id: id,
            title: title,
            content: content,
            insertDate: insertDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MainTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MainTable,
    MainData,
    $$MainTableFilterComposer,
    $$MainTableOrderingComposer,
    $$MainTableAnnotationComposer,
    $$MainTableCreateCompanionBuilder,
    $$MainTableUpdateCompanionBuilder,
    (MainData, BaseReferences<_$AppDatabase, $MainTable, MainData>),
    MainData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $T1TableManager get t1 => $T1TableManager(_db, _db.t1);
  $$MainTableTableManager get main => $$MainTableTableManager(_db, _db.main);
}
