import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:vendervpn/widgets/configs_list_headers.dart';
import 'package:vendervpn/widgets/list_tile_trailing.dart';
//import 'package:flutter/foundation.dart';

class ConfigsListView extends ConsumerWidget {
  final ScrollController scrollController;
  const ConfigsListView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(configsListProvider);
    final selectedConfig = ref.watch(userPrefsProvider).defaultConfig;
    final List<Widget> headers = [
      ConfigsListHeaders(scrollController: scrollController),
    ];
    final status = ref.read(v2rayControllerProvider.notifier).status;
    void onDelete(String id) {
      ref.read(configsListProvider.notifier).removeConfig(id);
      final ConfigModel config = ConfigModel(
        configjson: '',
        importedFrom: '',
        remark: '',
        port: 0,
        address: '',
        uri: '',
        dateAdded: '',
      );
      ref.read(userPrefsProvider.notifier).setDefauktConfig(config);
    }

    return ValueListenableBuilder(
      valueListenable: status,
      builder: (context, value, child) {
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
                value.state == 'DISCONNECTED' ? 'Not Secure' : 'CONNECTED',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
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
                    Text('${value.download}'),
                    Text('${value.downloadSpeed}'),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: VerticalDivider(width: 3),
                    ),
                    Text('${value.upload}'),
                    Text('${value.uploadSpeed}'),
                    const CircleAvatar(child: Icon(Icons.cloud_upload_rounded)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: list.length,
                //headers.length + list.length,
                itemBuilder: (ctx, index) {
                  //if (index < headers.length) {
                  //return headers[index];
                  //}

                  //int configsIndex = index - headers.length;
                  int configsIndex = index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        trailing: ListTileTraling(
                          onShare: () {},
                          onDelete:
                              () => ref
                                  .read(configsListProvider.notifier)
                                  .removeConfig(list[configsIndex].id),
                        ),
                        leading: Container(
                          width: 5,
                          decoration: BoxDecoration(
                            color:
                                selectedConfig != null &&
                                        list[configsIndex].id ==
                                            selectedConfig.id
                                    ? const Color.fromARGB(206, 50, 219, 163)
                                    : Colors.grey[300],
                          ),
                        ),
                        onTap:
                            () => ref
                                .read(userPrefsProvider.notifier)
                                .setDefauktConfig(list[configsIndex]),

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
              ),
            ),
          ],
        );
      },
    );
  }
}
