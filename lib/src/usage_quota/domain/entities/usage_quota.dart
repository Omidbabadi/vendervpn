import 'package:equatable/equatable.dart';

/// Today's data allowance for cloud nodes.
///
/// Every day the user gets [freeBytes] for free. Each completed rewarded ad
/// adds [rewardBytes] on top. At midnight everything resets (bonus included).
class UsageQuota extends Equatable {
  const UsageQuota({
    required this.day,
    required this.usedBytes,
    required this.bonusBytes,
  });

  /// A fresh allowance for [day]: nothing used, no bonus.
  const UsageQuota.empty(this.day) : usedBytes = 0, bonusBytes = 0;

  static const int freeBytes = 500 * 1024 * 1024; // 500 MB
  static const int rewardBytes = 1024 * 1024 * 1024; // 1 GB

  /// The day this quota belongs to, as `yyyy-MM-dd` in local time.
  final String day;
  final int usedBytes;
  final int bonusBytes;

  int get limitBytes => freeBytes + bonusBytes;

  int get remainingBytes => (limitBytes - usedBytes).clamp(0, limitBytes);

  bool get isExceeded => usedBytes >= limitBytes;

  UsageQuota withUsage(int bytes) {
    return UsageQuota(
      day: day,
      usedBytes: usedBytes + bytes,
      bonusBytes: bonusBytes,
    );
  }

  UsageQuota withRewardBonus() {
    return UsageQuota(
      day: day,
      usedBytes: usedBytes,
      bonusBytes: bonusBytes + rewardBytes,
    );
  }

  static String dayOf(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}-$month-$day';
  }

  @override
  List<Object?> get props => [day, usedBytes, bonusBytes];
}
