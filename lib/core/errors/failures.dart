import 'package:equatable/equatable.dart';

import 'exceptions.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode});
  final String message;
  final int statusCode;

  String get errorMessage => '$statusCode Error: $message';

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.statusCode});
  ServerFailure.fromException(ServerException e)
    : this(message: e.message, statusCode: e.statusCode);
}

class AdmobFailure extends Failure {
  const AdmobFailure({required super.message}) : super(statusCode: 1);
  AdmobFailure.fromException(AdmobException e) : this(message: e.message);
}

// class UnityAdsFailure extends Failure {
//   const UnityAdsFailure({required super.message}) : super(statusCode: 2);
//   UnityAdsFailure.fromException(UnityException e) : this(message: e.message);
// }

class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(statusCode: 3);
  CacheFailure.fromException(CacheException e) : this(message: e.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message}) : super(statusCode: 4);
  ConnectionFailure.fromException(ConnectionException e)
    : this(message: e.message);
}
