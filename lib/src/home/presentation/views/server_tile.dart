import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

import '../../../../core/common/app/riverpod/current_config.dart';
import '../../../../core/common/entities/config.dart';
import '../../../../core/res/styles/text.dart';
import '../../../../core/utils/core_utils.dart';

class ServerTile extends ConsumerWidget {
  const ServerTile({
    super.key,
    required this.dimmed,
    required this.config,
    required this.country,
  });
  final bool dimmed;
  final Config config;
  final String country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: GestureDetector(
        onTap: () {
          ref.read(currentConfigProvider.notifier).setCurrentConfig(config);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CoreUtils.adabtiveColor(
              context,
              lightModeColor: Colours.lightModeListTileColor,
              darkModeColor: Colours.daarkModeListTileColor,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CoreUtils.getCountryFlag(config.country!),
              const SizedBox(width: 16),

              Column(                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    country,
                    style: TextStyles.paragraphSubTextRegular
                        .copyWith(fontSize: 10)
                        .adaptiveColor(context),
                  ),
                  Text(config.remark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
