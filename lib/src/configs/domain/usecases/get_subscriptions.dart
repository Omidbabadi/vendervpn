import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// The subscriptions saved on the device.
class GetSubscriptions
    extends UsecaseWithOutParamsNotFuture<List<SubscriptionItem>> {
  const GetSubscriptions(this._repo);
  final LocalNodesRepo _repo;

  @override
  List<SubscriptionItem> call() => _repo.cachedSubscriptions();
}
