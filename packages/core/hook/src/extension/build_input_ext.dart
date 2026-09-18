import 'package:hooks/hooks.dart';

extension BuildInputExt on BuildInput {
  String f(String key) => 'hooks.user_defines.$packageName.$key';
}
