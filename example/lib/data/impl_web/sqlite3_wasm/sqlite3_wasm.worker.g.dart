// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'sqlite3_wasm.dart';

// **************************************************************************
// Generator: WorkerGenerator 9.0.0+2 (Squadron 7.4.3)
// **************************************************************************

// dart format width=80
/// Command ids used in operations map
const int _$closeId = 1;
const int _$initWithJiebaDictId = 2;
const int _$insertRandomDataId = 3;
const int _$savePinyinDictId = 4;
const int _$searchId = 5;
const int _$selectAllId = 6;
const int _$selectCountId = 7;
const int _$updateAllId = 8;
const int _$updatePinyinDictId = 9;
const int _$updatePinyinKind2UrlId = 10;

/// WorkerService operations for Sqlite3Wasm
extension on Sqlite3Wasm {
  OperationsMap _$getOperations() => OperationsMap({
    _$closeId: ($req) => close(),
    _$initWithJiebaDictId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return initWithJiebaDict($dsr.$3($req.args[0]));
    },
    _$insertRandomDataId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return insertRandomData($dsr.$0($req.args[0]));
    },
    _$savePinyinDictId: ($req) async {
      final Map<PinyinDictKind, String> $res = await savePinyinDict();
      try {
        final $sr = _$Ser(contextAware: false);
        return $sr.$1($res);
      } finally {}
    },
    _$searchId: ($req) async {
      final List<MainTableRow> $res;
      try {
        final $dsr = _$Deser(contextAware: false);
        $res = await search($dsr.$2($req.args[0]), $dsr.$4($req.args[1]));
      } finally {}
      try {
        final $sr = _$Ser(contextAware: false);
        return $sr.$3($res);
      } finally {}
    },
    _$selectAllId: ($req) async {
      final List<MainTableRow> $res = await selectAll();
      try {
        final $sr = _$Ser(contextAware: false);
        return $sr.$3($res);
      } finally {}
    },
    _$selectCountId: ($req) => selectCount(),
    _$updateAllId: ($req) => updateAll(),
    _$updatePinyinDictId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return updatePinyinDict($dsr.$2($req.args[0]));
    },
    _$updatePinyinKind2UrlId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return updatePinyinKind2Url($dsr.$6($req.args[0]));
    },
  });
}

/// Invoker for Sqlite3Wasm, implements the public interface to invoke the
/// remote service.
mixin _$Sqlite3Wasm$Invoker on Invoker implements Sqlite3Wasm {
  @override
  Future<void> close() => send(_$closeId);

  @override
  Future<void> initWithJiebaDict(Map<JiebaDictType, String> jiebaDictPath2Url) {
    final $sr = _$Ser(contextAware: false);
    return send(_$initWithJiebaDictId, args: [$sr.$5(jiebaDictPath2Url)]);
  }

  @override
  Future<void> insertRandomData(int length) =>
      send(_$insertRandomDataId, args: [length]);

  @override
  Future<Map<PinyinDictKind, String>> savePinyinDict() async {
    final dynamic $res = await send(_$savePinyinDictId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$6($res);
    } finally {}
  }

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) async {
    final dynamic $res;
    try {
      final $sr = _$Ser(contextAware: false);
      $res = await send(_$searchId, args: [value, $sr.$6(tokenizer)]);
    } finally {}
    try {
      final $dsr = _$Deser(contextAware: true);
      return $dsr.$8($res);
    } finally {}
  }

  @override
  Future<List<MainTableRow>> selectAll() async {
    final dynamic $res = await send(_$selectAllId);
    try {
      final $dsr = _$Deser(contextAware: true);
      return $dsr.$8($res);
    } finally {}
  }

  @override
  Future<int> selectCount() async {
    final dynamic $res = await send(_$selectCountId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$0($res);
    } finally {}
  }

  @override
  Future<void> updateAll() => send(_$updateAllId);

  @override
  Future<void> updatePinyinDict(String newPath) =>
      send(_$updatePinyinDictId, args: [newPath]);

  @override
  Future<void> updatePinyinKind2Url(Map<PinyinDictKind, String> kind2url) {
    final $sr = _$Ser(contextAware: false);
    return send(_$updatePinyinKind2UrlId, args: [$sr.$1(kind2url)]);
  }
}

/// Facade for Sqlite3Wasm, implements other details of the service unrelated to
/// invoking the remote service.
mixin _$Sqlite3Wasm$Facade implements Sqlite3Wasm {
  @override
  Future<void> init() => throw UnimplementedError();

  @override
  Future<void> createMainAndFts5(CommonDatabase db) =>
      throw UnimplementedError();

  @override
  // ignore: unused_element
  Sqlite3Dao get _dao => throw UnimplementedError();

  @override
  // ignore: unused_element
  DefaultSimpleWasmModuleLoader get _loader => throw UnimplementedError();

  @override
  // ignore: unused_element
  WasmSqlite3 get _wasmSqlite3 => throw UnimplementedError();

  @override
  // ignore: unused_element
  InMemoryFileSystem get _inMemoryFileSystem => throw UnimplementedError();

  @override
  // ignore: unused_element
  Map<PinyinDictKind, String> get _kind2url => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _dao(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _loader(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _wasmSqlite3(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _kind2url(void $value) => throw UnimplementedError();
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
class _$Sqlite3Wasm$WorkerService extends Sqlite3Wasm implements WorkerService {
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
  Future<void> close() => execute((w) => w.close());

  @override
  Future<void> initWithJiebaDict(
    Map<JiebaDictType, String> jiebaDictPath2Url,
  ) => execute((w) => w.initWithJiebaDict(jiebaDictPath2Url));

  @override
  Future<void> insertRandomData(int length) =>
      execute((w) => w.insertRandomData(length));

  @override
  Future<Map<PinyinDictKind, String>> savePinyinDict() =>
      execute((w) => w.savePinyinDict());

  @override
  Future<List<MainTableRow>> search(String value, Tokenizer tokenizer) =>
      execute((w) => w.search(value, tokenizer));

  @override
  Future<List<MainTableRow>> selectAll() => execute((w) => w.selectAll());

  @override
  Future<int> selectCount() => execute((w) => w.selectCount());

  @override
  Future<void> updateAll() => execute((w) => w.updateAll());

  @override
  Future<void> updatePinyinDict(String newPath) =>
      execute((w) => w.updatePinyinDict(newPath));

  @override
  Future<void> updatePinyinKind2Url(Map<PinyinDictKind, String> kind2url) =>
      execute((w) => w.updatePinyinKind2Url(kind2url));
}

final class _$Deser extends MarshalingContext {
  _$Deser({super.contextAware});
  late final $0 = value<int>();
  late final $1 = (($) => JiebaDictType.values[$0($)]);
  late final $2 = value<String>();
  late final $3 = map<JiebaDictType, String>(kcast: $1, vcast: $2);
  late final $4 = (($) => Tokenizer.values[$0($)]);
  late final $5 = (($) => PinyinDictKind.values[$0($)]);
  late final $6 = map<PinyinDictKind, String>(kcast: $5, vcast: $2);
  late final $7 = (($) => MainTableRowSquadronMarshaling.unmarshal($, this));
  late final $8 = list<MainTableRow>($7);
}

final class _$Ser extends MarshalingContext {
  _$Ser({super.contextAware});
  late final $0 = (($) => ($ as PinyinDictKind).index);
  late final $1 = map(kcast: $0);
  late final $2 = (($) =>
      MainTableRowSquadronMarshaling($ as MainTableRow).marshal());
  late final $3 = list($2);
  late final $4 = (($) => ($ as JiebaDictType).index);
  late final $5 = map(kcast: $4);
  late final $6 = (($) => ($ as Tokenizer).index);
}
