import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter.g.dart';

@riverpod
class Counter extends _$Counter{
  @override
  String build() => "";

  void incrementCounter() {
    state = "あいうえお";
  }
}