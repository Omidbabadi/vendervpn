import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/riverpod/providers.dart';

class ConfigsListHeaders extends ConsumerWidget {
  final ScrollController scrollController;
  const ConfigsListHeaders({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(v2rayControllerProvider);
    return controller.when(
      data: (v2ray) {
        final status = ref.read(v2rayControllerProvider.notifier).status;
        return SizedBox(
          height: 200,
          child: ValueListenableBuilder(
            valueListenable: status,
            builder: (context, value, child) {
              return ListView(
                controller: scrollController,
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
                          Text('${value.download}'),
                          Text('${value.downloadSpeed}'),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: VerticalDivider(width: 3),
                          ),
                          Text('${value.upload}'),
                          Text('${value.uploadSpeed}'),
                          const CircleAvatar(
                            child: Icon(Icons.cloud_upload_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      error: (error, stackTrace) => Text('Error: $error'),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
