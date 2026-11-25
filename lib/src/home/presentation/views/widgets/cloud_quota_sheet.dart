import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

/// Shown when today's free cloud data is used up.
/// Offers a rewarded ad that adds 1 GB.
class CloudQuotaSheet extends ConsumerWidget {
  const CloudQuotaSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const CloudQuotaSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(usageQuotaProvider);
    final textColor = Colours.classicAdabtiveTextColor(context);

    final used = SubscriptionUserInfo.formatBytes(quota.usedBytes);
    final limit = SubscriptionUserInfo.formatBytes(quota.limitBytes);
    final reward = SubscriptionUserInfo.formatBytes(UsageQuota.rewardBytes);
    final progress =
        quota.limitBytes == 0 ? 1.0 : quota.usedBytes / quota.limitBytes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.data_usage_rounded, size: 40, color: textColor),
            const SizedBox(height: 12),
            Text(
              "Today's free data is used up",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You used $used of $limit on cloud nodes today. '
              'Watch a short ad to get $reward more.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colours.subtitleGrey),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                color: Colours.orbCoral,
                backgroundColor: Colours.softChipBg(context),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                // Read the notifier before closing: this widget's ref is
                // gone once the sheet is popped.
                final connection = ref.read(connectionAdapterProvider.notifier);
                Navigator.of(context).pop();
                connection.startConnection(watchRewardedAd: true);
              },
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: Text('Watch ad · +$reward'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not now'),
            ),
            const SizedBox(height: 4),
            const Text(
              'Free data resets every day at midnight.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colours.subtitleGrey),
            ),
          ],
        ),
      ),
    );
  }
}
