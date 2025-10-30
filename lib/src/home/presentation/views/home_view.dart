import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/common/app/riverpod/banner_ad.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/configs_list.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/world_map.dart';

import '../../../info_screen/presention/views/status_screen.dart';
import '../../../info_screen/presention/views/utils/status_utils.dart';
import 'widgets/connection_button.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  static const path = '/home';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  @override
  Widget build(BuildContext context) {
          final _bannerAd = ref.watch(loadedBannerAdProvider);

    ref.listen(connectionAdapterProvider(), (p, next) async {
      if (next is ConnectionStateConnecting) {
        context.push(
          '/info',
          extra: StatusUtils('Connecting', Status.connecting),
        );
      }
    });
    ref.watch(currentThemeProvider);

    if (_bannerAd != null) {
      print('Home View: ${_bannerAd.adUnitId}');
    } else {
      print('banner ad was null');
    }

    return Column(
      children: [
        if (_bannerAd != null)
              SizedBox(
                height: 90,
                child: AdWidget(ad: _bannerAd,)),
        Expanded(
          child: Stack(
            children: [
              
          
              Positioned(top: 30, left: 0, right: 0, child: const WorldMap()),
              Positioned(
                left: 0,
                right: 0,
                top: context.height / 10,
                child: ConnectionButton(),
              ),
              ConfigsList(),
            ],
          ),
        ),
      ],
    );
  }
}
