import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

import '../../../../core/common/entities/config.dart';
import '../../../../core/services/injection_container.dart';

abstract class ConfigsRemoteDatasrc {
  const ConfigsRemoteDatasrc();
  Future<List<Config>> getConfigs();
}

class ConfigsRemoteDatasrcImpl implements ConfigsRemoteDatasrc {
  const ConfigsRemoteDatasrcImpl(this._client);
  final Client _client;

  @override
  Future<List<Config>> getConfigs() async {
    final TablesDB tablesDB = TablesDB(_client);
    final List<Map<String, String>> cacheConfig = [];
    final List<ConfigModel> allConfigs = [];

    try {
      final response = await tablesDB.listRows(
        databaseId: '68cfc4e70012fb5e5417',
        tableId: 'url',
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

        final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
          links: extractedLinks,
          importedFrom: 'cloud',
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

      await sl<CacheHelper>().cacheConfigs(cacheConfig);
      return allConfigs.cast<Config>();
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('ConfigsRemoteDatasrcImpl error: $e');
      throw const ServerException(
        message: 'Getting Configs From Server Failed',
        statusCode: 500,
      );
    }
  }
}
