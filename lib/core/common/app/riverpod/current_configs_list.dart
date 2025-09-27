import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../entities/config.dart';
part 'current_configs_list.g.dart';

@Riverpod(keepAlive: true)
class CurrentConfigsList extends _$CurrentConfigsList {
  @override
  List<Config>? build() {
    return null;
  }

  void setConfigs(List<Config> configs) {
    if (state != configs) state = configs;
  }
}
