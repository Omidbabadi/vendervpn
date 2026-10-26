import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/core/widgets/orb_face_widget.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/ip/presention/adapter/ip_provider.dart';

import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../configs/presention/app/adapter/configs_adapter.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../nodes/presentation/views/nodes_view.dart';
import 'utils/status_utils.dart';

enum Status { loading, success, error, idle, connecting, configsError }

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key, this.status});
  final StatusUtils? status;

  static const path = '/info';

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<StatusUtils> _statusNotifier;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _statusNotifier = ValueNotifier<StatusUtils>(
      widget.status ?? StatusUtils('Establishing Tunnel...', Status.connecting),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  OrbMood _moodForStatus(Status s) {
    return switch (s) {
      Status.success => OrbMood.connected,
      Status.connecting || Status.loading => OrbMood.connecting,
      Status.error || Status.configsError => OrbMood.error,
      Status.idle => OrbMood.disconnected,
    };
  }

  String _dotMatrixHeadline(Status s) {
    return switch (s) {
      Status.success => 'ONLINE',
      Status.connecting || Status.loading => 'LINKING',
      Status.error || Status.configsError => 'ERROR',
      Status.idle => 'IDLE',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final configsState = ref.watch(configsAdapterProvider);
    ref.watch(currentThemeProvider);
    final connectedConfig = ref.watch(currentConfigProvider);
    final ipSession = ref.watch(ipSessionProvider);

    final scaffoldBg = Colours.scaffoldBg(context);
    final surfaceColor = Colours.cardSurface(context);
    final textColor = Colours.classicAdabtiveTextColor(context);

    final Map<Status, String> texts = {
      Status.loading: l10n.loading_title,
      Status.success: l10n.succesful,
      Status.error: l10n.error,
      Status.connecting: l10n.connecting,
      Status.idle: l10n.idle,
      Status.configsError: l10n.failed_to_load_configs,
    };

    ref.listen(connectionAdapterProvider, (p, next) {
      if (next is ConnectionStateConnecting) {
        _statusNotifier.value = StatusUtils(
          texts[Status.connecting]!,
          Status.connecting,
        )..showBackButton = false;
      } else if (next is ConnectionStateConnected) {
        _statusNotifier.value = StatusUtils(
          texts[Status.success]!,
          Status.success,
        )..showBackButton = true;
      } else if (next is ConnectionStateError) {
        _statusNotifier.value = StatusUtils(
          next.message.isNotEmpty ? next.message : texts[Status.error]!,
          Status.error,
        )..showBackButton = true;
      } else if (next is ConnectionStateInitial ||
          next is ConnectionStateDisconnected) {
        context.go(HomeView.path);
      }
    });

    ref.listen(configsAdapterProvider, (p, n) {
      if (n is ConfigsLoaded) {
        context.go(HomeView.path);
      }
      if (n is ConfigsError) {
        _statusNotifier.value = StatusUtils(n.message, Status.configsError)
          ..showBackButton = false;
      }
    });

    return ValueListenableBuilder<StatusUtils>(
      valueListenable: _statusNotifier,
      builder: (context, status, _) {
        final isErrorOrConfigsError =
            status.status == Status.configsError || configsState is ConfigsError;
        final isSuccess = status.status == Status.success;
        final isConnecting =
            status.status == Status.connecting ||
            status.status == Status.loading;
        final mood = _moodForStatus(status.status);

        final accentColor =
            isSuccess
                ? Colours.orbEmerald
                : isErrorOrConfigsError
                ? Colours.orbRose
                : Colours.orbViolet;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: Column(
                children: [
                  // ─── Top Bar ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isConnecting)
                        GestureDetector(
                          onTap: () => context.go(HomeView.path),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colours.subtleBorder(context),
                              ),
                              boxShadow: Colours.softCardShadow(context),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 17,
                              color: textColor,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 42, height: 42),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colours.subtleBorder(context),
                          ),
                          boxShadow: Colours.softCardShadow(context),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'VPN State',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 42, height: 42),
                    ],
                  ),

                  const Spacer(),

                  // ─── Dot-Matrix Headline (Single Word) ───
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: DotMatrixText(
                      text: _dotMatrixHeadline(status.status),
                      dotSize: 3.4,
                      dotSpacing: 1.5,
                      charSpacing: 6.5,
                      activeColor: textColor,
                      inactiveColor: textColor.withValues(alpha: 0.08),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colours.subtitleGrey,
                    ),
                  ),
                  if (isConnecting) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colours.pastelAmberBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Colours.pastelAmberFg,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Please stay on this screen until the ad loads',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colours.pastelAmberFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ─── Center Animated Orb Face + Sonar Rings ───
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _ringController,
                      builder: (context, child) {
                        final p = _ringController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Expanding sonar ring 1
                            Container(
                              width: 170 + (p * 75),
                              height: 170 + (p * 75),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withValues(
                                    alpha: (1.0 - p) * 0.28,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Expanding sonar ring 2
                            Container(
                              width: 170 + (((p + 0.5) % 1.0) * 75),
                              height: 170 + (((p + 0.5) % 1.0) * 75),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withValues(
                                    alpha: (1.0 - ((p + 0.5) % 1.0)) * 0.22,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: OrbFaceWidget(
                        mood: mood,
                        size: 210,
                        showSatellites: true,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ─── Floating Node & IP Route Card (Cirus Style) ───
                  if (connectedConfig != null)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colours.subtleBorder(context)),
                        boxShadow: Colours.softCardShadow(context),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.6),
                                  ),
                                ),
                                child:
                                    ((ipSession.afterTun?.countryCode ??
                                                    connectedConfig.country) !=
                                                null &&
                                            (ipSession.afterTun?.countryCode ??
                                                    connectedConfig.country)!
                                                .length ==
                                                2)
                                        ? CoreUtils.getCountryFlag(
                                          (ipSession.afterTun?.countryCode ??
                                              connectedConfig.country)!,
                                        )
                                        : Icon(
                                          Icons.public_rounded,
                                          size: 20,
                                          color: textColor,
                                        ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ipSession.afterTun?.displayLocation ??
                                          (ipSession.isLoading
                                              ? 'Resolving VPN Location...'
                                              : connectedConfig.remark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Connected IP: ${ipSession.afterTun?.ip ?? connectedConfig.serverIp ?? 'Resolving endpoint...'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colours.subtitleGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if ((connectedConfig.ping ?? -1) > 0)
                                DotMatrixText(
                                  text: '${connectedConfig.ping}',
                                  dotSize: 2.0,
                                  dotSpacing: 1.0,
                                  charSpacing: 3.4,
                                  activeColor: Colours.orbEmerald,
                                ),
                            ],
                          ),
                          if (ipSession.beforeTun != null) ...[
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
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: Colours.orbViolet,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your IP: ${ipSession.beforeTun!.ip} (${ipSession.beforeTun!.countryCode})  →  ${ipSession.afterTun?.ip ?? connectedConfig.serverIp ?? 'Resolving...'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: textColor.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ─── Bottom Action Buttons ───
                  if (isErrorOrConfigsError)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(
                                color: Colours.subtleBorder(context),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () => context.go(NodesView.path),
                            icon: const Icon(Icons.folder_open_rounded, size: 18),
                            label: const Text(
                              'Local Nodes',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colours.orbCoral,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(configsAdapterProvider.notifier)
                                  .getConfigs();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              l10n.retry,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (!isConnecting)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () => context.go(HomeView.path),
                        child: const Text(
                          'Continue to Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
