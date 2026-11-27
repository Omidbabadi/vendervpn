import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/src/configs/data/datasrc/local_nodes_local_datasrc.dart';
import 'package:vendervpn/src/configs/data/datasrc/node_link_converter.dart';
import 'package:vendervpn/src/configs/data/datasrc/subscription_remote_datasrc.dart';
import 'package:vendervpn/src/configs/data/repo/local_nodes_repo_impl.dart';

/// Not used by the tests below; any call fails loudly.
class _UnusedLocal implements LocalNodesLocalDatasrc {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedConverter implements NodeLinkConverter {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemote implements SubscriptionRemoteDatasrc {
  Object? error;
  SubscriptionFetch fetch = (links: const <String>[], userInfo: null);

  @override
  Future<SubscriptionFetch> fetchSubscription(String url) async {
    final e = error;
    if (e != null) throw e;
    return fetch;
  }

  @override
  Future<SubscriptionUserInfo?> fetchUserInfo(String url) async {
    final e = error;
    if (e != null) throw e;
    return null;
  }
}

void main() {
  late _FakeRemote remote;
  late LocalNodesRepoImpl repo;

  setUp(() {
    remote = _FakeRemote();
    repo = LocalNodesRepoImpl(_UnusedLocal(), remote, _UnusedConverter());
  });

  test('fetchSubscription maps a ServerException to a ServerFailure', () async {
    remote.error = const ServerException(
      message: 'Subscription returned HTTP 403',
      statusCode: 403,
    );
    final result = await repo.fetchSubscription('https://x.test');
    final failure = result.fold((f) => f, (_) => null);
    expect(failure, isA<ServerFailure>());
    expect(failure!.message, 'Subscription returned HTTP 403');
    expect(failure.statusCode, 403);
  });

  test('fetchSubscription returns the fetched links', () async {
    remote.fetch = (links: const ['vless://a'], userInfo: null);
    final result = await repo.fetchSubscription('https://x.test');
    expect(result.fold((_) => null, (f) => f.links), ['vless://a']);
  });

  test('fetchSubscriptionInfo maps any error to a ServerFailure', () async {
    remote.error = StateError('boom');
    final result = await repo.fetchSubscriptionInfo('https://x.test');
    final failure = result.fold((f) => f, (_) => null);
    expect(failure, isA<ServerFailure>());
    expect(failure!.statusCode, 500);
  });

  test('extractLinks delegates to the pure link parser', () {
    expect(repo.extractLinks('vless://a\nnoise\nss://b'), [
      'vless://a',
      'ss://b',
    ]);
  });
}
