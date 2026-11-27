import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';

/// A quota snapshot from the server (never includes pending local usage).
class UsageQuotaModel extends QuotaEntity {
  const UsageQuotaModel({
    required super.day,
    required super.usedBytes,
    required super.bonusBytes,
    required super.freeBytes,
    required super.bonusPerAdBytes,
    required super.maxBonusesPerDay,
    required super.bonusesLeftToday,
    required super.resetsAt,
    required super.serverTime,
    required super.fetchedAt,
  });

  /// Parses a quota function response. Throws on a malformed body.
  ///
  /// The bonus fields are optional so a snapshot cached by an older build
  /// (or an older server) still loads; they read as "no bonus available"
  /// until the next server answer.
  factory UsageQuotaModel.fromServer(
    DataMap map, {
    required DateTime receivedAt,
  }) {
    return UsageQuotaModel(
      day: map['day'] as String,
      usedBytes: (map['usedBytes'] as num).toInt(),
      bonusBytes: (map['bonusBytes'] as num).toInt(),
      freeBytes: (map['freeBytes'] as num).toInt(),
      bonusPerAdBytes: (map['bonusPerAdBytes'] as num?)?.toInt() ?? 0,
      maxBonusesPerDay: (map['maxBonusesPerDay'] as num?)?.toInt() ?? 0,
      bonusesLeftToday: (map['bonusesLeftToday'] as num?)?.toInt() ?? 0,
      resetsAt: DateTime.parse(map['resetsAt'] as String),
      serverTime: DateTime.parse(map['serverTime'] as String),
      fetchedAt: receivedAt,
    );
  }

  /// Reads a snapshot saved with [toMap].
  factory UsageQuotaModel.fromMap(DataMap map) {
    return UsageQuotaModel.fromServer(
      map,
      receivedAt: DateTime.parse(map['fetchedAt'] as String),
    );
  }

  DataMap toMap() {
    return {
      'day': day,
      'usedBytes': usedBytes,
      'bonusBytes': bonusBytes,
      'freeBytes': freeBytes,
      'bonusPerAdBytes': bonusPerAdBytes,
      'maxBonusesPerDay': maxBonusesPerDay,
      'bonusesLeftToday': bonusesLeftToday,
      'resetsAt': resetsAt!.toUtc().toIso8601String(),
      'serverTime': serverTime!.toUtc().toIso8601String(),
      'fetchedAt': fetchedAt!.toUtc().toIso8601String(),
    };
  }
}
