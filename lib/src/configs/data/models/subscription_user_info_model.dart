import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

class SubscriptionUserInfoModel extends SubscriptionUserInfo {
  const SubscriptionUserInfoModel({
    required super.upload,
    required super.download,
    required super.total,
    required super.expire,
    super.announce,
    super.hasTrafficData,
  });

  SubscriptionUserInfoModel.fromEntity(SubscriptionUserInfo info)
    : this(
        upload: info.upload,
        download: info.download,
        total: info.total,
        expire: info.expire,
        announce: info.announce,
        hasTrafficData: info.hasTrafficData,
      );

  factory SubscriptionUserInfoModel.fromMap(DataMap map) {
    final rawAnnounce = (map['announce'] as String?)?.trim();
    return SubscriptionUserInfoModel(
      upload: int.tryParse((map['upload'] ?? '0').toString()) ?? 0,
      download: int.tryParse((map['download'] ?? '0').toString()) ?? 0,
      total: int.tryParse((map['total'] ?? '0').toString()) ?? 0,
      expire: int.tryParse((map['expire'] ?? '0').toString()) ?? 0,
      hasTrafficData: map['hasTrafficData'] as bool? ?? true,
      announce:
          (rawAnnounce != null && rawAnnounce.isNotEmpty) ? rawAnnounce : null,
    );
  }

  DataMap toMap() => {
    'upload': upload,
    'download': download,
    'total': total,
    'expire': expire,
    'hasTrafficData': hasTrafficData,
    if (announce != null && announce!.trim().isNotEmpty) 'announce': announce,
  };
}
