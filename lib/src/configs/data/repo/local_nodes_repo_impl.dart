import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/configs/data/datasrc/local_nodes_local_datasrc.dart';
import 'package:vendervpn/src/configs/data/datasrc/node_link_converter.dart';
import 'package:vendervpn/src/configs/data/datasrc/subscription_remote_datasrc.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

class LocalNodesRepoImpl implements LocalNodesRepo {
  const LocalNodesRepoImpl(this._local, this._remote, this._converter);
  final LocalNodesLocalDatasrc _local;
  final SubscriptionRemoteDatasrc _remote;
  final NodeLinkConverter _converter;

  @override
  List<Config> cachedNodes() => _local.loadNodes();

  @override
  ResultFuture<void> saveNodes(List<Config> nodes) async {
    try {
      await _local.saveNodes(nodes);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }

  @override
  List<SubscriptionItem> cachedSubscriptions() => _local.loadSubscriptions();

  @override
  ResultFuture<void> saveSubscriptions(
    List<SubscriptionItem> subscriptions,
  ) async {
    try {
      await _local.saveSubscriptions(subscriptions);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }

  @override
  ResultFuture<SubscriptionFetch> fetchSubscription(String url) async {
    try {
      return Right(await _remote.fetchSubscription(url));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<SubscriptionUserInfo?> fetchSubscriptionInfo(String url) async {
    try {
      return Right(await _remote.fetchUserInfo(url));
    } catch (e) {
      return Left(ServerFailure(message: '$e', statusCode: 500));
    }
  }

  @override
  List<String> extractLinks(String rawPayload) =>
      V2rayImportHelper.extractLinksFromPayload(rawPayload);

  @override
  ResultFuture<List<Config>> parseLinks({
    required List<String> links,
    required String importedFrom,
    String? idScope,
  }) async {
    try {
      return Right(
        await _converter.parseLinksToConfigs(
          links: links,
          importedFrom: importedFrom,
          idScope: idScope,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Reading the node links failed: $e'));
    }
  }
}
