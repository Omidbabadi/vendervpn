import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

class FastestServerCard extends StatelessWidget {
  const FastestServerCard({
    super.key,
    required this.fastestNode,
    required this.isAutoConnecting,
    required this.isConnected,
    required this.isSelected,
    required this.onTap,
  });

  final Config? fastestNode;
  final bool isAutoConnecting;
  final bool isConnected;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final isFastestActive = isConnected && isSelected;

    return Bounceable(
      onTap: isAutoConnecting ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isFastestActive
                ? Colours.orbEmerald.withValues(alpha: 0.7)
                : Colours.subtleBorder(context),
            width: isFastestActive ? 1.5 : 1.0,
          ),
          boxShadow: Colours.softCardShadow(context),
        ),
        child: Row(
          children: [
            // Electric / Speed Lightning Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colours.orbEmerald.withValues(alpha: 0.18),
                    Colours.orbCyan.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colours.orbEmerald.withValues(alpha: 0.45),
                ),
              ),
              child: Center(
                child: isAutoConnecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colours.orbEmerald,
                        ),
                      )
                    : const Icon(
                        Icons.bolt_rounded,
                        size: 22,
                        color: Colours.orbEmerald,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Dynamic Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.fastest_server,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isFastestActive
                              ? Colours.pastelMintBg
                              : Colours.pastelLilacBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isFastestActive
                              ? l10n.vpnstatus_connect
                              : l10n.fastest_badge,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isFastestActive
                                ? Colours.pastelMintFg
                                : Colours.pastelLilacFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isAutoConnecting)
                    Text(
                      l10n.finding_fastest_server,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colours.orbEmerald,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (fastestNode != null)
                    Row(
                      children: [
                        if (fastestNode!.country != null &&
                            fastestNode!.country!.length == 2) ...[
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CoreUtils.getCountryFlag(fastestNode!.country!),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          child: Text(
                            fastestNode!.remark,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colours.subtitleGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if ((fastestNode!.ping ?? -1) > 0) ...[
                          const SizedBox(width: 6),
                          DotMatrixText(
                            text: '${fastestNode!.ping}',
                            dotSize: 1.5,
                            dotSpacing: 0.6,
                            charSpacing: 2.2,
                            activeColor: Colours.pastelMintFg,
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'ms',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colours.pastelMintFg,
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Text(
                      l10n.fastest_server_desc,
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
            const SizedBox(width: 8),

            // Action Pill Button
            if (isAutoConnecting)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colours.softChipBg(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: Colours.orbEmerald,
                  ),
                ),
              )
            else if (isFastestActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colours.pastelMintBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: Colours.pastelMintFg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.vpnstatus_connect,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colours.pastelMintFg,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colours.pastelMintBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colours.orbEmerald.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flash_on_rounded,
                      size: 13,
                      color: Colours.pastelMintFg,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      l10n.auto_connect,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colours.pastelMintFg,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
