import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/data/datasrc/usage_quota_local_datasrc.dart';
import 'package:vendervpn/src/usage_quota/data/datasrc/usage_quota_remote_datasrc.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_outbox.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// The server is the source of truth. This keeps the unreported usage
/// (outbox) in memory and on disk, and reports it in batches.
class UsageQuotaRepoImpl implements UsageQuotaRepo {
  UsageQuotaRepoImpl(this._remote, this._local) : _outbox = _local.outbox;

  final UsageQuotaRemoteDatasrc _remote;
  final UsageQuotaLocalDatasrc _local;

  /// Largest single report. The server accepts up to 512 MB.
  static const _maxReportBytes = 256 * 1024 * 1024;

  /// Batches sent per flush; whatever is left waits for the next one.
  static const _maxBatchesPerFlush = 4;

  static const _uuid = Uuid();

  UsageOutbox _outbox;
  Future<UsageQuota?>? _flushing;

  @override
  UsageQuota cachedQuota() => _view();

  @override
  ResultFuture<UsageQuota> getQuota() => _guard(() async {
    // A report answers with a fresh snapshot, so only fetch if none was sent.
    final reported = await _flush();
    if (reported != null) return reported;
    final quota = await _remote.getQuota();
    await _local.saveSnapshot(quota);
    return _view(quota);
  });

  @override
  ResultFuture<UsageQuota> addUsage(int bytes) => _guard(() async {
    // Updated in memory before any await, so a flush that starts right
    // after this call already includes these bytes.
    _outbox = _outbox.add(bytes);
    await _local.saveOutbox(_outbox);
    return _view();
  });

  @override
  ResultFuture<UsageQuota> flushUsage() =>
      _guard(() async => await _flush() ?? _view());

  @override
  ResultFuture<UsageQuota> addRewardBonus() => _guard(() async {
    try {
      await _flush();
    } on Exception {
      // Best effort: the bonus doesn't depend on reported usage.
    }
    final quota = await _remote.grantTestBonus(_uuid.v4());
    await _local.saveSnapshot(quota);
    return _view(quota);
  });

  /// One flush at a time; callers during a flush share it. Returns the latest
  /// server snapshot, or null if there was nothing to send.
  Future<UsageQuota?> _flush() {
    return _flushing ??= _sendOutbox().whenComplete(() => _flushing = null);
  }

  Future<UsageQuota?> _sendOutbox() async {
    UsageQuotaModel? latest;
    for (var i = 0; i < _maxBatchesPerFlush; i++) {
      if (!_outbox.hasInFlight) {
        if (_outbox.pendingBytes <= 0) break;
        _outbox = _outbox.freeze(_uuid.v4(), _maxReportBytes);
        await _local.saveOutbox(_outbox); // persisted before it is sent
      }
      final quota = await _remote.report(
        reportId: _outbox.reportId!,
        bytes: _outbox.inFlightBytes,
      );
      _outbox = _outbox.acknowledged();
      await _local.saveOutbox(_outbox);
      await _local.saveSnapshot(quota);
      latest = quota;
    }
    return latest == null ? null : _view(latest);
  }

  UsageQuota _view([UsageQuota? snapshot]) {
    final base = snapshot ?? _local.snapshot ?? const UsageQuota.unknown();
    return base.withPending(_outbox.unreportedBytes);
  }

  Future<Either<Failure, UsageQuota>> _guard(
    Future<UsageQuota> Function() run,
  ) async {
    try {
      return Right(await run());
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }
}
