import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

class SaveSubscriptions
    extends UsecaseWithParams<void, List<SubscriptionItem>> {
  const SaveSubscriptions(this._repo);
  final LocalNodesRepo _repo;

  @override
  ResultFuture<void> call(List<SubscriptionItem> params) =>
      _repo.saveSubscriptions(params);
}
