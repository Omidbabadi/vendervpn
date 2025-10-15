import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/services/injection_container.dart';

import '../../domain/usecase/show_interstitial.dart';

part 'ads_adapter.g.dart';
part 'ad_state.dart';

@riverpod
class AdsAdapter extends _$AdsAdapter {
  @override
  AdsState build([GlobalKey? familyKey]) {
    _showInterstitial = sl<ShowInterstitial>();
    return InitialAds();
  }

  late ShowInterstitial _showInterstitial;

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
