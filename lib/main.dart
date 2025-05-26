import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vendervpn/home_page.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/models/user_preferences.dart';
import 'package:vendervpn/theme/dark_theme.dart';
import 'package:vendervpn/theme/light_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vendervpn/l10n/l10n.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:vendervpn/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserPreferencesAdapter());
  Hive.registerAdapter(ConfigModelAdapter());
  await Hive.openBox<UserPreferences>('userPrefs');
  await Hive.openBox<ConfigModel>('configs');
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: L10n.all,
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Flutter V2Ray',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: SafeArea(child: const MyHomePage()),
    );
  }
}
