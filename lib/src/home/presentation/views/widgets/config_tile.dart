import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/res/styles/text.dart';

import '../../../../../core/common/entities/config.dart';
import '../../../../../core/res/styles/colors.dart';
import '../../../../../core/utils/core_utils.dart';

class ConfigTile extends ConsumerWidget {
  const ConfigTile({
    super.key,
    required this.config,
    required this.isConnected,
  });
  final Config config;
  final bool isConnected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConfig = ref.watch(currentConfigProvider);
    ref.watch(currentThemeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: CoreUtils.adabtiveColor(
            context,
            lightModeColor: Colours.lightModeListTileColor,
            darkModeColor: Colours.daarkModeListTileColor,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color:
                  selectedConfig != null && config.id == selectedConfig.id
                      ? Colours.connectedColor
                      : Colors.grey[300],
            ),
          ),
          onTap: () {
            if (isConnected) {
              return;
            }
            ref.read(currentConfigProvider.notifier).setCurrentConfig(config);
          },

          title: Text(
            config.remark,

            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyles.paragraphSubTextRegular.adaptiveColor(context),
          ),
          trailing: CoreUtils.getCountryFlag(config.country!),
          
        ),
      ),
    );
  }
}
