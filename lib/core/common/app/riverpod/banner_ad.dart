import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'banner_ad.g.dart';

@Riverpod(keepAlive: true)
class LoadedBannerAd extends _$LoadedBannerAd {
  @override
  BannerAd? build() {
    return null;
  }

  loadBannerAd(BannerAd bannerAd) {
    state = bannerAd;
    debugPrint(bannerAd.adUnitId);
  }
}
