import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/dashboard/presention/widgets/nav_bar_item.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  Future<void> _toggleTunnel(
    ConnectionAdapter adapter,
    bool isConnected,
    bool isConnecting,
  ) async {
    if (isConnected || isConnecting) {
      await adapter.stopConnection();
    } else {
      await adapter.startConnection();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionAdapterProvider);
    final isConnected = connectionState is ConnectionStateConnected;
    final isConnecting = connectionState is ConnectionStateConnecting;
    final adapter = ref.watch(connectionAdapterProvider.notifier);

    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = Colours.cardSurface(context);

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colours.subtleBorder(context).withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                ...Colours.softCardShadow(context),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavBarItem(
                  label: l10n.nav_home,
                  icon:
                      Icons
                          .grid_view_rounded, // Matches the grid look in screenshot
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
                const SizedBox(width: 6),
                NavBarItem(
                  label: l10n.nav_nodes,
                  icon: Icons.dns_outlined,
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const SizedBox(width: 6),
                NavBarItem(
                  label: l10n.nav_settings,
                  icon: Icons.tune_rounded,
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              _toggleTunnel(adapter, isConnected, isConnecting);
            },
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    connectionState is ConnectionStateConnected
                        ? Colours.orbEmerald
                        : Colours.subtitleGrey,
              ),
              child: Icon(
                connectionState is ConnectionStateConnected
                    ? Icons.flash_off
                    : Icons.flash_on,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
