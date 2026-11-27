import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vendervpn/core/common/app/riverpod/current_locale.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/l10n/l10n.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'core/res/styles/app_theme.dart';
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
