import 'package:country_flags/country_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';

abstract class CoreUtils {
  const CoreUtils();

  static Color adabtiveColor(
    BuildContext context, {
    required Color lightModeColor,
    required Color darkModeColor,
  }) {
    return context.isDarkMode ? darkModeColor : lightModeColor;
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

  /// True for an ISO 3166-1 alpha-2 code that can be rendered as a flag.
  static bool isValidCountryCode(String? code) =>
      code != null && RegExp(r'^[A-Za-z]{2}$').hasMatch(code);

  static CountryFlag getCountryFlag(String currencyCode) {
    return CountryFlag.fromCountryCode(
      currencyCode,
      theme: ImageTheme(shape: Circle()),
    );
  }
}
