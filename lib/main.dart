import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vendervpn/core/common/app/riverpod/current_locale.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/l10n/l10n.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'core/res/styles/colors.dart';
import 'core/services/injection_container.dart';
import 'core/services/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colours.orbViolet,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colours.lightBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colours.lightBackgroundColor,
        foregroundColor: Colours.lightThemePrimaryTextColor,
        elevation: 0,
      ),
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colours.orbViolet,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colours.darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colours.darkBackgroundColor,
        foregroundColor: Colours.darkThemePrimaryTextColor,
        elevation: 0,
      ),
      useMaterial3: true,
    );

    final themeMode = ref.watch(currentThemeProvider);
    final locale = ref.watch(currentLocaleProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Vender VPN',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
