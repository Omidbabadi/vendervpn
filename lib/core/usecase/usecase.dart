import '../utils/typedefs.dart';

abstract class UsecaseWithParams<Type, Params> {
  const UsecaseWithParams();

  ResultFuture<Type> call(Params params);
}

abstract class UsecaseWithOutParams<Type> {
  const UsecaseWithOutParams();

  ResultFuture<Type> call();
}

abstract class UsecaseWithOutParamsNotFuture<Type> {
  const UsecaseWithOutParamsNotFuture();

  Type call();
}

abstract class UsecaseWithOutParamsGeter<Type> {
  const UsecaseWithOutParamsGeter();

  Type get call;
}
