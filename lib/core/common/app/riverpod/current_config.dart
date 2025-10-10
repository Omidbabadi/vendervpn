import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/entities/config.dart';

import '../../../services/injection_container.dart';

part 'current_config.g.dart';

@Riverpod(keepAlive: true)
class CurrentConfig extends _$CurrentConfig {
  @override
  Config? build() {
    return null;
  }

  final cacheHelper = sl<CacheHelper>();

  void getCachedSelctedConfig(Config config) {
    state = config;
  }

  Future<void> setCurrentConfig(Config config) async {
    await cacheHelper.cacheId(config.id);
    if (state != config) state = config;
  }
}
