import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import '../../../../../core/services/injection_container.dart';

class NetworkStats extends ConsumerWidget {
  const NetworkStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = sl<ValueNotifier<V2RayStatus>>();

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,

      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 193, 255, 242),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const CircleAvatar(child: Icon(Icons.cloud_download_rounded)),
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
                const CircleAvatar(child: Icon(Icons.cloud_upload_rounded)),
              ],
            ),
          ),
        );
      },
    );
  }
}
