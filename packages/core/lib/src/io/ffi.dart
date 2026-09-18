@DefaultAsset('package:sqlite3_simple_core/simple')
library;

import 'dart:ffi';

typedef Sqlite3SimpleInit =
    Int Function(Pointer<Void> db, Pointer<Void> pzErrMsg, Pointer<Void> pApi);

@Native<Sqlite3SimpleInit>()
external int sqlite3_simple_init(
  Pointer<Void> db,
  Pointer<Void> pzErrMsg,
  Pointer<Void> pApi,
);
