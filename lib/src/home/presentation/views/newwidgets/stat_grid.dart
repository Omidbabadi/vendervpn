import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';

import '../../../../../core/services/injection_container.dart';
import '../../../../connection/presention/adapter/connection_adapter.dart';
import 'stat_card.dart';

class StatGrid extends ConsumerWidget {
  const StatGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = sl<ValueNotifier<V2RayStatus>>();
    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,
      builder: (context, value, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              icon: Icons.download,
              title: 'Download',
              value: '${value.download / 10000}  MB/s',
              color: Colors.green,
            ),
            StatCard(
              icon: Icons.upload,
              title: 'Upload',
              value: '${(value.upload / 10000).round()}  MB/s',
              color: Color(0xFF135BEC),
            ),
            StatCard(
              icon: Icons.data_usage,
              title: 'Data Used',
              value: '${value.download / 10000}  MB/s',
              color: Colors.orange,
            ),
            StatCard(
              icon: Icons.shield,
              title: 'Status',
              value: 'Secure',
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}
