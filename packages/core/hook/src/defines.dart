import 'package:hooks/hooks.dart';

import 'extension/build_input_ext.dart';

class SimpleUserDefines {
  final BuildInput _input;
  final HookInputUserDefines _defines;

  SimpleUserDefines(this._input) : _defines = _input.userDefines;

  String? str(String key) {
    final value = _defines[key];
    if (value == null) return null;
    if (value is! String) {
      throw exception(
        key,
        (it) => '$it must be a string, but got ${value.runtimeType}',
      );
    }
    return value;
  }

  Uri? path(String key) => _defines.path(key);

  List<Object?>? list(String key) {
    final value = _defines[key];
    if (value == null) return null;
    if (value is! List) {
      throw exception(
        key,
        (it) => '$it must be a list, but got ${value.runtimeType}',
      );
    }
    return value;
  }

  Exception exception(
    String key,
    String Function(String fullKey) lazyMessage,
  ) => FormatException(lazyMessage(_input.f(key)));
}
