import 'package:appwrite/appwrite.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/configs/data/datasrc/node_link_converter.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

abstract class ConfigsRemoteDatasrc {
  const ConfigsRemoteDatasrc();
  Future<List<Config>> getConfigs();

  /// Cloud nodes saved by the last successful [getConfigs].
  Future<List<Config>> getCachedConfigs();
}

class ConfigsRemoteDatasrcImpl implements ConfigsRemoteDatasrc {
  const ConfigsRemoteDatasrcImpl(this._client, this._cache, this._converter);
  final Client _client;
  final CacheHelper _cache;
  final NodeLinkConverter _converter;

  @override
  Future<List<Config>> getCachedConfigs() async {
    final selectedId = _cache.id;
    final nodeCountries = _cache.nodeCountryMap;
    final configs = <Config>[];
    for (final e in _cache.configs) {
      try {
        configs.add(
          NodeLinkConverter.configFromCacheMap(
            e,
            selectedId: selectedId,
            nodeCountries: nodeCountries,
            defaultImportedFrom: NodeSource.cloudTag,
            defaultDateAdded: '',
          ),
        );
      } catch (err) {
        appLog('Skipping corrupt cached cloud config: $err');
      }
    }
    return configs;
  }

  @override
  Future<List<Config>> getConfigs() async {
    final TablesDB tablesDB = TablesDB(_client);
    final List<Map<String, String>> cacheConfig = [];
    final List<ConfigModel> allConfigs = [];

    try {
      final response = await tablesDB.listRows(
        databaseId: '6b071b2200201ca27bcb',
        tableId: '6b071b3e001bb7849d16',
      );
      if (response.rows.isEmpty) {
        throw const ServerException(
          message: 'No Configs Found',
          statusCode: 404,
        );
      }

      for (final row in response.rows) {
        final rawData = row.data;
        final dynamic rawLinksField =
            rawData['v2raylinks'] ??
            rawData['v2rayLinks'] ??
            rawData['v2ray_links'] ??
            rawData['url'];

        final List<String> extractedLinks = [];
        if (rawLinksField is List) {
          for (final item in rawLinksField) {
            if (item != null) {
              extractedLinks.addAll(
                V2rayImportHelper.extractLinksFromPayload(item.toString()),
              );
            }
          }
        } else if (rawLinksField != null) {
          extractedLinks.addAll(
            V2rayImportHelper.extractLinksFromPayload(rawLinksField.toString()),
          );
        }

        final createdAt =
            (rawData['createdAt'] ??
                    rawData['created_at'] ??
                    rawData['\$createdAt'] ??
                    row.$createdAt)
                .toString();

        final parsedModels = await _converter.parseLinksToConfigs(
          links: extractedLinks,
          importedFrom: NodeSource.cloudTag,
          forcedIdPrefix: row.$id,
          createdAt: createdAt,
        );

        for (final model in parsedModels) {
          cacheConfig.add(model.toMap(model));
          allConfigs.add(model);
        }
      }

      if (allConfigs.isEmpty) {
        throw const ServerException(
          message: 'No valid V2Ray links found in server response',
          statusCode: 404,
        );
      }

      await _cache.cacheConfigs(cacheConfig);
      return allConfigs.cast<Config>();
    } on ServerException {
      rethrow;
    } catch (e) {
      appLog('ConfigsRemoteDatasrcImpl error: $e');
      throw const ServerException(
        message: 'Getting Configs From Server Failed',
        statusCode: 500,
      );
    }
  }
}
