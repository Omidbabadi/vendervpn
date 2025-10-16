import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

import '../repo/unity_ads_repo.dart';

class IsInitialize extends UsecaseWithOutParams<bool> {
  const IsInitialize(this._repo);

  final UnityAdsRepo _repo;

  @override
  ResultFuture<bool> call() => _repo.isInitialize();
}
