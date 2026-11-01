import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/per_app_proxy/presention/app/adpter/per_app_proxy_adapter.dart';

class PerAppProxySheet extends ConsumerStatefulWidget {
  const PerAppProxySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PerAppProxySheet(),
    );
  }

  @override
  ConsumerState<PerAppProxySheet> createState() => _PerAppProxySheetState();
}

class _PerAppProxySheetState extends ConsumerState<PerAppProxySheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final state = ref.read(perAppProxyProvider);
      ref
          .read(perAppProxyProvider.notifier)
          .loadInstalledApps(includeSystem: state.showSystemApps);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(perAppProxyProvider);
    final notifier = ref.read(perAppProxyProvider.notifier);
    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final apps = state.filteredApps;
    final isBypass = state.mode == PerAppProxyMode.bypass;
    final accentColor = isBypass ? Colours.pastelAmberFg : Colours.orbViolet;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 36,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.86,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colours.subtleBorder(context)),
          boxShadow: Colours.softCardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colours.subtitleGrey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color:
                          isBypass
                              ? Colours.pastelAmberBg
                              : Colours.pastelLilacBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isBypass
                          ? Icons.alt_route_rounded
                          : Icons.apps_outage_rounded,
                      size: 20,
                      color: accentColor,
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
                                l10n.per_app_proxy_title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isBypass
                                        ? Colours.pastelAmberBg
                                        : Colours.pastelLilacBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${state.selectedPackages.length} ${l10n.selected_apps_count}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBypass
                              ? l10n.per_app_mode_bypass_desc
                              : l10n.per_app_mode_proxy_desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colours.subtitleGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.selectedPackages.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifier.clearSelectedApps();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colours.pastelRoseFg,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        l10n.clear_selection,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Mode Switcher (Per-App Proxy vs Bypass Mode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colours.softChipBg(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTabButton(
                        label: l10n.per_app_mode_proxy,
                        icon: Icons.shield_outlined,
                        selected: state.mode == PerAppProxyMode.perApp,
                        activeColor: Colours.orbViolet,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.setMode(PerAppProxyMode.perApp);
                        },
                      ),
                    ),
                    Expanded(
                      child: _ModeTabButton(
                        label: l10n.per_app_mode_bypass,
                        icon: Icons.alt_route_rounded,
                        selected: state.mode == PerAppProxyMode.bypass,
                        activeColor: Colours.pastelAmberFg,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.setMode(PerAppProxyMode.bypass);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar & System Apps Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: notifier.setSearchQuery,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: l10n.search_apps_hint,
                        hintStyle: const TextStyle(
                          color: Colours.subtitleGrey,
                          fontSize: 12.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Colours.subtitleGrey,
                        ),
                        suffixIcon:
                            state.searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.setSearchQuery('');
                                  },
                                )
                                : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        filled: true,
                        fillColor: Colours.softChipBg(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notifier.setShowSystemApps(!state.showSystemApps);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            state.showSystemApps
                                ? Colours.orbViolet.withValues(alpha: 0.14)
                                : Colours.softChipBg(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              state.showSystemApps
                                  ? Colours.orbViolet
                                  : Colours.subtleBorder(context),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.android_rounded,
                            size: 15,
                            color:
                                state.showSystemApps
                                    ? Colours.orbViolet
                                    : Colours.subtitleGrey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.show_system_apps,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color:
                                  state.showSystemApps
                                      ? Colours.orbViolet
                                      : Colours.subtitleGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: Colours.subtleBorder(context),
            ),

            // Installed Apps List
            Expanded(
              child:
                  state.isLoadingApps
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: accentColor),
                            const SizedBox(height: 12),
                            Text(
                              l10n.loading_apps,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colours.subtitleGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : apps.isEmpty
                      ? Center(
                        child: Text(
                          l10n.no_apps_found,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colours.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                        itemCount: apps.length,
                        itemBuilder: (ctx, index) {
                          final app = apps[index];
                          final isSelected = state.selectedPackages.contains(
                            app.packageName,
                          );
                          return _AppSelectionTile(
                            app: app,
                            isSelected: isSelected,
                            isBypass: isBypass,
                            textColor: textColor,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.toggleApp(app.packageName);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  const _ModeTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Colours.classicAdabtiveTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9.5, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colours.cardSurface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? Colours.softCardShadow(context) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? activeColor : Colours.subtitleGrey,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? textColor : Colours.subtitleGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppSelectionTile extends StatelessWidget {
  const _AppSelectionTile({
    required this.app,
    required this.isSelected,
    required this.isBypass,
    required this.textColor,
    required this.onTap,
  });

  final AppInfo app;
  final bool isSelected;
  final bool isBypass;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isBypass ? Colours.pastelAmberFg : Colours.orbViolet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? activeColor.withValues(alpha: 0.09)
                    : Colours.softChipBg(context).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isSelected
                      ? activeColor.withValues(alpha: 0.55)
                      : Colours.subtleBorder(context),
            ),
          ),
          child: Row(
            children: [
              // App Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colours.cardSurface(context),
                  borderRadius: BorderRadius.circular(11),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    app.icon != null && app.icon!.isNotEmpty
                        ? Image.memory(
                          app.icon!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder:
                              (_, _, _) => const Icon(
                                Icons.android_rounded,
                                size: 22,
                                color: Colours.subtitleGrey,
                              ),
                        )
                        : const Icon(
                          Icons.android_rounded,
                          size: 22,
                          color: Colours.subtitleGrey,
                        ),
              ),
              const SizedBox(width: 12),

              // App Name & Package Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (app.isSystemApp) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colours.subtleBorder(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SYS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colours.subtitleGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.packageName,
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
              const SizedBox(width: 10),

              // Selection Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? activeColor
                            : Colours.subtitleGrey.withValues(alpha: 0.45),
                    width: 1.8,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
