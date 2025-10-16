import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/unity_ads/domain/usecase/is_initialize.dart';

import '../../domain/usecase/show_interstitial.dart';

part 'ads_adapter.g.dart';
part 'ad_state.dart';

@Riverpod(keepAlive: true)
class AdsAdapter extends _$AdsAdapter {
  @override
  AdsState build([GlobalKey? familyKey]) {
    _showInterstitial = sl<ShowInterstitial>();
    _initialize = sl<IsInitialize>();
    return InitialAds();
  }

  late ShowInterstitial _showInterstitial;
  late IsInitialize _initialize;

  Future<void> initialize() async {
    state = const InitializingAds();
    final result = await _initialize.call();
    result.fold(
      (l) {
        state = AdsError(l.message);
      },
      (r) {
        state = const AdsIntialized();
      },
    );
  }

  Future<void> showInterstitial() async {
    final result = await _showInterstitial.call('Interstitial_Android');
    result.fold(
      (l) {
        state = AdsError(l.message);
      },
      (r) {
        state = const AdsLoaded();
      },
    );
  }
}
