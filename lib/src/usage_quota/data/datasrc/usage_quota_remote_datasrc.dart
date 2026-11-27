import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' show ExecutionMethod;
import 'package:appwrite/models.dart' as models;
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/services/device_identity.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';

/// The `quota` Appwrite function. The app only ever sends usage deltas and
/// IDs; the server decides the day, the limits and the totals.
abstract class UsageQuotaRemoteDatasrc {
  const UsageQuotaRemoteDatasrc();

  Future<UsageQuotaModel> getQuota();

  /// Adds [bytes] to today's usage. Retrying with the same [reportId] is
  /// safe: the server counts each report once.
  Future<UsageQuotaModel> report({
    required String reportId,
    required int bytes,
  });

  /// TEMPORARY test grant of the rewarded-ad bonus (no ad verification).
  Future<UsageQuotaModel> grantTestBonus(String grantId);
}

/// Signs in anonymously and binds the session to this device on first use.
/// The quota belongs to the device, so a reinstall (new anonymous user)
/// still sees the same quota.
class UsageQuotaRemoteDatasrcImpl implements UsageQuotaRemoteDatasrc {
  UsageQuotaRemoteDatasrcImpl(Client client, this._device, this._cache)
    : _account = Account(client),
      _functions = Functions(client);

  static const _functionId = 'quota';
  static const _timeout = Duration(seconds: 15);
  static const _jsonHeaders = {'content-type': 'application/json'};

  final Account _account;
  final Functions _functions;
  final DeviceIdentity _device;
  final CacheHelper _cache;

  Future<void>? _ready;

  @override
  Future<UsageQuotaModel> getQuota() =>
      _quotaCall(ExecutionMethod.gET, '/quota');

  @override
  Future<UsageQuotaModel> report({
    required String reportId,
    required int bytes,
  }) {
    return _quotaCall(ExecutionMethod.pOST, '/report', {
      'reportId': reportId,
      'bytes': bytes,
    });
  }

  @override
  Future<UsageQuotaModel> grantTestBonus(String grantId) {
    return _quotaCall(ExecutionMethod.pOST, '/bonus', {'grantId': grantId});
  }

  Future<UsageQuotaModel> _quotaCall(
    ExecutionMethod method,
    String path, [
    DataMap? body,
  ]) async {
    final json = await _call(method, path, body);
    try {
      return UsageQuotaModel.fromServer(json, receivedAt: DateTime.now());
    } catch (_) {
      throw const ServerException(message: 'bad_response', statusCode: 502);
    }
  }

  Future<DataMap> _call(
    ExecutionMethod method,
    String path,
    DataMap? body,
  ) async {
    for (var attempt = 0; ; attempt++) {
      final canRetry = attempt == 0;
      try {
        await _ensureReady();
        final execution = await _execute(method, path, body);
        final status = execution.responseStatusCode;
        final decoded = _decode(execution.responseBody);
        if (status >= 200 && status < 300) return decoded;
        if (status == 412 && canRetry) {
          // The server lost our binding: bind again, then retry once.
          await _forgetSession();
          continue;
        }
        throw ServerException(
          message: decoded['error']?.toString() ?? 'http_$status',
          statusCode: status,
        );
      } on ServerException {
        rethrow;
      } on AppwriteException catch (e) {
        if (e.code == 401 && canRetry) {
          // Session expired or was deleted: sign in again, then retry once.
          await _forgetSession();
          continue;
        }
        throw ServerException(
          message: e.message ?? e.type ?? 'appwrite_error',
          statusCode: e.code ?? 503,
        );
      } on TimeoutException {
        throw const ServerException(message: 'timeout', statusCode: 504);
      } on Exception catch (e) {
        throw ServerException(message: e.toString(), statusCode: 503);
      }
    }
  }

  Future<models.Execution> _execute(
    ExecutionMethod method,
    String path,
    DataMap? body,
  ) {
    return _functions
        .createExecution(
          functionId: _functionId,
          path: path,
          method: method,
          body: body == null ? null : jsonEncode(body),
          xasync: false,
          headers: _jsonHeaders,
        )
        .timeout(_timeout);
  }

  /// Session plus device binding, done once per app run (and again after a
  /// 401/412). Concurrent callers share one attempt.
  Future<void> _ensureReady() async {
    final ready = _ready ??= _prepare();
    try {
      await ready;
    } catch (_) {
      if (identical(_ready, ready)) _ready = null;
      rethrow;
    }
  }

  Future<void> _prepare({bool isRetry = false}) async {
    final userId = await _signIn();
    if (_cache.quotaBoundUserId == userId) return;

    final execution = await _execute(ExecutionMethod.pOST, '/bind', {
      'platform': _device.platform,
      'deviceId': await _device.deviceId(),
    });
    final status = execution.responseStatusCode;
    if (status == 409 && !isRetry) {
      // This anonymous user is bound to another device (e.g. app data was
      // restored from a backup): start a fresh anonymous user here.
      await _account.deleteSession(sessionId: 'current').timeout(_timeout);
      return _prepare(isRetry: true);
    }
    if (status != 200) {
      throw ServerException(
        message:
            _decode(execution.responseBody)['error']?.toString() ??
            'bind_failed',
        statusCode: status,
      );
    }
    await _cache.cacheQuotaBoundUserId(userId);
  }

  /// The current user's ID, creating an anonymous session if there is none.
  Future<String> _signIn() async {
    try {
      return (await _account.get().timeout(_timeout)).$id;
    } on AppwriteException catch (e) {
      if (e.code != 401) rethrow;
    }
    return (await _account.createAnonymousSession().timeout(_timeout)).userId;
  }

  Future<void> _forgetSession() async {
    _ready = null;
    await _cache.cacheQuotaBoundUserId(null);
  }

  static DataMap _decode(String body) {
    try {
      final value = jsonDecode(body);
      if (value is Map) return Map<String, dynamic>.from(value);
    } on FormatException {
      // Not JSON: treated as an empty body.
    }
    return const {};
  }
}
