import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'sqlite3_web_worker.dart';

enum _Type<T extends Sqlite3WebRequest> {
  updateJiebaDict<UpdateJiebaDictRequest>(UpdateJiebaDictRequest.fromJs);

  final T Function(JSObject) fromJs;

  const _Type(this.fromJs);

  static final byName = _Type.values.asNameMap();
}

class _Key {
  _Key._();

  static const type = 't';
  static const data = 'd';
}

sealed class Sqlite3WebRequest {
  _Type get _type;

  static Sqlite3WebRequest fromJs(JSObject jsObject) {
    final type = _Type.byName[(jsObject[_Key.type] as JSString).toDart]!;
    return type.fromJs(jsObject);
  }

  JSObject toJs() {
    return JSObject()..[_Key.type] = _type.name.toJS;
  }
}

/// 通过自定义请求传递结巴分词文件交由 [Sqlite3WebDb.handleCustomRequest] 进行处理
final class UpdateJiebaDictRequest extends Sqlite3WebRequest {
  @override
  final _type = _Type.updateJiebaDict;

  final Map<String, String> path2url;

  UpdateJiebaDictRequest(this.path2url);

  factory UpdateJiebaDictRequest.fromJs(JSObject jsObject) =>
      UpdateJiebaDictRequest(
        (jsObject[_Key.data].dartify() as Map).cast<String, String>(),
      );

  @override
  JSObject toJs() {
    return super.toJs()..[_Key.data] = path2url.jsify();
  }
}
