import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

import '../../../../../core/res/styles/colors.dart';
import '../../../../../core/res/styles/text.dart';
import '../../../../../l10n/app_localizations.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionAdapterProvider().notifier).status;

    return ValueListenableBuilder<V2RayStatus>(
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
                    color: Colours.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                !CoreUtils.isConnected(value.state)
                    ? AppLocalizations.of(context)!.vpnstatus_not_connect
                    : AppLocalizations.of(context)!.vpnstatus_connect,
                textAlign: TextAlign.center,
                style: TextStyles.headingMedium
                    .adaptiveColor(context)
                    .copyWith(
                      color:
                          value.state == 'CONNECTED' ? Colours.primary : null,
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
                    const CircleAvatar(child: Icon(Icons.cloud_upload_rounded)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
