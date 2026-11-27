import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/byte_format.dart';
import 'package:vendervpn/core/widgets/quota_progress_bar.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/cloud_quota_sheet.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

/// Today's cloud-node data allowance (server free data + ad bonuses):
/// used / limit, a progress bar, and how much is left. Updates live while
/// connected, since the connection adapter adds usage on every status tick.
/// Every amount comes from the quota server; nothing is hardcoded here.
class CloudQuotaMeter extends ConsumerWidget {
  const CloudQuotaMeter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(usageQuotaProvider);
    final l10n = AppLocalizations.of(context)!;
    final textColor = Colours.classicAdabtiveTextColor(context);

    final ratio =
        !quota.isKnown
            ? 0.0
            : quota.totalBytes == 0
            ? 1.0
            : (quota.totalUsedBytes / quota.totalBytes).clamp(0.0, 1.0);
    final barColor =
        quota.isExhausted
            ? Colours.orbCoral
            : ratio >= 0.8
            ? Colours.pastelAmberFg
            : Colours.orbViolet;

    final used = formatBytes(quota.totalUsedBytes);
    final limit = formatBytes(quota.totalBytes);
    final left = formatBytes(quota.remainingBytes);
    final reward = formatBytes(quota.bonusPerAdBytes);
    final hasBonus = quota.bonusBytes > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colours.softChipBg(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, size: 15, color: barColor),
              const SizedBox(width: 8),
              Text(
                l10n.quota_meter_title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Text(
                '$used / $limit',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          QuotaProgressBar(
            value: ratio,
            color: barColor,
            backgroundColor: Colours.subtleBorder(context),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  quota.isExhausted
                      ? l10n.quota_meter_used_up
                      : hasBonus
                      ? l10n.quota_meter_left_with_bonus(left)
                      : l10n.quota_meter_left(left),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        quota.isExhausted
                            ? Colours.orbCoral
                            : Colours.subtitleGrey,
                  ),
                ),
              ),
              if (quota.isExhausted && quota.canEarnBonus)
                GestureDetector(
                  onTap: () => CloudQuotaSheet.show(context),
                  child: Text(
                    l10n.quota_meter_watch_ad(reward),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colours.orbViolet,
                    ),
                  ),
                )
              else
                Text(
                  l10n.quota_meter_resets,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colours.subtitleGrey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
