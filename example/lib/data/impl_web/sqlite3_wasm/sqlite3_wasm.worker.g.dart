// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'sqlite3_wasm.dart';

// **************************************************************************
// Generator: WorkerGenerator 9.0.0+2 (Squadron 7.4.3)
// **************************************************************************

// dart format width=80
/// Command ids used in operations map
const int _$closeDatabaseId = 1;
const int _$initDatabaseId = 2;
const int _$initFts5Id = 3;
const int _$insertRandomDataId = 4;
const int _$searchId = 5;
const int _$selectAllId = 6;
const int _$selectCountId = 7;
const int _$updateAllId = 8;

/// WorkerService operations for Sqlite3Wasm
extension on Sqlite3Wasm {
  OperationsMap _$getOperations() => OperationsMap({
    _$closeDatabaseId: ($req) => closeDatabase(),
    _$initDatabaseId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return initDatabase($dsr.$2($req.args[0]));
    },
    _$initFts5Id: ($req) => initFts5(),
    _$insertRandomDataId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return insertRandomData($dsr.$3($req.args[0]));
    },
    _$searchId: ($req) async {
      final List<MainTableRow> $res;
      try {
        final $dsr = _$Deser(contextAware: false);
        $res = await search($dsr.$0($req.args[0]), $dsr.$4($req.args[1]));
      } finally {}
      return $res;
    },
    _$selectAllId: ($req) => selectAll(),
    _$selectCountId: ($req) => selectCount(),
    _$updateAllId: ($req) => updateAll(),
  });
}

/// Invoker for Sqlite3Wasm, implements the public interface to invoke the
/// remote service.
base mixin _$Sqlite3Wasm$Invoker on Invoker implements Sqlite3Wasm {
  @override
  Future<void> closeDatabase() => send(_$closeDatabaseId);

  @override
  Future<void> initDatabase(Map<String, Uint8List> files) =>
      send(_$initDatabaseId, args: [files]);

  @override
  Future<void> initFts5() => send(_$initFts5Id);

  @override
  Future<void> insertRandomData(int length) =>
      send(_$insertRandomDataId, args: [length]);

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    final dynamic $res;
    try {
      final $sr = _$Ser(contextAware: false);
      $res = await send(_$searchId, args: [value, $sr.$0(tokenizer)]);
    } finally {}
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$6($res);
    } finally {}
  }

  @override
  Future<List<MainTableRow>> selectAll() async {
    final dynamic $res = await send(_$selectAllId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$6($res);
    } finally {}
  }

  @override
  Future<int> selectCount() async {
    final dynamic $res = await send(_$selectCountId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$3($res);
    } finally {}
  }

  @override
  Future<void> updateAll() => send(_$updateAllId);
}

/// Facade for Sqlite3Wasm, implements other details of the service unrelated to
/// invoking the remote service.
base mixin _$Sqlite3Wasm$Facade implements Sqlite3Wasm {
  @override
  MainTableRow buildRow(int index) => throw UnimplementedError();

  @override
  // ignore: unused_element
  Sqlite3Dao get dao => throw UnimplementedError();

  @override
  // ignore: unused_element
  CommonDatabase get db => throw UnimplementedError();

  @override
  // ignore: unused_element
  WasmSqlite3 get _wasmSqlite3 => throw UnimplementedError();

  @override
  // ignore: unused_element
  InMemoryFileSystem get _inMemoryFileSystem => throw UnimplementedError();

  @override
  // ignore: unused_element
  set dao(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _wasmSqlite3(void $value) => throw UnimplementedError();
}

/// WorkerClient for Sqlite3Wasm
final class $Sqlite3Wasm$Client extends WorkerClient
    with _$Sqlite3Wasm$Invoker, _$Sqlite3Wasm$Facade
    implements Sqlite3Wasm {
  $Sqlite3Wasm$Client(PlatformChannel channelInfo)
    : super(Channel.deserialize(channelInfo)!);
}

/// Local worker extension for Sqlite3Wasm
extension $Sqlite3WasmLocalWorkerExt on Sqlite3Wasm {
  // Get a fresh local worker instance.
  LocalWorker<Sqlite3Wasm> getLocalWorker([
    ExceptionManager? exceptionManager,
  ]) => LocalWorker.create(this, _$getOperations(), exceptionManager);
}

/// WorkerService class for Sqlite3Wasm
base class _$Sqlite3Wasm$WorkerService extends Sqlite3Wasm
    implements WorkerService {
  _$Sqlite3Wasm$WorkerService() : super();

  @override
  OperationsMap get operations => _$getOperations();
}

/// Service initializer for Sqlite3Wasm
WorkerService $Sqlite3WasmInitializer(WorkerRequest $req) =>
    _$Sqlite3Wasm$WorkerService();

/// Worker for Sqlite3Wasm
base class Sqlite3WasmWorker extends Worker
    with _$Sqlite3Wasm$Invoker, _$Sqlite3Wasm$Facade
    implements Sqlite3Wasm {
  Sqlite3WasmWorker({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $Sqlite3WasmActivator(Squadron.platformType),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  Sqlite3WasmWorker.js({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $Sqlite3WasmActivator(SquadronPlatformType.js),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  @override
  List? getStartArgs() => null;
}

/// Worker pool for Sqlite3Wasm
base class Sqlite3WasmWorkerPool extends WorkerPool<Sqlite3WasmWorker>
    with _$Sqlite3Wasm$Facade
    implements Sqlite3Wasm {
  Sqlite3WasmWorkerPool({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => Sqlite3WasmWorker(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  Sqlite3WasmWorkerPool.js({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => Sqlite3WasmWorker.js(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  @override
  Future<void> closeDatabase() => execute((w) => w.closeDatabase());

  @override
  Future<void> initDatabase(Map<String, Uint8List> files) =>
      execute((w) => w.initDatabase(files));

  @override
  Future<void> initFts5() => execute((w) => w.initFts5());

  @override
  Future<void> insertRandomData(int length) =>
      execute((w) => w.insertRandomData(length));

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      execute((w) => w.search(value, tokenizer));

  @override
  Future<List<MainTableRow>> selectAll() => execute((w) => w.selectAll());

  @override
  Future<int> selectCount() => execute((w) => w.selectCount());

  @override
  Future<void> updateAll() => execute((w) => w.updateAll());
}

final class _$Deser extends MarshalingContext {
  _$Deser({super.contextAware});
  late final $0 = value<String>();
  late final $1 = value<Uint8List>();
  late final $2 = map<String, Uint8List>(kcast: $0, vcast: $1);
  late final $3 = value<int>();
  late final $4 = (($) => Tokenizer.values[$3($)]);
  late final $5 = value<MainTableRow>();
  late final $6 = list<MainTableRow>($5);
}

final class _$Ser extends MarshalingContext {
  _$Ser({super.contextAware});
  late final $0 = (($) => ($ as Tokenizer).index);
}
