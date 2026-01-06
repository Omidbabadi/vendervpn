import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Cache {
  Cache._internal();

  static final instance = Cache._internal();

  String? _url;
  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  Map<String, String> _map = {};
  Map<String, String> get map => _map;

  //interstitial ad
  InterstitialAd? get interstitialAd => _interstitialAd;
  void setInterstitialAd(InterstitialAd? ad) {
    _interstitialAd = ad;
  }

  void resetInterstitialAd() {
    _interstitialAd = null;
  }

  // rewarded ad
  RewardedAd? get rewardedAd => _rewardedAd;
  void setRewardedAd(RewardedAd ad) => _rewardedAd = ad;
  void resetRewardedAd() => _rewardedAd = null;

  // banner ad
  BannerAd? get bannerAd => _bannerAd;
  void setBannerAd(BannerAd? banner) {
    _bannerAd = banner;
  }

  void resetBannerAd() {
    _bannerAd = null;
  }

  void setMap(Map<String, String> map) {
    _map = map;
  }

  String? get url => _url;

  void setThemeMode(ThemeMode theme) {
    themeModeNotifier.value = theme;
  }

  void setUrl(String? id) {
    _url = id;
  }

  void reset() {
    setUrl(null);
  }
}
