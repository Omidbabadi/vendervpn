import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vendervpn/enums/menu_actions.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:vendervpn/widgets/home_page_widget.dart';
import 'package:vendervpn/widgets/show_snackbar.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.dispose();
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(children: [TextField(controller: _controller)]),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                ref
                    .read(v2rayControllerProvider.notifier)
                    .importFromSubcrtion(_controller.text);
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(v2rayControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          showSnackBar(
            context,
            true,
            title: AppLocalizations.of(context)!.error,
            message: err.toString(),
          );
        },
      );
    });
    //final controller = ref.watch(v2rayControllerProvider);
    final connectedConfig = ref.watch(userPrefsProvider).defaultConfig;
    //  final configsList = ref.watch(configsListProvider);
    const String assetName = 'assets/Category.svg';
    const String addIcon = 'assets/Paper Plus.svg';
    final Brightness isDark = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<MenuAction>(
            icon: SvgPicture.asset(
              addIcon,
              height: 40,
              width: 40,
              colorFilter: ColorFilter.mode(
                isDark == Brightness.dark
                    ? const Color.fromARGB(255, 0, 255, 179)
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.importFromClipBoard:
                  ref
                      .read(v2rayControllerProvider.notifier)
                      .importFromClipboard();
                //_importFromClipBoard();
                //break;
                case MenuAction.importFromQrCode:
                //_importFromQrcode();
                //  break;

                case MenuAction.importSub:
                //_subLinks();
                // await showAlert();
                case MenuAction.updateSubs:
                //_updateSubs();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuAction.importFromClipBoard,
                  child: Text(
                    AppLocalizations.of(context)!.import_from_clipboard,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: MenuAction.importFromQrCode,
                  child: Text(
                    AppLocalizations.of(context)!.import_from_qrcode,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: MenuAction.importSub,
                  child: Text(
                    AppLocalizations.of(context)!.import_sub_link,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: MenuAction.updateSubs,
                  child: Text(
                    AppLocalizations.of(context)!.coming_soon,
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
      body: HomePageWidget(
        connect:
            () => ref
                .read(v2rayControllerProvider.notifier)
                .connect(config: connectedConfig!),
        delay: () => ref.read(v2rayControllerProvider.notifier).getDelay(),
        disConnect:
            () => ref.read(v2rayControllerProvider.notifier).disconnect(),
      ),
    );
  }
}
