import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/config_tile.dart';
import 'package:vendervpn/src/nodes/presentation/views/widgets/subscription_expansion_card.dart';

class LocalNodesGroupedList extends ConsumerWidget {
  const LocalNodesGroupedList({
    super.key,
    required this.localConfigs,
    required this.subscriptions,
    required this.isConnected,
    required this.collapsedSubKeys,
  });

  final List<Config> localConfigs;
  final List<SubscriptionItem> subscriptions;
  final bool isConnected;
  final Set<String> collapsedSubKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);

    // Group subscription configs by their `importedFrom` tag (e.g. `sub:<name>`)
    final subGroups = <String, List<Config>>{};
    final directNodes = <Config>[];

    for (final config in localConfigs) {
      if (config.importedFrom.startsWith('sub:')) {
        subGroups.putIfAbsent(config.importedFrom, () => []).add(config);
      } else {
        directNodes.add(config);
      }
    }

    // Build ordered list of subscription group entries:
    // 1. All registered SubscriptionItems
    // 2. Any orphan `sub:...` groups present in localConfigs
    final groupEntries =
        <
          ({String key, String name, SubscriptionItem? sub, List<Config> nodes})
        >[];
    final handledKeys = <String>{};

    for (final sub in subscriptions) {
      final key = 'sub:${sub.name}';
      handledKeys.add(key);
      groupEntries.add((
        key: key,
        name: sub.name,
        sub: sub,
        nodes: subGroups[key] ?? const <Config>[],
      ));
    }

    for (final entry in subGroups.entries) {
      if (!handledKeys.contains(entry.key)) {
        final name = entry.key.substring(4);
        groupEntries.add((
          key: entry.key,
          name: name.isNotEmpty ? name : l10n.sub_url_action,
          sub: null,
          nodes: entry.value,
        ));
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // ─── Expandable Subscription Groups ───
        for (final group in groupEntries)
          SubscriptionExpansionCard(
            groupKey: group.key,
            name: group.name,
            subscription: group.sub,
            nodes: group.nodes,
            isExpanded: !collapsedSubKeys.contains(group.key),
            isConnected: isConnected,
            surfaceColor: surfaceColor,
            textColor: textColor,
          ),

        // ─── Standalone / Direct Nodes (Clipboard / QR Code) ───
        if (directNodes.isNotEmpty) ...[
          if (groupEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 14,
                    color: Colours.subtitleGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.direct_imports} (${directNodes.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colours.subtitleGrey,
                    ),
                  ),
                ],
              ),
            ),
          for (final config in directNodes)
            ConfigTile(config: config, isConnected: isConnected, isLocal: true),
        ],
      ],
    );
  }
}
