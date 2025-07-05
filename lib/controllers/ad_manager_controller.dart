import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdManagerController extends Notifier<AdManagerState> {
  @override
  AdManagerState build() {
    _initUnityAds();
    return const AdManagerState.initial();
  }

  Future<void> _initUnityAds() async {
    //TO-DO: add ios game id
    await UnityAds.init(
      testMode: false,
      gameId: '5867671',
      firebaseTestLabMode: FirebaseTestLabMode.disableAds,
      onComplete: () {
        state = state.copyWith(initialzed: true);
      },
      onFailed: (error, message) {
        state = state.copyWith(error: '$error: $message');
      },
    );
  }

  Future<void> loadUnityAd(String placementId) async {
    debugPrint('loadUnityAd called');
    await UnityAds.load(
      placementId: placementId,
      onComplete: (placementId) {
        state = state.copyWith(adLoaded: true);
        debugPrint(state.adLoaded.toString());
      },
      onFailed: (placementId, error, errorMessage) {
        debugPrint(state.adLoaded.toString());

        state = state.copyWith(
          error: '$error: $errorMessage with this placementId: $placementId',
        );
      },
    );
  }

  Future<void> showUnityVideoAd(String placementId) async {
    debugPrint('showUnityVideoAd');
    await UnityAds.showVideoAd(
      placementId: placementId,
      onComplete: (placementId) {
        state = state.copyWith(adCompleted: true, adLoaded: false);
        loadUnityAd(placementId);
      },
      onFailed:
          (placemenId, error, message) =>
              state = state.copyWith(
                adLoaded: false,
                error: '$error: $message with this placementId: $placementId',
              ),
    );
  }
}

class AdManagerState {
  final bool initialzed;
  final bool adLoaded;
  final bool adCompleted;
  final bool adSkipped;
  final String? error;

  const AdManagerState({
    required this.initialzed,
    required this.adLoaded,
    required this.adCompleted,
    required this.adSkipped,
    this.error,
  });

  const AdManagerState.initial()
    : initialzed = false,
      adLoaded = false,
      adCompleted = false,
      adSkipped = false,
      error = null;

  AdManagerState copyWith({
    bool? initialzed,
    bool? adLoaded,
    bool? adCompleted,
    bool? adSkipped,
    String? error,
  }) {
    return AdManagerState(
      initialzed: initialzed ?? this.initialzed,
      adLoaded: adLoaded ?? this.adLoaded,
      adCompleted: adCompleted ?? this.adCompleted,
      adSkipped: adSkipped ?? this.adSkipped,
      error: error,
    );
  }
}
