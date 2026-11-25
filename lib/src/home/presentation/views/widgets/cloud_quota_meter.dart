import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/cloud_quota_sheet.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

/// Today's cloud-node data allowance (500 MB free + ad bonuses):
/// used / limit, a progress bar, and how much is left. Updates live while
/// connected, since the connection adapter adds usage on every status tick.
class CloudQuotaMeter extends ConsumerWidget {
  const CloudQuotaMeter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(usageQuotaProvider);
    final textColor = Colours.classicAdabtiveTextColor(context);

    final ratio =
        quota.limitBytes == 0
            ? 1.0
            : (quota.usedBytes / quota.limitBytes).clamp(0.0, 1.0);
    final barColor =
        quota.isExceeded
            ? Colours.orbCoral
            : ratio >= 0.8
            ? Colours.pastelAmberFg
            : Colours.orbViolet;

    final used = SubscriptionUserInfo.formatBytes(quota.usedBytes);
    final limit = SubscriptionUserInfo.formatBytes(quota.limitBytes);
    final left = SubscriptionUserInfo.formatBytes(quota.remainingBytes);
    final reward = SubscriptionUserInfo.formatBytes(UsageQuota.rewardBytes);
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
                'Free cloud data',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: Colours.subtleBorder(context),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  quota.isExceeded
                      ? 'Used up for today'
                      : '$left left today${hasBonus ? ' · incl. ad bonus' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        quota.isExceeded
                            ? Colours.orbCoral
                            : Colours.subtitleGrey,
                  ),
                ),
              ),
              if (quota.isExceeded)
                GestureDetector(
                  onTap: () => CloudQuotaSheet.show(context),
                  child: Text(
                    'Watch ad · +$reward',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colours.orbViolet,
                    ),
                  ),
                )
              else
                const Text(
                  'Resets at midnight',
                  style: TextStyle(fontSize: 10.5, color: Colours.subtitleGrey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
