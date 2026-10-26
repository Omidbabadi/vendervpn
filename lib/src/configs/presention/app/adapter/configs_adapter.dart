import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_configs.dart';

import '../../../../../core/services/injection_container.dart';

part 'configs_adapter.g.dart';
part 'configs_state.dart';

@Riverpod(keepAlive: true)
class ConfigsAdapter extends _$ConfigsAdapter {
  @override
  ConfigsState build() {
    _getConfigs = sl<GetConfigs>();
    return ConfigsInitial();
  }

  late GetConfigs _getConfigs;
  final _cacheHelper = sl<CacheHelper>();

  Future<void> getConfigs() async {
    state = const ConfigsLoading();
    final result = await _getConfigs.call();
    if (!ref.mounted) return;
    result.fold(
      (l) {
        final localConfigs = ref.read(localConfigsListProvider);
        if (localConfigs.isNotEmpty) {
          final selectedLocal = localConfigs.firstWhere(
            (c) => c.id == _cacheHelper.id,
            orElse: () => localConfigs.first,
          );
          ref
              .read(currentConfigProvider.notifier)
              .getCachedSelctedConfig(selectedLocal);
          state = ConfigsLoaded(localConfigs);
          return;
        }
        state = ConfigsError(l.message);
      },
      (r) {
        ref.read(currentConfigsListProvider.notifier).setConfigs(r);
        final localConfigs = ref.read(localConfigsListProvider);
        final allAvailable = [...r, ...localConfigs];
        if (allAvailable.isNotEmpty) {
          final cachedConfig = allAvailable.firstWhere(
            (config) => config.id == _cacheHelper.id,
            orElse: () => allAvailable.first,
          );
          ref
              .read(currentConfigProvider.notifier)
              .getCachedSelctedConfig(cachedConfig);
        }
        state = ConfigsLoaded(r);
      },
    );
  }
}
