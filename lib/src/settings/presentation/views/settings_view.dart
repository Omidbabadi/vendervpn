import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_locale.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/per_app_proxy/presention/app/adpter/per_app_proxy_adapter.dart';
import 'package:vendervpn/src/per_app_proxy/presention/views/per_app_proxy_sheet.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});
  static const path = '/settings';

  void _setTheme(ThemeMode mode) {
    HapticFeedback.selectionClick();
    sl<CacheHelper>().cacheThemeMode(mode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(currentThemeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);
    final perAppState = ref.watch(perAppProxyProvider);
    final perAppNotifier = ref.read(perAppProxyProvider.notifier);
    final isConnected =
        ref.watch(connectionAdapterProvider) is ConnectionStateConnected;

    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final isBypass = perAppState.mode == PerAppProxyMode.bypass;
    final perAppAccent = isBypass ? Colours.pastelAmberFg : Colours.orbViolet;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            l10n.preferences_subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colours.subtitleGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.settings_title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          // ─── 1. THEME CHANGER (Light / Dark / System) ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colours.subtleBorder(context)),
              boxShadow: Colours.softCardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colours.pastelLilacBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: Colours.pastelLilacFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.theme_appearance,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colours.softChipBg(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OptionPill(
                          label: l10n.theme_light,
                          icon: Icons.light_mode_rounded,
                          selected: currentTheme == ThemeMode.light,
                          onTap: () => _setTheme(ThemeMode.light),
                        ),
                      ),
                      Expanded(
                        child: _OptionPill(
                          label: l10n.theme_dark,
                          icon: Icons.dark_mode_rounded,
                          selected: currentTheme == ThemeMode.dark,
                          onTap: () => _setTheme(ThemeMode.dark),
                        ),
                      ),
                      Expanded(
                        child: _OptionPill(
                          label: l10n.theme_system,
                          icon: Icons.auto_awesome_rounded,
                          selected: currentTheme == ThemeMode.system,
                          onTap: () => _setTheme(ThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── 2. APP LANGUAGE (English / Persian) ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colours.subtleBorder(context)),
              boxShadow: Colours.softCardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colours.pastelMintBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        size: 18,
                        color: Colours.pastelMintFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.app_language,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colours.softChipBg(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OptionPill(
                          label: 'English (EN)',
                          icon: Icons.translate_rounded,
                          selected: currentLocale.languageCode == 'en',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(currentLocaleProvider.notifier)
                                .setLocale('en');
                          },
                        ),
                      ),
                      Expanded(
                        child: _OptionPill(
                          label: 'فارسی (FA)',
                          icon: Icons.translate_rounded,
                          selected: currentLocale.languageCode == 'fa',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(currentLocaleProvider.notifier)
                                .setLocale('fa');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── 3. CONNECTION MODE (VPN Mode vs Proxy Mode) ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color:
                    perAppState.proxyOnly
                        ? Colours.orbCyan.withValues(alpha: 0.45)
                        : Colours.subtleBorder(context),
              ),
              boxShadow: Colours.softCardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            perAppState.proxyOnly
                                ? Colours.orbCyan.withValues(alpha: 0.14)
                                : Colours.pastelLilacBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        perAppState.proxyOnly
                            ? Icons.lan_rounded
                            : Icons.vpn_lock_rounded,
                        size: 18,
                        color:
                            perAppState.proxyOnly
                                ? Colours.orbCyan
                                : Colours.pastelLilacFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.connection_mode_title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.connection_mode_subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colours.subtitleGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colours.softChipBg(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OptionPill(
                          label: l10n.vpn_mode_label,
                          icon: Icons.vpn_lock_rounded,
                          selected: !perAppState.proxyOnly,
                          activeColor: Colours.orbViolet,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            perAppNotifier.setProxyOnly(false);
                          },
                        ),
                      ),
                      if (Platform.isAndroid)
                        Expanded(
                          child: _OptionPill(
                            label: l10n.proxy_mode_label,
                            icon: Icons.lan_rounded,
                            selected: perAppState.proxyOnly,
                            activeColor: Colours.orbCyan,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              perAppNotifier.setProxyOnly(true);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colours.softChipBg(context).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colours.subtleBorder(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        perAppState.proxyOnly
                            ? Icons.hub_outlined
                            : Icons.shield_outlined,
                        size: 15,
                        color:
                            perAppState.proxyOnly
                                ? Colours.orbCyan
                                : Colours.orbViolet,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          perAppState.proxyOnly
                              ? l10n.proxy_mode_desc
                              : l10n.vpn_mode_desc,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isConnected) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 13.5,
                        color: Colours.subtitleGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.reconnect_to_apply,
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
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (Platform.isAndroid) ...[
            // ─── 4. PER-APP PROXY (Per-App Proxy vs Bypass Mode) ───
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color:
                      perAppState.isEnabled
                          ? perAppAccent.withValues(alpha: 0.45)
                          : Colours.subtleBorder(context),
                ),
                boxShadow: Colours.softCardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isBypass
                                  ? Colours.pastelAmberBg
                                  : Colours.pastelLilacBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isBypass
                              ? Icons.alt_route_rounded
                              : Icons.apps_outage_rounded,
                          size: 18,
                          color: perAppAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.per_app_proxy_title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.per_app_proxy_subtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colours.subtitleGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: perAppState.isEnabled,
                        activeThumbColor: perAppAccent,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          perAppNotifier.setEnabled(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Two-Mode Selector: Per-App Proxy vs Bypass Mode
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colours.softChipBg(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _OptionPill(
                            label: l10n.per_app_mode_proxy,
                            icon: Icons.shield_outlined,
                            selected: perAppState.mode == PerAppProxyMode.perApp,
                            activeColor: Colours.orbViolet,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              perAppNotifier.setMode(PerAppProxyMode.perApp);
                            },
                          ),
                        ),
                        Expanded(
                          child: _OptionPill(
                            label: l10n.per_app_mode_bypass,
                            icon: Icons.alt_route_rounded,
                            selected: perAppState.mode == PerAppProxyMode.bypass,
                            activeColor: Colours.pastelAmberFg,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              perAppNotifier.setMode(PerAppProxyMode.bypass);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Mode explanation banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colours.softChipBg(context).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colours.subtleBorder(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isBypass
                              ? Icons.call_split_rounded
                              : Icons.filter_alt_outlined,
                          size: 15,
                          color: perAppAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isBypass
                                ? l10n.per_app_mode_bypass_desc
                                : l10n.per_app_mode_proxy_desc,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Select Apps Button
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      PerAppProxySheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: perAppAccent.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: perAppAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.checklist_rtl_rounded,
                            size: 18,
                            color: perAppAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.manage_apps,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: perAppAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${perAppState.selectedPackages.length} ${l10n.selected_apps_count}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: textColor.withValues(alpha: 0.65),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isConnected && perAppState.isEnabled) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 13.5,
                          color: Colours.subtitleGrey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.reconnect_to_apply,
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
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // ─── 5. BETA RELEASE FOOTER ───
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colours.subtleBorder(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 14,
                    color: Colours.orbViolet,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'VenderVPN v1.0.0-beta.1',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colours.pastelLilacBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'BETA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colours.pastelLilacFg,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.activeColor = Colours.orbViolet,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final textColor = Colours.classicAdabtiveTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
