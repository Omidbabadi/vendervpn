import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Cache {
  Cache._internal();

  static final instance = Cache._internal();

  String? _url;

  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  BannerAd? _bannerAd;

  BannerAd? get bannerAd => _bannerAd;

  Map<String, String> _map = {};

  Map<String, String> get map => _map;

  void setBannerAd(BannerAd banner) {
    print('baner Ad: ${banner.adUnitId}');
    _bannerAd = banner;
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
