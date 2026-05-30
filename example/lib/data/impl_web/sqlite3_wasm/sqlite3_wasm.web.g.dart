// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// Generator: WorkerGenerator 9.0.0+2 (Squadron 7.4.3)
// **************************************************************************

import 'package:squadron/squadron.dart';

import 'sqlite3_wasm.dart';

void main() {
  /// Web entry point for Sqlite3Wasm
  run($Sqlite3WasmInitializer);
}

EntryPoint $getSqlite3WasmActivator(SquadronPlatformType platform) {
  if (platform.isWeb) {
    return Squadron.uri('~/sqlite3_wasm.web.g.dart.js');
  } else {
    throw UnsupportedError('${platform.label} not supported.');
  }
}
