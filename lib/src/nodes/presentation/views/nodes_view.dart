import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/config_tile.dart';
import 'package:vendervpn/src/nodes/presentation/views/widgets/import_action_card.dart';
import 'package:vendervpn/src/nodes/presentation/views/widgets/local_nodes_grouped_list.dart';
import 'package:vendervpn/src/nodes/presentation/views/widgets/qr_scanner_sheet.dart';
import 'package:vendervpn/src/nodes/presentation/views/widgets/tab_pill_button.dart';

class NodesView extends ConsumerWidget {
  const NodesView({super.key});
  static const path = '/nodes';

  Future<void> _importFromClipboard(BuildContext context, WidgetRef ref) async {
    final uiState = ref.read(nodesViewUiStateProvider);
    if (uiState.isImporting) return;
    ref.read(nodesViewUiStateProvider.notifier).setImporting(true);
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) {
        if (!context.mounted) return;
        CoreUtils.showSnackBar(
          context,
          true,
          title: 'Clipboard Empty',
          message: 'Copy a V2Ray link or subscription URL first.',
        );
        return;
      }

      final count = await ref
          .read(localConfigsListProvider.notifier)
          .importFromRawPayload(text, source: 'clipboard');
      if (!context.mounted) return;
      if (count > 0) {
        CoreUtils.showSnackBar(
          context,
          false,
          title: 'Nodes Imported',
          message: 'Added $count V2Ray node(s) from clipboard.',
        );
      } else {
        CoreUtils.showSnackBar(
          context,
          true,
          title: 'Invalid Format',
          message:
              'No valid vmess://, vless://, trojan://, ss://, or hy2:// links found.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CoreUtils.showSnackBar(
        context,
        true,
        title: 'Import Failed',
        message: e.toString(),
      );
    } finally {
      ref.read(nodesViewUiStateProvider.notifier).setImporting(false);
    }
  }

  Future<void> _showSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    ref.read(nodesViewUiStateProvider.notifier).setSubIntervalHours(6);
    const intervalOptions = [1, 6, 12, 24, 0]; // 0 = Manual only
    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);

    final result = await showModalBottomSheet<
      ({String name, String url, int intervalHours})
    >(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, modalRef, _) {
            final selectedIntervalHours =
                modalRef.watch(nodesViewUiStateProvider).subIntervalHours;
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.viewInsetsOf(ctx).bottom +
                    MediaQuery.paddingOf(ctx).bottom +
                    12,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(30),
                  ),
                  border: Border.all(color: Colours.subtleBorder(ctx)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colours.pastelLilacBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rss_feed_rounded,
                            color: Colours.pastelLilacFg,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Subscription URL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Auto-syncs V2Ray configs on your chosen schedule',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colours.subtitleGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Subscription Name Input
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Subscription Name',
                        labelStyle: const TextStyle(
                          color: Colours.subtitleGrey,
                          fontSize: 12,
                        ),
                        hintText: 'e.g. Premium EU Nodes',
                        hintStyle: const TextStyle(color: Colours.subtitleGrey),
                        prefixIcon: const Icon(
                          Icons.label_outline_rounded,
                          size: 18,
                          color: Colours.orbViolet,
                        ),
                        filled: true,
                        fillColor: Colours.softChipBg(ctx),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Subscription URL Input
                    TextField(
                      controller: urlController,
                      autofocus: true,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Subscription URL',
                        labelStyle: const TextStyle(
                          color: Colours.subtitleGrey,
                          fontSize: 12,
                        ),
                        hintText: 'https://example.com/sub/...',
                        hintStyle: const TextStyle(color: Colours.subtitleGrey),
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          size: 18,
                          color: Colours.orbViolet,
                        ),
                        filled: true,
                        fillColor: Colours.softChipBg(ctx),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.content_paste_rounded,
                            size: 18,
                          ),
                          onPressed: () async {
                            final clip = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );
                            if (clip?.text != null) {
                              urlController.text = clip!.text!.trim();
                              if (nameController.text.trim().isEmpty) {
                                final uri = Uri.tryParse(urlController.text);
                                if (uri != null && uri.host.isNotEmpty) {
                                  nameController.text = uri.host;
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Auto-Update Interval Selector (1h, 6h, 12h, 24h, Manual)
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: Colours.subtitleGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Auto-Update Interval',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          intervalOptions.map((hours) {
                            final isSelected = selectedIntervalHours == hours;
                            final label =
                                hours == 0 ? 'Manual' : 'Every ${hours}h';
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: hours == intervalOptions.last ? 0 : 6,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    modalRef
                                        .read(nodesViewUiStateProvider.notifier)
                                        .setSubIntervalHours(hours);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colours.orbViolet
                                              : Colours.softChipBg(ctx),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colours.orbViolet
                                                : Colours.subtleBorder(ctx),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : textColor.withValues(
                                                  alpha: 0.75,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 18),

                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colours.orbViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed:
                          () => Navigator.of(ctx).pop((
                            name: nameController.text.trim(),
                            url: urlController.text.trim(),
                            intervalHours: selectedIntervalHours,
                          )),
                      child: const Text(
                        'Save & Fetch Configs',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || result.url.isEmpty) return;
    ref.read(nodesViewUiStateProvider.notifier).setImporting(true);
    try {
      final rawUrl = result.url;
      final int count;
      if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        count = await ref
            .read(localConfigsListProvider.notifier)
            .importSubscriptionUrl(
              rawUrl,
              name: result.name,
              intervalHours: result.intervalHours,
            );
      } else {
        count = await ref
            .read(localConfigsListProvider.notifier)
            .importFromRawPayload(
              rawUrl,
              source:
                  result.name.isNotEmpty
                      ? 'sub:${result.name}'
                      : 'subscription',
            );
      }
      if (!context.mounted) return;
      if (count > 0) {
        final intervalText =
            result.intervalHours > 0
                ? 'Auto-updates every ${result.intervalHours}h.'
                : 'Manual update mode.';
        CoreUtils.showSnackBar(
          context,
          false,
          title: 'Subscription Synced',
          message: 'Imported $count node(s). $intervalText',
        );
      } else {
        CoreUtils.showSnackBar(
          context,
          true,
          title: 'No Nodes Found',
          message: 'Could not parse any V2Ray nodes from that URL.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CoreUtils.showSnackBar(
        context,
        true,
        title: 'Subscription Error',
        message: e.toString(),
      );
    } finally {
      ref.read(nodesViewUiStateProvider.notifier).setImporting(false);
    }
  }

  Future<void> _showQrScannerSheet(BuildContext context, WidgetRef ref) async {
    final qrPayload = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QrScannerSheet(),
    );

    if (qrPayload == null || qrPayload.isEmpty) return;
    ref.read(nodesViewUiStateProvider.notifier).setImporting(true);
    try {
      final count = await ref
          .read(localConfigsListProvider.notifier)
          .importFromRawPayload(qrPayload, source: 'qrcode');
      if (!context.mounted) return;
      if (count > 0) {
        CoreUtils.showSnackBar(
          context,
          false,
          title: 'QR Node Added',
          message: 'Scanned & imported $count V2Ray node(s) into Local Nodes.',
        );
      } else {
        CoreUtils.showSnackBar(
          context,
          true,
          title: 'Invalid QR Code',
          message:
              'Scanned QR code did not contain a valid V2Ray URI or subscription.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CoreUtils.showSnackBar(
        context,
        true,
        title: 'QR Scan Error',
        message: e.toString(),
      );
    } finally {
      ref.read(nodesViewUiStateProvider.notifier).setImporting(false);
    }
  }

  Future<void> _pingAllActiveTab(WidgetRef ref) async {
    final uiState = ref.read(nodesViewUiStateProvider);
    if (uiState.isPingingAll) return;
    ref.read(nodesViewUiStateProvider.notifier).setPingingAll(true);
    try {
      final selectedTab = uiState.selectedTab;
      final list =
          selectedTab == 0
              ? ref.read(currentConfigsListProvider)
              : ref.read(localConfigsListProvider);
      final connAdapter = ref.read(connectionAdapterProvider.notifier);

      for (final node in list) {
        final delay = await connAdapter.ping(node.configjson);
        if (selectedTab == 0) {
          ref
              .read(currentConfigsListProvider.notifier)
              .updateConfigPing(node.id, delay);
        } else {
          ref
              .read(localConfigsListProvider.notifier)
              .updateConfigPing(node.id, delay);
        }
      }
    } finally {
      ref.read(nodesViewUiStateProvider.notifier).setPingingAll(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    final uiState = ref.watch(nodesViewUiStateProvider);
    final selectedTab = uiState.selectedTab;
    final isImporting = uiState.isImporting;
    final isPingingAll = uiState.isPingingAll;

    final cloudConfigs = ref.watch(currentConfigsListProvider);
    final localConfigs = ref.watch(localConfigsListProvider);
    final subscriptions = ref.watch(subscriptionsListProvider);
    final configsState = ref.watch(configsAdapterProvider);
    final isCloudSyncing = configsState is ConfigsLoading;
    final connectionState = ref.watch(connectionAdapterProvider);
    final isConnected = connectionState is ConnectionStateConnected;

    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final activeList = selectedTab == 0 ? cloudConfigs : localConfigs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header + Dot-Matrix Counter + Ping All / Sync ───
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tunnel Endpoints',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colours.subtitleGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Nodes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: DotMatrixText(
                          text: activeList.length.toString().padLeft(2, '0'),
                          dotSize: 2.2,
                          dotSpacing: 1.0,
                          charSpacing: 3.8,
                          activeColor: Colours.orbEmerald,
                          inactiveColor: textColor.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Ping All Pill
              GestureDetector(
                onTap: () => _pingAllActiveTab(ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colours.subtleBorder(context)),
                    boxShadow: Colours.softCardShadow(context),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPingingAll)
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: Colours.orbEmerald,
                          ),
                        )
                      else
                        const Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: Colours.orbEmerald,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        'Ping All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (selectedTab == 0) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap:
                      isCloudSyncing
                          ? null
                          : () =>
                              ref
                                  .read(configsAdapterProvider.notifier)
                                  .getConfigs(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colours.subtleBorder(context)),
                      boxShadow: Colours.softCardShadow(context),
                    ),
                    child: Center(
                      child:
                          isCloudSyncing
                              ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: Colours.orbViolet,
                                ),
                              )
                              : Icon(
                                Icons.sync_rounded,
                                size: 18,
                                color: textColor,
                              ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ─── Segmented Two-Tab Switcher (Cloud Nodes vs Local Nodes) ───
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colours.softChipBg(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colours.subtleBorder(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabPillButton(
                    title: 'Cloud Nodes (${cloudConfigs.length})',
                    icon: Icons.cloud_done_outlined,
                    selected: selectedTab == 0,
                    onTap:
                        () => ref
                            .read(nodesViewUiStateProvider.notifier)
                            .setSelectedTab(0),
                  ),
                ),
                Expanded(
                  child: TabPillButton(
                    title: 'Local Nodes (${localConfigs.length})',
                    icon: Icons.folder_special_outlined,
                    selected: selectedTab == 1,
                    onTap:
                        () => ref
                            .read(nodesViewUiStateProvider.notifier)
                            .setSelectedTab(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── Local Nodes Import Toolbar (Clipboard, QR Code, Subscription) ───
          if (selectedTab == 1) ...[
            Row(
              children: [
                Expanded(
                  child: ImportActionCard(
                    icon: Icons.content_paste_go_rounded,
                    label: 'Clipboard',
                    accent: Colours.orbEmerald,
                    onTap: () => _importFromClipboard(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ImportActionCard(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'QR Code',
                    accent: Colours.orbCoral,
                    onTap: () => _showQrScannerSheet(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ImportActionCard(
                    icon: Icons.rss_feed_rounded,
                    label: 'Sub URL',
                    accent: Colours.orbViolet,
                    onTap: () => _showSubscriptionDialog(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ─── Nodes List ───
          Expanded(
            child:
                isImporting && activeList.isEmpty
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colours.orbViolet,
                      ),
                    )
                    : activeList.isEmpty &&
                        (selectedTab == 0 || subscriptions.isEmpty)
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selectedTab == 0
                                ? Icons.cloud_off_rounded
                                : Icons.add_link_rounded,
                            size: 44,
                            color: Colours.subtitleGrey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedTab == 0
                                ? 'No cloud nodes synced yet'
                                : 'No local nodes imported yet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedTab == 0
                                ? 'Tap the sync icon above to fetch Appwrite nodes'
                                : 'Import from Clipboard, QR Code, or Subscription URL',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colours.subtitleGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : selectedTab == 0
                    ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: activeList.length,
                      itemBuilder: (context, index) {
                        return ConfigTile(
                          config: activeList[index],
                          isConnected: isConnected,
                          isLocal: false,
                        );
                      },
                    )
                    : LocalNodesGroupedList(
                      localConfigs: localConfigs,
                      subscriptions: subscriptions,
                      isConnected: isConnected,
                      collapsedSubKeys: uiState.collapsedSubKeys,
                    ),
          ),
        ],
      ),
    );
  }
}
