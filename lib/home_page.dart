import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vendervpn/enums/menu_actions.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:vendervpn/services/api_service.dart';
import 'package:vendervpn/widgets/home_page_widget.dart';
import 'package:vendervpn/widgets/show_alert.dart';
import 'package:vendervpn/widgets/show_snackbar.dart';
import 'package:hive/hive.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final Box<ConfigModel> configsBox = Hive.box('configs');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.dispose();
  }

  void _changeLocale() {
    showAlertDialog(
      context: context,
      actions: [
        FilledButton(
          onPressed: () {
            ref.read(userPrefsProvider.notifier).setLanguage('fa');
            Navigator.of(context).pop();
          },
          child: Text('فارسی'),
        ),
        FilledButton(
          onPressed: () {
            ref.read(userPrefsProvider.notifier).setLanguage('en');
                        Navigator.of(context).pop();

          },
          child: Text('english'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
      title:  Text(AppLocalizations.of(context)!.change_language_title),
    );
  }

  Future<void> refreshConfigs() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    final apiService = ApiService();
    try {
      final configs = await apiService.getConfigsList();
      if (configs == null) {
        setState(() {
          _isLoading = !_isLoading;
        });
        return;
      }

      if (configs.isEmpty) {
        if (mounted) {
          showSnackBar(
            context,
            true,
            title: 'Server Issue',
            message: '0 Servers Found',
          );
          setState(() {
            _isLoading = !_isLoading;
          });
        }return;
      }
      if (mounted) {
        showSnackBar(
          context,
          false,
          title: 'Successful',
          message: '${configs.length.toString()} Servers Found',
        );
      }
      ref.read(userPrefsProvider.notifier).setDefaultConfig(configs[0]);
      await configsBox.clear();
      await configsBox.addAll(configs);
    } catch (e) {
      if (mounted) {
        showSnackBar(context, true, title: 'Error', message: '$e');

        setState(() {
          _isLoading = !_isLoading;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String moreIcon = 'assets/More-Square.svg';
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<MenuActions>(
            icon: SvgPicture.asset(
              moreIcon,
              height: 40,
              width: 40,
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 0, 255, 179),
                BlendMode.srcIn,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) async {
              switch (value) {
                case MenuActions.refreshServers:
                  refreshConfigs();
               
                  break;
                case MenuActions.changeLanguage:
                  _changeLocale();
                  
                  break;

                case MenuActions.toggleTheme:
                 ref.read(userPrefsProvider.notifier).toggleTheme();
                  break;
                
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuActions.refreshServers,
                  child: Text(
                    AppLocalizations.of(context)!.get_servers,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: MenuActions.changeLanguage,
                  child: Text(
                    AppLocalizations.of(context)!.language,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: MenuActions.toggleTheme,
                  child: Text(
                    AppLocalizations.of(context)!.change_theme,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'V  E  N  D  E  R  V  P  N',
          style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
        ),
        backgroundColor: Colors.transparent,
        //const Color.fromARGB(255, 40, 45, 53),
      ),
      body: HomePageWidget(),
    );
  }
}
