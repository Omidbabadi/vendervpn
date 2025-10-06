import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';

import '../../../../../core/common/app/riverpod/current_config.dart';

class ConfigsList extends ConsumerWidget {
  const ConfigsList({super.key});
  static const path = '/configs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(currentConfigsListProvider);
    final selectedConfig = ref.watch(currentConfigProvider);
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        debugPrint(list.length.toString());
        return ListTile(
          title: Text(list[index].remark),
          selected: list[index] == selectedConfig,
          onTap: () {
            ref
                .read(currentConfigProvider.notifier)
                .setCurrentConfig(list[index]);
            context.push(HomeView.path);
          },
        );
      },
    );
  }
}
