import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
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
      return Constants.androidBannerAdIdTest;
    } else if (Platform.isIOS) {
      return Constants.iosBannerAdIdTest;
    }
    return null;
  }

  static String? get interstitialAdId {
    if (Platform.isAndroid) {
      return Constants.interstialAdUnitId;
    } else if (Platform.isIOS) {
      return Constants.iOSInterstialAdUnitId;
    } else if (Platform.isLinux) {
      return Constants.linuxInterstialAdUnitId;
    } else if (Platform.isWindows) {
      return Constants.windowsInterstialAdUnitId;
    }
    return null;
  }

  static void showSnackBar(
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
}
