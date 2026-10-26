import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/ip/presention/adapter/ip_provider.dart';
import 'package:vendervpn/src/nodes/presentation/views/nodes_view.dart';

class ConnectionStatus extends ConsumerWidget {
  const ConnectionStatus({super.key});

  String _formatRate(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/S';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB/S';
    }
    return '$bytes B/S';
  }

  String _formatVolume(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    final selectedConfig = ref.watch(currentConfigProvider);
    final ipSession = ref.watch(ipSessionProvider);
    final connectionState = ref.watch(connectionAdapterProvider);
    final statusNotifier = ref.watch(connectionAdapterProvider.notifier).status;
    final surfaceColor = Colours.cardSurface(context);
    final textColor = Colours.classicAdabtiveTextColor(context);
    final isConnected = connectionState is ConnectionStateConnected;

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: statusNotifier,
      builder: (context, status, _) {
        final activeIp = ipSession.activeInfo(isConnected);
        final beforeIp = ipSession.beforeTun;
        final afterIp = ipSession.afterTun;

        final countryCode =
            isConnected
                ? (afterIp?.countryCode ?? selectedConfig?.country)
                : (beforeIp?.countryCode ?? selectedConfig?.country);

        final locationHeadline =
            isConnected
                ? (afterIp?.displayLocation ??
                    (ipSession.isLoading
                        ? 'Resolving VPN Location...'
                        : (selectedConfig?.remark ?? 'Connected Tunnel')))
                : (beforeIp != null
                    ? 'Your Location • ${beforeIp.displayLocation}'
                    : (selectedConfig?.remark ?? 'Detecting Location...'));

        final connectedEndpointIp = afterIp?.ip ?? selectedConfig?.serverIp;
        final ipSubtitle =
            isConnected
                ? 'Connected IP: ${connectedEndpointIp ?? 'Resolving endpoint...'}'
                : 'Your IP: ${beforeIp?.ip ?? (ipSession.isLoading ? 'Resolving...' : 'Unknown')}';

        final protocol =
            selectedConfig != null
                ? V2rayImportHelper.protocolOf(selectedConfig.uri)
                : 'V2RAY';
        final ping = selectedConfig?.ping ?? -1;
        final totalTraffic = status.download + status.upload;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colours.subtleBorder(context)),
            boxShadow: Colours.softCardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Location & IP Identity on Left, Live Dot-Matrix Speed on Right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colours.softChipBg(context),
                      border: Border.all(
                        color:
                            isConnected
                                ? Colours.orbEmerald.withValues(alpha: 0.6)
                                : Colours.subtleBorder(context),
                      ),
                    ),
                    child:
                        (countryCode != null && countryCode.length == 2)
                            ? CoreUtils.getCountryFlag(countryCode)
                            : Icon(
                              Icons.public_rounded,
                              size: 18,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationHeadline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ipSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colours.subtitleGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DotMatrixText(
                        text: _formatRate(status.downloadSpeed),
                        dotSize: 2.1,
                        dotSpacing: 1.0,
                        charSpacing: 3.4,
                        activeColor: textColor,
                        inactiveColor: textColor.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '↑ ${_formatRate(status.uploadSpeed)} • ${_formatVolume(totalTraffic)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colours.subtitleGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Before TUN -> After TUN route pill when connected (or selected target node when disconnected)
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colours.softChipBg(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.route_rounded
                          : Icons.dns_outlined,
                      size: 15,
                      color:
                          isConnected
                              ? Colours.orbEmerald
                              : Colours.orbViolet,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isConnected && beforeIp != null
                            ? 'Real: ${beforeIp.ip} (${beforeIp.countryCode})  →  Connected: ${connectedEndpointIp ?? 'Resolving...'} (${afterIp?.countryCode ?? countryCode ?? '--'})'
                            : 'Target Node: ${selectedConfig?.remark ?? 'None'} ($protocol)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (ipSession.isLoading)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6,
                          color: Colours.orbViolet,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          if (isConnected && selectedConfig != null) {
                            ref
                                .read(ipSessionProvider.notifier)
                                .lookupAfterTun(selectedConfig);
                          } else {
                            ref
                                .read(ipSessionProvider.notifier)
                                .lookupBeforeTun();
                          }
                        },
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 15,
                          color: activeIp != null
                              ? Colours.subtitleGrey
                              : Colours.orbViolet,
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go(NodesView.path),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colours.subtleBorder(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 13,
                              color: Colours.orbViolet,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Switch',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bottom Row: Latency/Status metric on Left + Emerald Sparkline Wave on Right
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected
                            ? Icons.trending_up_rounded
                            : Icons.sensors_rounded,
                        size: 16,
                        color:
                            isConnected
                                ? Colours.orbEmerald
                                : Colours.orbCoral,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ping > 0 ? '$ping ms' : (isConnected ? 'LIVE' : 'IDLE'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              isConnected
                                  ? Colours.orbEmerald
                                  : Colours.orbCoral,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '↓ ${_formatVolume(status.download)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colours.subtitleGrey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 135,
                    height: 36,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        isConnected: isConnected,
                        speedSeed: status.downloadSpeed + status.uploadSpeed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.isConnected,
    required this.speedSeed,
  });

  final bool isConnected;
  final int speedSeed;

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor =
        isConnected ? Colours.orbEmerald : const Color(0xFF94A3B8);
    final phase = (speedSeed % 1000) / 160.0;

    final points = <Offset>[];
    const samples = 18;
    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      final x = t * size.width;
      final wave =
          isConnected
              ? (math.sin(t * math.pi * 2.6 + phase) * 0.28 +
                  math.cos(t * math.pi * 4.2 - phase) * 0.16)
              : math.sin(t * math.pi * 2.0) * 0.10;
      final y = size.height * (0.55 - wave - (t * 0.15));
      points.add(Offset(x, y.clamp(2.0, size.height - 2.0)));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath =
        Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.24),
              lineColor.withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size);

    final strokePaint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.isConnected != isConnected ||
      oldDelegate.speedSeed != speedSeed;
}
