import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/res/media.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/configs_list.dart';

import '../../../../core/common/singelton/unity_ads_core.dart';
import 'widgets/connection_button.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  static const path = '/home';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    return Stack(
      children: [
        SizedBox(
          height: context.height / 2,
          width: context.width,
          child: Image.asset(
            context.isDarkMode ? Media.darkModeMap : Media.lightModeMap,
            fit: BoxFit.fitHeight,
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          top: context.height / 10,
          child: ConnectionButton(),
        ),
        ConfigsList(),
        Positioned(
          top: 0,
          child: sl<UnityAdsService>().showBannerAd('Banner_Android')
        ),
      ],
    );
  }
}
