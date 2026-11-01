import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

import '../../../../../core/common/app/riverpod/local_configs_list.dart';
import '../../../../../core/common/entities/config.dart';
import '../../../../../core/res/styles/colors.dart';
import '../../../../../core/utils/core_utils.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../home/presentation/views/widgets/config_tile.dart';

class SubscriptionExpansionCard extends ConsumerWidget {
  const SubscriptionExpansionCard({
    super.key,
    required this.groupKey,
    required this.name,
    required this.subscription,
    required this.nodes,
    required this.isExpanded,
    required this.isConnected,
    required this.surfaceColor,
    required this.textColor,
  });

  final String groupKey;
  final String name;
  final SubscriptionItem? subscription;
  final List<Config> nodes;
  final bool isExpanded;
  final bool isConnected;
  final Color surfaceColor;
  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isImporting = ref.watch(nodesViewUiStateProvider).isImporting;
    final intervalLabel =
        subscription != null
            ? (subscription!.intervalHours > 0
                ? '${l10n.every_n_hours} ${subscription!.intervalHours}h'
                : l10n.manual_interval)
            : l10n.sub_url_action;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colours.subtleBorder(context)),
        boxShadow: Colours.softCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Expandable Group Header ───
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(nodesViewUiStateProvider.notifier)
                  .toggleSubExpanded(groupKey);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colours.pastelLilacBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.rss_feed_rounded,
                          size: 18,
                          color: Colours.pastelLilacFg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colours.pastelLilacBg,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${nodes.length}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colours.pastelLilacFg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subscription != null
                                  ? '$intervalLabel • ${subscription!.url}'
                                  : '${nodes.length} node(s)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colours.subtitleGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subscription != null
                              ? '$intervalLabel • ${subscription!.url}'
                              : '${nodes.length} • ${l10n.sub_url_action}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colours.subtitleGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subscription != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        ref
                            .read(nodesViewUiStateProvider.notifier)
                            .setImporting(true);
                        try {
                          final count = await ref
                              .read(localConfigsListProvider.notifier)
                              .refreshSubscription(subscription!);
                          if (!context.mounted) return;
                          CoreUtils.showSnackBar(
                            context,
                            false,
                            title: l10n.subscription_updated_title,
                            message: '"${subscription!.name}" ($count)',
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          CoreUtils.showSnackBar(
                            context,
                            true,
                            title: l10n.sync_failed_title,
                            message: e.toString(),
                          );
                        } finally {
                          ref
                              .read(nodesViewUiStateProvider.notifier)
                              .setImporting(false);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colours.softChipBg(context),
                          shape: BoxShape.circle,
                        ),
                      ],
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: textColor.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(localConfigsListProvider.notifier)
                            .removeSubscriptionAndNodes(subscription!);
                        if (!context.mounted) return;
                        CoreUtils.showSnackBar(
                          context,
                          false,
                          title: l10n.subscription_removed_title,
                          message: '"${subscription!.name}"',
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colours.pastelRoseBg.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Colours.pastelRoseFg,
                        ),
                      ),
                    ],
                  ),
                  if (userInfo != null) ...[
                    const SizedBox(height: 10),
                    _SubscriptionUserInfoBanner(
                      userInfo: userInfo,
                      textColor: textColor,
                      l10n: l10n,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ─── Expandable Nodes Body ───
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child:
                  isImporting
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Colours.orbViolet,
                        ),
                      )
                      : Column(
                        children: [
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colours.subtleBorder(context),
                          ),
                          const SizedBox(height: 10),
                          if (nodes.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.no_nodes_in_sub,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colours.subtitleGrey,
                                ),
                              ),
                            )
                          else
                            for (final node in nodes)
                              ConfigTile(
                                config: node,
                                isConnected: isConnected,
                                isLocal: true,
                              ),
                        ],
                      ),
            ),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionUserInfoBanner extends StatelessWidget {
  const _SubscriptionUserInfoBanner({
    required this.userInfo,
    required this.textColor,
    required this.l10n,
  });

  final SubscriptionUserInfo userInfo;
  final Color textColor;
  final AppLocalizations l10n;

  String _formatExpiryText() {
    if (userInfo.isUnlimitedExpire) {
      return '∞ ${l10n.never_expires}';
    }
    final dt = userInfo.expireDate!;
    final now = DateTime.now();
    if (now.isAfter(dt)) {
      return l10n.expired;
    }
    final diff = dt.difference(now);
    final dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    if (diff.inDays >= 1) {
      return '${diff.inDays} ${l10n.days_left} ($dateStr)';
    }
    final hours = diff.inHours.clamp(1, 23);
    return '$hours ${l10n.hours_left}';
  }

  @override
  Widget build(BuildContext context) {
    final usedStr = SubscriptionUserInfo.formatBytes(userInfo.used);
    final totalStr =
        userInfo.isUnlimitedTraffic
            ? '∞ ${l10n.unlimited}'
            : SubscriptionUserInfo.formatBytes(userInfo.total);
    final upStr = SubscriptionUserInfo.formatBytes(userInfo.upload);
    final downStr = SubscriptionUserInfo.formatBytes(userInfo.download);
    final ratio = userInfo.usageRatio;
    final isExpired = userInfo.isExpired;
    final isHighUsage = ratio != null && ratio >= 0.85;

    final Color expireBg;
    final Color expireFg;
    if (isExpired) {
      expireBg = Colours.pastelRoseBg;
      expireFg = Colours.pastelRoseFg;
    } else if (!userInfo.isUnlimitedExpire &&
        userInfo.expireDate!.difference(DateTime.now()).inDays <= 3) {
      expireBg = Colours.pastelAmberBg;
      expireFg = Colours.pastelAmberFg;
    } else {
      expireBg = Colours.pastelMintBg;
      expireFg = Colours.pastelMintFg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colours.softChipBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colours.subtleBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (userInfo.hasTrafficData) ...[
            Row(
              children: [
                const Icon(
                  Icons.data_usage_rounded,
                  size: 13.5,
                  color: Colours.orbViolet,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${l10n.used_label}: $usedStr / $totalStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: expireBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpired
                            ? Icons.error_outline_rounded
                            : Icons.schedule_rounded,
                        size: 11,
                        color: expireFg,
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        _formatExpiryText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: expireFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (ratio != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4.5,
                  backgroundColor: Colours.subtleBorder(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isHighUsage ? Colours.pastelRoseFg : Colours.orbViolet,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 12,
                  color: Colours.orbAzure,
                ),
                const SizedBox(width: 3),
                Text(
                  upStr,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 12,
                  color: Colours.pastelMintFg,
                ),
                const SizedBox(width: 3),
                Text(
                  downStr,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.72),
                  ),
                ),
                if (ratio != null) ...[
                  const Spacer(),
                  Text(
                    '${(ratio * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color:
                          isHighUsage
                              ? Colours.pastelRoseFg
                              : Colours.subtitleGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (userInfo.hasTrafficData && userInfo.hasAnnounce) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              color: Colours.subtleBorder(context),
            ),
            const SizedBox(height: 7),
          ],
          if (userInfo.hasAnnounce)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.5),
                  child: Icon(
                    Icons.campaign_rounded,
                    size: 15,
                    color: Colours.pastelAmberFg,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    userInfo.announce!,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.38,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.86),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final urlMatch = RegExp(
                      r'https?://\S+',
                    ).firstMatch(userInfo.announce!);
                    final textToCopy =
                        urlMatch != null
                            ? urlMatch.group(0)!
                            : userInfo.announce!;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    CoreUtils.showSnackBar(
                      context,
                      false,
                      title: l10n.succesful,
                      message: textToCopy,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 13.5,
                      color: textColor.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
