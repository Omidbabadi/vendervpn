part of 'admob_adapter.dart';

sealed class AdmobState extends Equatable {
  const AdmobState();

  @override
  List<Object?> get props => [];
}

final class AdmobInit extends AdmobState {
  const AdmobInit();
}


final class AdmobInitialzing extends AdmobState {
  const AdmobInitialzing();
}


final class AdmobInitialzed extends AdmobState {
  const AdmobInitialzed();
}

final class InterstitialAdLoading extends AdmobState {
  const InterstitialAdLoading();
}

final class InterstitialAdLoaded extends AdmobState {
  const InterstitialAdLoaded();
}

final class InterstitialAdShowing extends AdmobState {
  const InterstitialAdShowing();
}

final class InterstitialAdShowed extends AdmobState {
  const InterstitialAdShowed();
}


final class AdmobError extends AdmobState {
  const AdmobError(this.message);
  final String message;
}
