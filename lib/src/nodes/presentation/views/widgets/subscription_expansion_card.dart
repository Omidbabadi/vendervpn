import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              child: Row(
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
                    ),
                  ],
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
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
