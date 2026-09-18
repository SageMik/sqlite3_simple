import 'package:flutter_riverpod/flutter_riverpod.dart';

NotifierProvider<MutableNotifier<T>, T> mutable<T>(T initial) {
  return NotifierProvider(() => MutableNotifier<T>(initial));
}

class MutableNotifier<T> extends Notifier<T> {
  final T _initial;

  MutableNotifier(this._initial);

  @override
  T build() => _initial;

  void update(T value) => state = value;
}
