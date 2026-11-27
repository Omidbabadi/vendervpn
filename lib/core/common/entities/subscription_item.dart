import 'package:vendervpn/core/common/entities/subscription_user_info.dart';

/// A saved subscription URL and how often it is refreshed.
class SubscriptionItem {
  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.url,
    required this.intervalHours,
    required this.lastUpdated,
    this.userInfo,
  });

  final String id;
  final String name;
  final String url;
  final int intervalHours;
  final DateTime lastUpdated;
  final SubscriptionUserInfo? userInfo;

  bool get isDueForUpdate {
    if (intervalHours <= 0) return false;
    return DateTime.now().difference(lastUpdated) >=
        Duration(hours: intervalHours);
  }

  SubscriptionItem copyWith({
    String? id,
    String? name,
    String? url,
    int? intervalHours,
    DateTime? lastUpdated,
    SubscriptionUserInfo? userInfo,
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      intervalHours: intervalHours ?? this.intervalHours,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}
