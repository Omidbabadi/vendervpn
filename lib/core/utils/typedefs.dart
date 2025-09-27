import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/model/v2ray_status.dart';

import '../errors/failures.dart';

typedef DataMap = Map<String, dynamic>;
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef Result<T> = Either<Failure, T>;
typedef Status = ValueNotifier<V2RayStatus>;
