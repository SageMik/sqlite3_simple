import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_platform_utils/flutter_platform_utils.dart';
import 'package:sqlite3/sqlite3.dart' as s3;
import 'package:sqlite3/sqlite3.dart' hide sqlite3;
import 'package:sqlite3/src/ffi/implementation.dart';

Sqlite3? _sqlite3;

Sqlite3 get sqlite3 {
 return _sqlite3 ??= PlatformUtils.isOhos
     ? FfiSqlite3(DynamicLibrary.open("libsqlite3.so"))
     : s3.sqlite3;
}