import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

class NavConnectButton extends StatelessWidget {
  const NavConnectButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.onTap,
  });

  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Colours.cardSurface(context);
    final textColor = Colours.classicAdabtiveTextColor(context);

    final tooltipMessage = isConnected
        ? l10n.disconnect
        : isConnecting
            ? l10n.connecting
            : l10n.connect;

    // Matches the height and elevation of the adjacent navigation pill
    const buttonSize = 58.0;

    return Semantics(
      button: true,
      label: tooltipMessage,
      child: Tooltip(
        message: tooltipMessage,
        child: Bounceable(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? null
                  : surfaceColor.withValues(alpha: 0.96),
              gradient: isConnected
                  ? const LinearGradient(
                      colors: [
                        Colours.orbEmerald,
                        Color(0xFF059669),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: isConnected
                    ? Colours.orbEmerald.withValues(alpha: 0.8)
                    : isConnecting
                        ? Colours.orbViolet.withValues(alpha: 0.7)
                        : Colours.subtleBorder(context).withValues(alpha: 0.6),
                width: isConnected || isConnecting ? 1.5 : 1.0,
              ),
              boxShadow: [
                if (isConnected) ...[
                  BoxShadow(
                    color: Colours.orbEmerald.withValues(alpha: 0.42),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] else if (isConnecting) ...[
                  BoxShadow(
                    color: Colours.orbViolet.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  ...Colours.softCardShadow(context),
                ] else ...[
                  ...Colours.softCardShadow(context),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ],
            ),
            child: Center(
              child: isConnecting
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colours.orbViolet,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.power_settings_new_rounded,
                          size: 15,
                          color: Colours.orbViolet.withValues(alpha: 0.85),
                        ),
                      ],
                    )
                  : isConnected
                      ? const Icon(
                          Icons.power_settings_new_rounded,
                          size: 25,
                          color: Colors.white,
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            size: 22,
                            color: textColor.withValues(alpha: 0.85),
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
