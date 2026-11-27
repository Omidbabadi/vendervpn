import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/byte_format.dart';
import 'package:vendervpn/core/widgets/quota_progress_bar.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

/// Shown when today's free cloud data is used up.
/// Offers a rewarded ad that adds the server's per-ad bonus, while the
/// server says today's ads still pay out.
class CloudQuotaSheet extends ConsumerWidget {
  const CloudQuotaSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      // The dashboard's floating nav bar is drawn above the shell's
      // navigator, so a sheet opened there sits behind it.
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CloudQuotaSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(usageQuotaProvider);
    final l10n = AppLocalizations.of(context)!;
    final textColor = Colours.classicAdabtiveTextColor(context);

    final used = formatBytes(quota.totalUsedBytes);
    final limit = formatBytes(quota.totalBytes);
    final reward = formatBytes(quota.bonusPerAdBytes);
    final canEarn = quota.canEarnBonus;
    final progress =
        quota.totalBytes == 0 ? 1.0 : quota.totalUsedBytes / quota.totalBytes;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.data_usage_rounded, size: 40, color: textColor),
            const SizedBox(height: 12),
            Text(
              l10n.quota_sheet_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quota_sheet_used(used, limit),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colours.subtitleGrey),
            ),
            const SizedBox(height: 16),
            QuotaProgressBar(
              value: progress,
              minHeight: 8,
              color: Colours.orbCoral,
              backgroundColor: Colours.softChipBg(context),
            ),
            const SizedBox(height: 16),
            Text(
              canEarn
                  ? l10n.quota_sheet_pitch(reward)
                  : l10n.quota_sheet_no_bonus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (canEarn) ...[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {
                  // Read the notifier before closing: this widget's ref is
                  // gone once the sheet is popped.
                  final connection = ref.read(
                    connectionAdapterProvider.notifier,
                  );
                  Navigator.of(context).pop();
                  connection.startConnection(watchRewardedAd: true);
                },
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(l10n.quota_sheet_watch_ad(reward)),
              ),
              const SizedBox(height: 6),
            ],
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colours.subtitleGrey,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                canEarn ? l10n.quota_sheet_decline : l10n.quota_sheet_close,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.quota_sheet_resets,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colours.subtitleGrey),
            ),
          ],
        ),
      ),
    );
  }
}
