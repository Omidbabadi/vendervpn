import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_cloud_usage.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_reward_bonus.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/get_usage_quota.dart';

final usageQuotaProvider = NotifierProvider<UsageQuotaAdapter, UsageQuota>(
  UsageQuotaAdapter.new,
);

/// Holds today's cloud-node quota for the UI and the connection flow.
class UsageQuotaAdapter extends Notifier<UsageQuota> {
  final _getUsageQuota = sl<GetUsageQuota>();
  final _addCloudUsage = sl<AddCloudUsage>();
  final _addRewardBonus = sl<AddRewardBonus>();

  // Writes run one after another, so two quick updates can't overwrite
  // each other in storage.
  Future<void> _pendingWrite = Future.value();

  @override
  UsageQuota build() {
    Future.microtask(refresh);
    return UsageQuota.empty(UsageQuota.dayOf(DateTime.now()));
  }

  /// Reloads the quota from storage (this also rolls over to a new day).
  Future<UsageQuota> refresh() async {
    _applyResult(await _getUsageQuota.call());
    return state;
  }

  Future<void> addUsage(int bytes) {
    _pendingWrite = _pendingWrite.then((_) async {
      _applyResult(await _addCloudUsage.call(bytes));
    });
    return _pendingWrite;
  }

  Future<void> addRewardBonus() {
    _pendingWrite = _pendingWrite.then((_) async {
      _applyResult(await _addRewardBonus.call());
    });
    return _pendingWrite;
  }

  void _applyResult(Result<UsageQuota> result) {
    if (!ref.mounted) return;
    result.fold(
      (failure) {
        debugPrint('Usage quota error: ${failure.message}');
      },
      (quota) {
        state = quota;
      },
    );
  }
}
