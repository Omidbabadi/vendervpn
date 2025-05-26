import 'package:flutter/foundation.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

Future<void> showAdThanConnect(Function onAdCompleted) async {
  try {
    final isAdLoaded = await Appodeal.isLoaded(AppodealAdType.Interstitial);
    if (isAdLoaded) {
      debugPrint('ad is loaded');
      Appodeal.show(AppodealAdType.Interstitial);
      onAdCompleted();
    } else {
      debugPrint('ad is not loaded');
      onAdCompleted();
    }
  } catch (e) {
    debugPrint(e.toString());
    onAdCompleted();
  }
}
