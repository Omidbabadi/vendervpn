import 'package:dartz/dartz.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/config_editor/data/datasrc/config_editor_local_datasrc.dart';
import 'package:vendervpn/src/config_editor/data/models/share_link_codec.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/repo/config_editor_repo.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

class ConfigEditorRepoImpl implements ConfigEditorRepo {
  const ConfigEditorRepoImpl(this._datasrc);
  final ConfigEditorLocalDatasrc _datasrc;

  @override
  ResultFuture<EditableNode> loadNode(Config config) async {
    try {
      return Right(ShareLinkCodec.decode(config.uri));
    } on ConfigEditException catch (e) {
      return Left(ConfigEditFailure.fromException(e));
    }
  }

  @override
  ResultFuture<String> buildShareLink(EditableNode node) async {
    try {
      return Right(ShareLinkCodec.encode(node));
    } catch (e) {
      return Left(ConfigEditFailure(message: 'Could not build the link: $e'));
    }
  }

  @override
  ResultFuture<Config> saveNode({
    required Config original,
    required EditableNode node,
  }) async {
    try {
      final link = ShareLinkCodec.encode(node);
      // Parse the new link exactly like the node list does on start-up, so a
      // link that saves is a link that loads and connects.
      final parser = V2ray.parseFromURL(link);
      final configJson = V2rayImportHelper.buildFullConfigurationWithHttpInbound(
        parser,
      );

      final address = parser.address.trim();
      final linkChanged = link != original.uri;
      final sameServer = address == original.address.trim();
      final remark =
          parser.remark.trim().isNotEmpty
              ? parser.remark.trim()
              : '${V2rayImportHelper.protocolOf(link)} ($address)';
      final verified = sameServer ? _datasrc.verifiedCountry(original.uri) : null;

      final updated = ConfigModel(
        configjson: configJson,
        importedFrom: original.importedFrom,
        remark: remark,
        port: parser.port,
        address: address,
        uri: link,
        dateAdded: original.dateAdded,
        id: original.id,
        isSelected: original.isSelected,
        country: verified ?? V2rayImportHelper.countryFromRemarkFlag(remark),
        serverIp: sameServer ? original.serverIp : null,
        ping: linkChanged ? -1 : original.ping,
      );

      await _datasrc.saveLocalNode(updated);
      // Verified countries are keyed by link: keep it when only the
      // settings changed, not the server.
      if (verified != null && linkChanged) {
        await _datasrc.cacheVerifiedCountry(link, verified);
      }
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } on ConfigEditException catch (e) {
      return Left(ConfigEditFailure.fromException(e));
    } catch (e) {
      return Left(
        ConfigEditFailure(message: "These settings don't make a valid node: $e"),
      );
    }
  }
}
