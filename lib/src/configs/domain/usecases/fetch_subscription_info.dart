import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// Only a subscription's account info (traffic, expiry, announcement).
class FetchSubscriptionInfo
    extends UsecaseWithParams<SubscriptionUserInfo?, String> {
  const FetchSubscriptionInfo(this._repo);
  final LocalNodesRepo _repo;

  @override
  ResultFuture<SubscriptionUserInfo?> call(String params) =>
      _repo.fetchSubscriptionInfo(params);
}
