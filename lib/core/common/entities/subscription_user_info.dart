import 'package:equatable/equatable.dart';

/// What a subscription provider reports about the account: traffic used and
/// allowed, expiry, and an optional announcement.
class SubscriptionUserInfo extends Equatable {
  const SubscriptionUserInfo({
    required this.upload,
    required this.download,
    required this.total,
    required this.expire,
    this.announce,
    this.hasTrafficData = true,
  });

  final int upload;
  final int download;
  final int total;
  final int expire;
  final String? announce;
  final bool hasTrafficData;

  int get used => upload + download;
  bool get isUnlimitedTraffic => total <= 0;
  bool get isUnlimitedExpire => expire <= 0;
  bool get hasAnnounce => announce != null && announce!.trim().isNotEmpty;

  double? get usageRatio {
    if (total <= 0) return null;
    return (used / total).clamp(0.0, 1.0);
  }

  DateTime? get expireDate {
    if (expire <= 0) return null;
    final ms = expire > 100000000000 ? expire : expire * 1000;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isExpired {
    final dt = expireDate;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt);
  }

  SubscriptionUserInfo copyWith({
    int? upload,
    int? download,
    int? total,
    int? expire,
    String? announce,
    bool? hasTrafficData,
  }) {
    return SubscriptionUserInfo(
      upload: upload ?? this.upload,
      download: download ?? this.download,
      total: total ?? this.total,
      expire: expire ?? this.expire,
      announce: announce ?? this.announce,
      hasTrafficData: hasTrafficData ?? this.hasTrafficData,
    );
  }

  @override
  List<Object?> get props => [
    upload,
    download,
    total,
    expire,
    announce,
    hasTrafficData,
  ];
}

/// The links a subscription returned and the account info it reported.
typedef SubscriptionFetch = ({
  List<String> links,
  SubscriptionUserInfo? userInfo,
});
