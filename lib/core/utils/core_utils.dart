import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:country_flags/country_flags.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:toastification/toastification.dart';
import 'package:vendervpn/core/utils/consts.dart';

abstract class CoreUtils {
  const CoreUtils();

  static Color adabtiveColor(
    BuildContext context, {
    required Color lightModeColor,
    required Color darkModeColor,
  }) {
    return context.isDarkMode ? darkModeColor : lightModeColor;
  }


  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return Constants.androidBannerAdId;
    } else if (Platform.isIOS) {
      return Constants.iosBannerAdId;
    }
    return null;
  }

  static String? get interstitialAdId {
    if (Platform.isAndroid) {
      return Constants.androidInterstialAdUnitId;
    } else if (Platform.isIOS) {
      return Constants.iOSInterstialAdUnitId;
    }
    return null;
  }

  static bool isConnected(String state) {
    return switch (state) {
      'CONNECTED' => true,
      _ => false,
    };
  }

  static Color isConnectedColor(bool isConnected) {
    return isConnected ? Colours.connectedColor : Colours.grayColor;
  }

  static showSnackBar(
    BuildContext context,
    bool isError, {
    required String title,
    required String message,
  }) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      title: Text(title),
      style: ToastificationStyle.fillColored,
      type: !isError ? ToastificationType.success : ToastificationType.error,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      dragToClose: true,
    );
  }

  static CountryFlag getCountryFlag(String currencyCode) {
    return CountryFlag.fromCountryCode(
      currencyCode,
      theme: ImageTheme(shape: Circle()),
    );
  }

  static Map<String, double>? countryCenter(String countryIso) {
    final centers = {
      'AF': {'lat': 33.9391, 'lon': 67.7100},
      'AL': {'lat': 41.1533, 'lon': 20.1683},
      'DZ': {'lat': 28.0339, 'lon': 1.6596},
      'AD': {'lat': 42.5063, 'lon': 1.5218},
      'AO': {'lat': -11.2027, 'lon': 17.8739},
      'AR': {'lat': -38.4161, 'lon': -63.6167},
      'AM': {'lat': 40.0691, 'lon': 45.0382},
      'AU': {'lat': -25.2744, 'lon': 133.7751},
      'AT': {'lat': 47.5162, 'lon': 14.5501},
      'AZ': {'lat': 40.1431, 'lon': 47.5769},
      'BH': {'lat': 26.0667, 'lon': 50.5577},
      'BD': {'lat': 23.6850, 'lon': 90.3563},
      'BY': {'lat': 53.7098, 'lon': 27.9534},
      'BE': {'lat': 50.8503, 'lon': 4.3517},
      'BZ': {'lat': 17.1899, 'lon': -88.4976},
      'BJ': {'lat': 9.3077, 'lon': 2.3158},
      'BT': {'lat': 27.5142, 'lon': 90.4336},
      'BO': {'lat': -16.2902, 'lon': -63.5887},
      'BA': {'lat': 43.9159, 'lon': 17.6791},
      'BW': {'lat': -22.3285, 'lon': 24.6849},
      'BR': {'lat': -14.2350, 'lon': -51.9253},
      'BN': {'lat': 4.5353, 'lon': 114.7277},
      'BG': {'lat': 42.7339, 'lon': 25.4858},
      'BF': {'lat': 12.2383, 'lon': -1.5616},
      'BI': {'lat': -3.3731, 'lon': 29.9189},
      'KH': {'lat': 12.5657, 'lon': 104.9910},
      'CM': {'lat': 7.3697, 'lon': 12.3547},
      'CA': {'lat': 56.1304, 'lon': -106.3468},
      'CL': {'lat': -35.6751, 'lon': -71.5430},
      'CN': {'lat': 35.8617, 'lon': 104.1954},
      'CO': {'lat': 4.5709, 'lon': -74.2973},
      'CR': {'lat': 9.7489, 'lon': -83.7534},
      'HR': {'lat': 45.1000, 'lon': 15.2000},
      'CU': {'lat': 21.5218, 'lon': -77.7812},
      'CY': {'lat': 35.1264, 'lon': 33.4299},
      'CZ': {'lat': 49.8175, 'lon': 15.4730},
      'DK': {'lat': 56.2639, 'lon': 9.5018},
      'DO': {'lat': 18.7357, 'lon': -70.1627},
      'EC': {'lat': -1.8312, 'lon': -78.1834},
      'EG': {'lat': 26.8206, 'lon': 30.8025},
      'EE': {'lat': 58.5953, 'lon': 25.0136},
      'ET': {'lat': 9.1450, 'lon': 40.4897},
      'FI': {'lat': 61.9241, 'lon': 25.7482},
      'FR': {'lat': 46.6034, 'lon': 1.8883},
      'GE': {'lat': 42.3154, 'lon': 43.3569},
      'DE': {'lat': 51.1657, 'lon': 10.4515},
      'GH': {'lat': 7.9465, 'lon': -1.0232},
      'GR': {'lat': 39.0742, 'lon': 21.8243},
      'GT': {'lat': 15.7835, 'lon': -90.2308},
      'HN': {'lat': 15.2000, 'lon': -86.2419},
      'HK': {'lat': 22.3193, 'lon': 114.1694},
      'HU': {'lat': 47.1625, 'lon': 19.5033},
      'IS': {'lat': 64.9631, 'lon': -19.0208},
      'IN': {'lat': 20.5937, 'lon': 78.9629},
      'ID': {'lat': -0.7893, 'lon': 113.9213},
      'IR': {'lat': 32.4279, 'lon': 53.6880},
      'IQ': {'lat': 33.2232, 'lon': 43.6793},
      'IE': {'lat': 53.4129, 'lon': -8.2439},
      'IL': {'lat': 31.0461, 'lon': 34.8516},
      'IT': {'lat': 41.8719, 'lon': 12.5674},
      'JP': {'lat': 36.2048, 'lon': 138.2529},
      'JO': {'lat': 30.5852, 'lon': 36.2384},
      'KZ': {'lat': 48.0196, 'lon': 66.9237},
      'KE': {'lat': -0.0236, 'lon': 37.9062},
      'KR': {'lat': 35.9078, 'lon': 127.7669},
      'KW': {'lat': 29.3117, 'lon': 47.4818},
      'KG': {'lat': 41.2044, 'lon': 74.7661},
      'LA': {'lat': 19.8563, 'lon': 102.4955},
      'LV': {'lat': 56.8796, 'lon': 24.6032},
      'LB': {'lat': 33.8547, 'lon': 35.8623},
      'LY': {'lat': 26.3351, 'lon': 17.2283},
      'LT': {'lat': 55.1694, 'lon': 23.8813},
      'LU': {'lat': 49.8153, 'lon': 6.1296},
      'MY': {'lat': 4.2105, 'lon': 101.9758},
      'MX': {'lat': 23.6345, 'lon': -102.5528},
      'MD': {'lat': 47.4116, 'lon': 28.3699},
      'MN': {'lat': 46.8625, 'lon': 103.8467},
      'MA': {'lat': 31.7917, 'lon': -7.0926},
      'NP': {'lat': 28.3949, 'lon': 84.1240},
      'NL': {'lat': 52.1326, 'lon': 5.2913},
      'NZ': {'lat': -40.9006, 'lon': 174.8860},
      'NG': {'lat': 9.0820, 'lon': 8.6753},
      'NO': {'lat': 60.4720, 'lon': 8.4689},
      'PK': {'lat': 30.3753, 'lon': 69.3451},
      'PS': {'lat': 31.9522, 'lon': 35.2332},
      'PA': {'lat': 8.5379, 'lon': -80.7821},
      'PY': {'lat': -23.4425, 'lon': -58.4438},
      'PE': {'lat': -9.1900, 'lon': -75.0152},
      'PH': {'lat': 12.8797, 'lon': 121.7740},
      'PL': {'lat': 51.9194, 'lon': 19.1451},
      'PT': {'lat': 39.3999, 'lon': -8.2245},
      'QA': {'lat': 25.3548, 'lon': 51.1839},
      'RO': {'lat': 45.9432, 'lon': 24.9668},
      'RU': {'lat': 61.5240, 'lon': 105.3188},
      'SA': {'lat': 23.8859, 'lon': 45.0792},
      'RS': {'lat': 44.0165, 'lon': 21.0059},
      'SG': {'lat': 1.3521, 'lon': 103.8198},
      'SK': {'lat': 48.6690, 'lon': 19.6990},
      'SI': {'lat': 46.1512, 'lon': 14.9955},
      'ZA': {'lat': -30.5595, 'lon': 22.9375},
      'ES': {'lat': 40.4637, 'lon': -3.7492},
      'SE': {'lat': 60.1282, 'lon': 18.6435},
      'CH': {'lat': 46.8182, 'lon': 8.2275},
      'SY': {'lat': 34.8021, 'lon': 38.9968},
      'TH': {'lat': 15.8700, 'lon': 100.9925},
      'TR': {'lat': 38.9637, 'lon': 35.2433},
      'UA': {'lat': 48.3794, 'lon': 31.1656},
      'AE': {'lat': 23.4241, 'lon': 53.8478},
      'GB': {'lat': 55.3781, 'lon': -3.4360},
      'US': {'lat': 37.0902, 'lon': -95.7129},
      'VN': {'lat': 14.0583, 'lon': 108.2772},
      'YE': {'lat': 15.5527, 'lon': 48.5164},
    };
    return centers[countryIso.toUpperCase()];
  }
}
