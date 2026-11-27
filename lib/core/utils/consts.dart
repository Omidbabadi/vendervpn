abstract class Constants {
  const Constants();

  // --- Interstitial Test IDs ---
  static const interstialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Android
  static const iOSInterstialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910'; // Fixed: iOS Interstitial

  // --- Banner Test IDs ---
  static const androidBannerAdIdTest =
      'ca-app-pub-3940256099942544/9214589741'; // Adaptive Banner
  static const iosBannerAdIdTest =
      'ca-app-pub-3940256099942544/2934735716'; // Fixed-size Banner

  // --- Rewarded Test IDs ---
  static const androidRewardedAdTest = 'ca-app-pub-3940256099942544/5224354917';
  static const iosRewardedAdTest = 'ca-app-pub-3940256099942544/1712485313';

  // --- Rewarded Interstitial Test IDs ---
  static const androidRewardedInterstitialAdTest =
      'ca-app-pub-3940256099942544/5354046379';
  static const iosRewardedInterstitialAdTest =
      'ca-app-pub-3940256099942544/6978759866';

  // --- App Open Test IDs ---
  static const androidAppOpenAdTest = 'ca-app-pub-3940256099942544/9257395921';
  static const iosAppOpenAdTest = 'ca-app-pub-3940256099942544/5575463023';

  // --- Native Advanced Test IDs ---
  static const androidNativeAdTest = 'ca-app-pub-3940256099942544/2247696110';
  static const iosNativeAdTest = 'ca-app-pub-3940256099942544/3986624511';

  static const List<String> subnets = [
    "0.0.0.0/5",
    "8.0.0.0/7",
    "11.0.0.0/8",
    "12.0.0.0/6",
    "16.0.0.0/4",
    "32.0.0.0/3",
    "64.0.0.0/2",
    "128.0.0.0/3",
    "160.0.0.0/5",
    "168.0.0.0/6",
    "172.0.0.0/12",
    "172.32.0.0/11",
    "172.64.0.0/10",
    "172.128.0.0/9",
    "173.0.0.0/8",
    "174.0.0.0/7",
    "176.0.0.0/4",
    "192.0.0.0/9",
    "192.128.0.0/11",
    "192.160.0.0/13",
    "192.169.0.0/16",
    "192.170.0.0/15",
    "192.172.0.0/14",
    "192.176.0.0/12",
    "192.192.0.0/10",
    "193.0.0.0/8",
    "194.0.0.0/7",
    "196.0.0.0/6",
    "200.0.0.0/5",
    "208.0.0.0/4",
    "240.0.0.0/4",
  ];
}
