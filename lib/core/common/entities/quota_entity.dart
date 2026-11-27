import 'package:equatable/equatable.dart';

/// Today's data allowance for cloud nodes, as the quota server reports it.
///
/// The server owns the numbers and the day boundary (midnight Asia/Tehran).
/// [pendingBytes] is traffic this device has counted but not reported yet, so
/// the meter and the connection cutoff stay live between reports.
class QuotaEntity extends Equatable {
  const QuotaEntity({
    required this.day,
    required this.usedBytes,
    required this.bonusBytes,
    required this.freeBytes,
    required this.bonusPerAdBytes,
    required this.maxBonusesPerDay,
    required this.bonusesLeftToday,
    required this.resetsAt,
    required this.serverTime,
    required this.fetchedAt,
    this.pendingBytes = 0,
  });

  /// Nothing has been loaded from the server yet. All amounts are zero: the
  /// app has no built-in limits, only the server's.
  const QuotaEntity.unknown()
    : day = '',
      usedBytes = 0,
      bonusBytes = 0,
      freeBytes = 0,
      bonusPerAdBytes = 0,
      maxBonusesPerDay = 0,
      bonusesLeftToday = 0,
      resetsAt = null,
      serverTime = null,
      fetchedAt = null,
      pendingBytes = 0;

  /// The server's day, `yyyy-MM-dd`. Empty while [isKnown] is false.
  final String day;

  /// Usage the server has confirmed.
  final int usedBytes;

  /// Bonus granted today (sum of rewarded ads).
  final int bonusBytes;

  /// Free data per day (server `FREE_BYTES`).
  final int freeBytes;

  /// What one rewarded ad adds (server `BONUS_BYTES`).
  final int bonusPerAdBytes;

  /// Most ads that pay out per day (server `MAX_BONUSES_PER_DAY`).
  final int maxBonusesPerDay;

  /// Ads that will still pay out today.
  final int bonusesLeftToday;

  /// When the server's day ends and the quota resets (server clock, UTC).
  final DateTime? resetsAt;

  /// The server clock when this snapshot was made.
  final DateTime? serverTime;

  /// The device clock when this snapshot arrived.
  final DateTime? fetchedAt;

  /// Counted on this device, not yet confirmed by the server.
  final int pendingBytes;

  bool get isKnown => fetchedAt != null;

  int get totalUsedBytes => usedBytes + pendingBytes;

  int get totalBytes => freeBytes + bonusBytes;

  int get remainingBytes => (totalBytes - totalUsedBytes).clamp(0, totalBytes);

  bool get isExhausted => isKnown && totalUsedBytes >= totalBytes;

  /// Server clock minus device clock, so a wrong device clock doesn't matter.
  Duration get _clockSkew {
    final server = serverTime;
    final local = fetchedAt;
    if (server == null || local == null) return Duration.zero;
    return server.difference(local);
  }

  DateTime serverNow([DateTime? now]) =>
      (now ?? DateTime.now()).add(_clockSkew);

  /// The snapshot is still for the server's current day.
  bool isCurrent([DateTime? now]) {
    final end = resetsAt;
    return end != null && serverNow(now).isBefore(end);
  }

  /// Current and fetched less than [maxAge] ago.
  bool isFresh(Duration maxAge, [DateTime? now]) {
    final at = fetchedAt;
    if (at == null) return false;
    final t = now ?? DateTime.now();
    return isCurrent(t) && !t.isBefore(at) && t.difference(at) < maxAge;
  }

  /// [resetsAt] on the device clock.
  DateTime? get localResetsAt => resetsAt?.subtract(_clockSkew);

  QuotaEntity withPending(int bytes) => _copy(pendingBytes: bytes);

  /// A rewarded ad would still add data today, per the server's numbers.
  bool get canEarnBonus =>
      isKnown && bonusPerAdBytes > 0 && bonusesLeftToday > 0;

  /// Estimate after one rewarded ad, using the server's per-ad amount (the
  /// server confirms the real number). Unchanged when no bonus is left.
  QuotaEntity withRewardBonus() {
    if (!canEarnBonus) return this;
    return _copy(
      bonusBytes: bonusBytes + bonusPerAdBytes,
      bonusesLeftToday: bonusesLeftToday - 1,
    );
  }

  QuotaEntity _copy({
    int? bonusBytes,
    int? bonusesLeftToday,
    int? pendingBytes,
  }) {
    return QuotaEntity(
      day: day,
      usedBytes: usedBytes,
      bonusBytes: bonusBytes ?? this.bonusBytes,
      freeBytes: freeBytes,
      bonusPerAdBytes: bonusPerAdBytes,
      maxBonusesPerDay: maxBonusesPerDay,
      bonusesLeftToday: bonusesLeftToday ?? this.bonusesLeftToday,
      resetsAt: resetsAt,
      serverTime: serverTime,
      fetchedAt: fetchedAt,
      pendingBytes: pendingBytes ?? this.pendingBytes,
    );
  }

  @override
  List<Object?> get props => [
    day,
    usedBytes,
    bonusBytes,
    freeBytes,
    bonusPerAdBytes,
    maxBonusesPerDay,
    bonusesLeftToday,
    resetsAt,
    serverTime,
    fetchedAt,
    pendingBytes,
  ];
}
