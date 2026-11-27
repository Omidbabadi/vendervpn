import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

/// Nodes the user imported (links, QR codes, subscriptions). Never touches
/// the cloud node list or the quota.
abstract class LocalNodesRepo {
  const LocalNodesRepo();

  /// Saved nodes; entries whose link no longer parses are skipped.
  List<Config> cachedNodes();

  ResultFuture<void> saveNodes(List<Config> nodes);

  List<SubscriptionItem> cachedSubscriptions();

  ResultFuture<void> saveSubscriptions(List<SubscriptionItem> subscriptions);

  ResultFuture<SubscriptionFetch> fetchSubscription(String url);

  /// Right(null) when the provider reports no account info.
  ResultFuture<SubscriptionUserInfo?> fetchSubscriptionInfo(String url);

  /// Node links found in pasted text (plain lines or base64).
  List<String> extractLinks(String rawPayload);

  /// Links that don't parse are skipped.
  ResultFuture<List<Config>> parseLinks({
    required List<String> links,
    required String importedFrom,
    String? idScope,
  });
}
