import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/widgets/orb_face_widget.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key});

  static final GlobalKey<OrbFaceWidgetState> _orbKey =
      GlobalKey<OrbFaceWidgetState>();

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
    final adapter = ref.watch(connectionAdapterProvider.notifier);
    final connectionState = ref.watch(connectionAdapterProvider);
    ref.watch(currentThemeProvider);
    final l10n = AppLocalizations.of(context)!;
    final textColor = Colours.classicAdabtiveTextColor(context);

    final isConnected = connectionState is ConnectionStateConnected;
    final isConnecting = connectionState is ConnectionStateConnecting;
    final isError = connectionState is ConnectionStateError;

    final mood =
        isConnected
            ? OrbMood.connected
            : isConnecting
            ? OrbMood.connecting
            : isError
            ? OrbMood.error
            : OrbMood.disconnected;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Iridescent Liquid Orb Face — wiggles ONLY when tapped
        OrbFaceWidget(
          key: _orbKey,
          mood: mood,
          size: 224,
          showSatellites: true,
          onTap: () => _toggleTunnel(adapter, isConnected, isConnecting),
        ),
        const SizedBox(height: 14),

        GestureDetector(
          onTap: () {
            _orbKey.currentState?.triggerWiggle();
            _toggleTunnel(adapter, isConnected, isConnecting);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colours.softChipBg(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colours.subtleBorder(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isConnected
                            ? Colours.orbEmerald
                            : isConnecting
                            ? Colours.orbViolet
                            : Colours.orbCoral,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected
                      ? l10n.disconnect
                      : isConnecting
                      ? l10n.connecting
                      : l10n.connect,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.85),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
