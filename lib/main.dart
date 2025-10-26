import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/l10n/l10n.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/src/admob/domain/usecase/init.dart';

import 'core/common/singelton/unity_ads_core.dart';
import 'core/res/styles/colors.dart';
import 'core/services/injection_container.dart';
import 'core/services/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  late Init initad = sl<Init>();
  final result = await initad.call();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colours.lightThemePrimaryColor,
      ),
      scaffoldBackgroundColor: Colours.lightBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colours.lightBackgroundColor,
        foregroundColor: Colours.lightThemePrimaryTextColor,
      ),

      useMaterial3: true,
    );
    final themeMode = ref.watch(currentThemeProvider);
    return MaterialApp.router(
      supportedLocales: L10n.all,
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Vender VPN',
      theme: theme,
      themeMode: themeMode,
      darkTheme: theme.copyWith(
        scaffoldBackgroundColor: Colours.darkBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colours.darkBackgroundColor,
          foregroundColor: Colours.darkThemePrimaryTextColor,
        ),
      ),
      routerConfig: router,
    );
  }
}
