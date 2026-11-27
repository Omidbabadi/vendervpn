import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  const ServerException({required this.message, required this.statusCode});
  final String message;
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheException extends Equatable implements Exception {
  const CacheException({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class AdmobException extends Equatable implements Exception {
  const AdmobException(this.cause, {required this.message});
  final String message;

  /// The ad SDK's own error object, kept for logging. Typed as [Object] so
  /// core code does not depend on the ad SDK.
  final Object? cause;

  @override
  List<Object?> get props => [message];
}

// class UnityException extends Equatable implements Exception {
//   const UnityException({required this.message,this.unityAdsBannerError,this.unityAdsLoadError,this.unityAdsShowError,this.unityAdsInitializationError});
//   final String message;
//   final UnityAdsLoadError? unityAdsLoadError;
//   final UnityAdsShowError? unityAdsShowError;
//   final UnityAdsBannerError? unityAdsBannerError;
//   final UnityAdsInitializationError? unityAdsInitializationError;

//   @override
//   List<Object?> get props => [message,unityAdsLoadError,unityAdsShowError,unityAdsBannerError,unityAdsInitializationError];
// }

/// A node's share link or edited settings could not be read or built.
class ConfigEditException extends Equatable implements Exception {
  const ConfigEditException({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class ConnectionException extends Equatable implements Exception {
  const ConnectionException({required this.message, required this.ping});
  final String message;
  final int ping;

  @override
  List<Object?> get props => [message];
}
