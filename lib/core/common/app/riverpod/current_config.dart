import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/entities/config.dart';

part 'current_config.g.dart';

@Riverpod(keepAlive: true)
class CurrentConfig extends _$CurrentConfig {
  @override
  Config? build() {
    return null;
  }

  void setCurrentConfig(Config config) {
    if (state != config) state = config;
  }
}
