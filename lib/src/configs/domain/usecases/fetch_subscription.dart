import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// Downloads a subscription URL: its links and account info.
class FetchSubscription extends UsecaseWithParams<SubscriptionFetch, String> {
  const FetchSubscription(this._repo);
  final LocalNodesRepo _repo;

  @override
  ResultFuture<SubscriptionFetch> call(String params) =>
      _repo.fetchSubscription(params);
}
