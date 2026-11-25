import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';

class UsageQuotaModel extends UsageQuota {
  const UsageQuotaModel({
    required super.day,
    required super.usedBytes,
    required super.bonusBytes,
  });

  const UsageQuotaModel.empty(String day) : super.empty(day);

  factory UsageQuotaModel.fromEntity(UsageQuota quota) {
    return UsageQuotaModel(
      day: quota.day,
      usedBytes: quota.usedBytes,
      bonusBytes: quota.bonusBytes,
    );
  }

  factory UsageQuotaModel.fromMap(DataMap map) {
    return UsageQuotaModel(
      day: map['day'] as String,
      usedBytes: (map['usedBytes'] as num).toInt(),
      bonusBytes: (map['bonusBytes'] as num).toInt(),
    );
  }

  DataMap toMap() {
    return {'day': day, 'usedBytes': usedBytes, 'bonusBytes': bonusBytes};
  }
}
