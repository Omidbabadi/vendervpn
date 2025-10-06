import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cuurrent_state.g.dart';

@Riverpod(keepAlive: true)
class CuurrentState extends _$CuurrentState {
  @override
  ValueNotifier<V2RayStatus>? build() {
    return null;
  }
}
