part of 'ads_adapter.dart';

abstract class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object?> get props => [];
}

final class InitialAds extends AdsState {
  const InitialAds();
}

final class InitializingAds extends AdsState {
  const InitializingAds();
}

final class AdsIntialized extends AdsState {
  const AdsIntialized();
}

final class AdsLoaded extends AdsState {
  const AdsLoaded();
}

final class AdsError extends AdsState {
  const AdsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
