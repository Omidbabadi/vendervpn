import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/singelton/core.dart';

part 'banner_ad.g.dart';

@Riverpod(keepAlive: true)
class LoadedBannerAd extends _$LoadedBannerAd {
  @override
  BannerAd? build() {
    final ad = Cache.instance.bannerAd;
    if (ad != null) {
      debugPrint('banner ad in ad mob provider build');
      return ad;
    } else {
      return null;
    }
  }

  loadBannerAd(BannerAd bannerAd) {
    state = bannerAd;
    debugPrint('banner ad in ad mob provider');
  }
}
