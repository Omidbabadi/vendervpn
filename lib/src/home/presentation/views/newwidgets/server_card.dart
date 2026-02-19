import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/utils/core_utils.dart';

import '../../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../../core/res/styles/colors.dart';
import '../../../../../core/res/styles/text.dart';
import '../configs_list_view.dart';

class ServerCard extends ConsumerWidget {
  const ServerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    final config = ref.watch(currentConfigProvider);
    if (config == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        context.go(ServerListScreen.path);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CoreUtils.adabtiveColor(
            context,
            lightModeColor: Colours.lightModeListTileColor,
            darkModeColor: Colours.daarkModeListTileColor,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CoreUtils.adabtiveColor(
              context,
              lightModeColor: Colors.grey.shade200,
              darkModeColor: const Color(0xFF242C3D),
            ),
          ),
        ),
        child: Row(
          children: [
            CoreUtils.getCountryFlag(config.country!),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyles.paragraphSubTextRegular.adaptiveColor(
                      context,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    config.remark,
                    style: TextStyles.paragraphSubTextRegular
                        .copyWith(fontSize: 10)
                        .adaptiveColor(context),
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                Icon(Icons.signal_cellular_alt, color: Colors.green, size: 18),
                SizedBox(width: 4),
                Text(
                  '34ms',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
