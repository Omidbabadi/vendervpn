import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

class ConfigTile extends ConsumerWidget {
  const ConfigTile({
    super.key,
    required this.config,
    required this.isConnected,
    this.isLocal = false,
  });

  final Config config;
  final bool isConnected;
  final bool isLocal;

  Future<void> _testPing(WidgetRef ref) async {
    final pingingSet = ref.read(pingingNodeIdsProvider);
    if (pingingSet.contains(config.id)) return;

    ref.read(pingingNodeIdsProvider.notifier).setPinging(config.id, true);
    try {
      final delay = await ref
          .read(connectionAdapterProvider.notifier)
          .ping(config.configjson);

      if (isLocal) {
        ref
            .read(localConfigsListProvider.notifier)
            .updateConfigPing(config.id, delay);
      } else {
        ref
            .read(currentConfigsListProvider.notifier)
            .updateConfigPing(config.id, delay);
      }
      final selected = ref.read(currentConfigProvider);
      if (selected?.id == config.id) {
        await ref
            .read(currentConfigProvider.notifier)
            .setCurrentConfig(config.copyWith(ping: delay));
      }
    } finally {
      ref.read(pingingNodeIdsProvider.notifier).setPinging(config.id, false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConfig = ref.watch(currentConfigProvider);
    final isSelected = selectedConfig?.id == config.id;
    final isPinging = ref.watch(pingingNodeIdsProvider).contains(config.id);
    ref.watch(currentThemeProvider);
    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final ping = config.ping ?? -1;
    final protocol = V2rayImportHelper.protocolOf(config.uri);

    return Bounceable(
      onTap: () {
        if (isConnected && !isSelected) {
          CoreUtils.showSnackBar(
            context,
            true,
            title: 'Tunnel Active',
            message: 'Disconnect current session before switching nodes.',
          );
          return;
        }
        HapticFeedback.selectionClick();
        ref.read(currentConfigProvider.notifier).setCurrentConfig(config);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                isSelected
                    ? Colours.orbEmerald.withValues(alpha: 0.65)
                    : Colours.subtleBorder(context),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: Colours.softCardShadow(context),
        ),
        child: Row(
          children: [
            // Country Flag Avatar
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colours.softChipBg(context),
                border: Border.all(
                  color:
                      isSelected
                          ? Colours.orbEmerald
                          : Colours.subtleBorder(context),
                ),
              ),
              child:
                  (config.country != null && config.country!.length == 2)
                      ? CoreUtils.getCountryFlag(config.country!)
                      : Icon(
                        Icons.public_rounded,
                        size: 20,
                        color: textColor.withValues(alpha: 0.65),
                      ),
            ),
            const SizedBox(width: 12),

            // Node Remark + Protocol Badge & Host/IP
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.remark,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colours.softChipBg(context),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          protocol,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected
                                    ? Colours.orbEmerald
                                    : Colours.orbViolet,
                          ),
                        ),
                      ),
                      if (config.importedFrom.startsWith('sub:')) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colours.pastelLilacBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            config.importedFrom.substring(4),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colours.pastelLilacFg,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${config.address}:${config.port}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colours.subtitleGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Ping Latency Pill (Dot-Matrix numbers)
            GestureDetector(
              onTap: () => _testPing(ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      ping > 0
                          ? (ping < 350
                              ? Colours.pastelMintBg
                              : Colours.pastelAmberBg)
                          : Colours.softChipBg(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child:
                    isPinging
                        ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: Colours.orbViolet,
                          ),
                        )
                        : ping > 0
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DotMatrixText(
                              text: '$ping',
                              dotSize: 1.6,
                              dotSpacing: 0.7,
                              charSpacing: 2.5,
                              activeColor:
                                  ping < 350
                                      ? Colours.pastelMintFg
                                      : Colours.pastelAmberFg,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'ms',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    ping < 350
                                        ? Colours.pastelMintFg
                                        : Colours.pastelAmberFg,
                              ),
                            ),
                          ],
                        )
                        : const Icon(
                          Icons.network_check_rounded,
                          size: 15,
                          color: Colours.subtitleGrey,
                        ),
              ),
            ),

            // Delete action for Local Nodes
            if (isLocal) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  ref
                      .read(localConfigsListProvider.notifier)
                      .removeConfig(config.id);
                },
                child: Container(
                  width: 30,
                  height: 30,
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
          ],
        ),
      ),
    );
  }
}
