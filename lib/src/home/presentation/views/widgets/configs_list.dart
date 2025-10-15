import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/config_tile.dart';

import '../../../../../core/res/styles/colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'connection_status.dart';

class ConfigsList extends ConsumerWidget {
  const ConfigsList({super.key});
  static const path = '/configs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(currentConfigsListProvider);
    final status = ref.watch(connectionAdapterProvider().notifier).status;
 ref.watch(currentThemeProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.50,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: CoreUtils.adabtiveColor(
              context,
              lightModeColor: Colours.onWightColor,
              darkModeColor: Colours.onBlackColor,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: CoreUtils.adabtiveColor(
            //       context,
            //       lightModeColor: Colours.darkBackgroundColor,
            //       darkModeColor: Colours.lightBackgroundColor,
            //     ),
            //     blurRadius: 10,
            //     offset: const Offset(3, 3),
            //   ),
            // ],
          ),
          child: ValueListenableBuilder(
            valueListenable: status,
            builder: (context, value, child) {
              return ListView.builder(
                controller: controller,
                itemCount: list.length + 1,
                itemBuilder: (ctx, index) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: FilledButton(
                          onPressed: () async {},
                          child: Text(
                            AppLocalizations.of(context)!.get_servers,
                          ),
                        ),
                      ),
                    );
                  }
                  int configsIndex = index - 1;
                  if (index == 0) {
                    return ConnectionIndicator();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: ConfigTile(config: list[configsIndex]),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
