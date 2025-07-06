import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:vendervpn/services/api_service.dart';
import 'package:vendervpn/widgets/configs_list_headers.dart';
import 'package:vendervpn/widgets/list_tile_trailing.dart';
import 'package:vendervpn/widgets/show_snackbar.dart';
//import 'package:flutter/foundation.dart';

class ConfigsListView extends ConsumerWidget {
  final ScrollController scrollController;
  const ConfigsListView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _getConfigs() async {
      final apiService = ApiService();

      try {
        final configs = await apiService.getConfigsList();
        if (configs == null) return;
        if (configs.isEmpty && context.mounted) {
          showSnackBar(
            context,
            true,
            title: 'Server Issue',
            message: '0 Servers Found',
          );
        }
        if (context.mounted) {
          ref.read(userPrefsProvider.notifier).setDefaultConfig(configs[0]);
          showSnackBar(
            context,
            false,
            title: AppLocalizations.of(context)!.founded_servers,
            message: "${configs.length} servers found",
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    final list = ref.watch(configsListProvider);
    final selectedConfig = ref.watch(userPrefsProvider).defaultConfig;

    final status = ref.read(v2rayControllerProvider.notifier).status;
    void onDelete(String id) {
      if (selectedConfig!.id == id) {
        showSnackBar(
          context,
          true,
          title: 'Forbidden Action',
          message: 'This Config is set as selected, You cant delete it',
        );
        return;
      }

      ref.read(configsListProvider.notifier).removeConfig(id);
    }

    return ValueListenableBuilder(
      valueListenable: status,
      builder: (context, value, child) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 255, 179),
                ),
                onPressed: () {
                  _getConfigs();
                },
                child: Text(AppLocalizations.of(context)!.get_servers),
              ),
            ),
          );
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: list.length + 1,
          itemBuilder: (ctx, index) {
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
                          color: const Color.fromARGB(255, 33, 255, 181),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value.state == 'DISCONNECTED'
                          ? 'Not Secure'
                          : 'CONNECTED',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(
                        color:
                            value.state == 'DISCONNECTED'
                                ? null
                                : const Color.fromARGB(255, 33, 255, 181),
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
                          Text('${value.download / 100} kb/s'),
                          Text('${value.downloadSpeed / 100} kb/s'),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: VerticalDivider(width: 3),
                          ),
                          Text('${value.upload / 100} kb/s'),
                          Text('${value.uploadSpeed / 100} kb/s'),
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
                  trailing: ListTileTraling(
                    // onShare: () {},
                    onDelete: () {
                      onDelete(list[configsIndex].id);
                    },
                    //() => ref
                    //  .read(configsListProvider.notifier)
                    // .removeConfig(list[configsIndex].id),
                  ),
                  leading: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color:
                          selectedConfig != null &&
                                  list[configsIndex].id == selectedConfig.id
                              ? const Color.fromARGB(206, 50, 219, 163)
                              : Colors.grey[300],
                    ),
                  ),
                  onTap:
                      () => ref
                          .read(userPrefsProvider.notifier)
                          .setDefaultConfig(list[configsIndex]),

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
                    list[configsIndex].address,
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
