import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
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
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        final configsIndex = index - 1;
        if (index == 0) {
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(8.0),
              child: Center(
                child:Container(
                  width:30,height:3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color:Colours.connectedColor
                  )
                )
              ))
            ],
          );
        }
      },
    );
  }
}
