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
      return ad;
    } else {
      return null;
    }
  }

  void loadBannerAd(BannerAd bannerAd) {
    state = bannerAd;
  }

  void clearBannerAd() {
    state?.dispose();
    Cache.instance.resetBannerAd();
    state = null;
  }
}
