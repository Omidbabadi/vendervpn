import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';

import '../../../../../core/common/app/riverpod/current_config.dart';
import '../../../../../core/res/styles/colors.dart';
import '../../../../../l10n/app_localizations.dart';

class ConfigsList extends ConsumerWidget {
  const ConfigsList({super.key});
  static const path = '/configs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(currentConfigsListProvider);
    final state = sl<ValueNotifier<V2RayStatus>>();
    final selectedConfig = ref.watch(currentConfigProvider);
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (context, value, child) {
        return ListView.builder(
      itemCount: list.length + 1,
      itemBuilder: (ctx, index) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: FilledButton(
                onPressed: () async {},
                child: Text(AppLocalizations.of(context)!.get_servers),
              ),
            ),
          );
        }
        int configsIndex = index - 1;
        if (index == 0) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colours.connectedColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value.state == 'DISCONNECTED'
                      ? AppLocalizations.of(context)!.vpnstatus_not_connect
                      : AppLocalizations.of(context)!.vpnstatus_connect,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color:
                        value.state == 'DISCONNECTED'
                            ? null
                            : Colours.connectedColor,
                  ),
                ),
              ),
              Text(
                value.duration,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 48,
                  color:
                      value.state == 'DISCONNECTED'
                          ? const Color.fromARGB(255, 223, 223, 223)
                          : const Color.fromARGB(255, 33, 255, 181),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 193, 255, 242),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.cloud_download_rounded),
                      ),
                      Text(
                        '${value.download} kb/s',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // Text('${value.downloadSpeed / 1000} mb/s'),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: VerticalDivider(width: 3),
                      ),
                      Text(
                        '${value.upload} kb/s',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      //Text('${value.uploadSpeed / 1000} kb/s'),
                      const CircleAvatar(
                        child: Icon(Icons.cloud_upload_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Container(
                width: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color:
                      selectedConfig != null &&
                              list[configsIndex].id == selectedConfig.id
                          ? const Color.fromARGB(206, 50, 219, 163)
                          : Colors.grey[300],
                ),
              ),
              onTap: () {
                
              },

              title: Text(
                list[configsIndex].remark,

                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${list[configsIndex].address}:${list[configsIndex].port}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
      },
    );
  }
}
