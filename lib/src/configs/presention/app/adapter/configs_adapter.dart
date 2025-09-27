import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_configs.dart';

part 'configs_adapter.g.dart';
part 'configs_state.dart';

@riverpod
class ConfigsAdapter extends _$ConfigsAdapter {
  @override
  ConfigsState build([GlobalKey? familyKey]) {
    return ConfigsInitial();
  }

  late GetConfigs _getConfigs;

  Future<void> getConfigs() async {
    state = const ConfigsLoading();
    final result = await _getConfigs.call();
    result.fold((l) => state = ConfigsError(l.message), (r) {
      ref.read(currentConfigsListProvider.notifier).setConfigs(r);
      state = ConfigsLoaded(r);
    });
  }
}
