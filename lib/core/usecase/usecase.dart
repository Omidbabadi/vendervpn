import '../utils/typedefs.dart';

abstract class UsecaseWithParams<T, Params> {
  const UsecaseWithParams();

  ResultFuture<T> call(Params params);
}

abstract class UsecaseWithOutParams<T> {
  const UsecaseWithOutParams();

  ResultFuture<T> call();
}

abstract class UsecaseWithOutParamsNotFuture<T> {
  const UsecaseWithOutParamsNotFuture();

  T call();
}

abstract class UsecaseWithOutParamsGeter<T> {
  const UsecaseWithOutParamsGeter();

  T get call;
}

abstract class UsecaseWithOutParamsFuture<T> {
  const UsecaseWithOutParamsFuture();

  Future<T> call();
}
