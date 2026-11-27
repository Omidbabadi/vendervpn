import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/data/models/subscription_user_info_model.dart';

class SubscriptionItemModel extends SubscriptionItem {
  const SubscriptionItemModel({
    required super.id,
    required super.name,
    required super.url,
    required super.intervalHours,
    required super.lastUpdated,
    super.userInfo,
  });

  SubscriptionItemModel.fromEntity(SubscriptionItem item)
    : this(
        id: item.id,
        name: item.name,
        url: item.url,
        intervalHours: item.intervalHours,
        lastUpdated: item.lastUpdated,
        userInfo: item.userInfo,
      );

  factory SubscriptionItemModel.fromMap(DataMap map) {
    final url = (map['url'] as String? ?? '').trim();
    final uri = Uri.tryParse(url);
    final fallbackName =
        (uri != null && uri.host.isNotEmpty) ? uri.host : 'Subscription';
    final rawName = (map['name'] as String? ?? '').trim();
    final rawUserInfo = map['userInfo'];
    return SubscriptionItemModel(
      id: map['id'] as String? ?? 'sub_${url.hashCode.abs()}',
      name: rawName.isNotEmpty ? rawName : fallbackName,
      url: url,
      intervalHours:
          int.tryParse((map['intervalHours'] ?? '6').toString()) ?? 6,
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
      userInfo:
          rawUserInfo is Map
              ? SubscriptionUserInfoModel.fromMap(
                Map<String, dynamic>.from(rawUserInfo),
              )
              : null,
    );
  }

  DataMap toMap() => {
    'id': id,
    'name': name,
    'url': url,
    'intervalHours': intervalHours,
    'lastUpdated': lastUpdated.toIso8601String(),
    if (userInfo != null)
      'userInfo': SubscriptionUserInfoModel.fromEntity(userInfo!).toMap(),
  };
}
