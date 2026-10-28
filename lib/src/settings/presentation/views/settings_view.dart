import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_locale.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

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

    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);

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
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Colours.classicAdabtiveTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
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
              color: selected ? Colours.orbViolet : Colours.subtitleGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? textColor : Colours.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
