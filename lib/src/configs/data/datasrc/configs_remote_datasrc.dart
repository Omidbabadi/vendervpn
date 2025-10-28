import 'package:appwrite/appwrite.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
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
    final id = sl<CacheHelper>().id;
    final List<Map<String, String>> cacheConfig = [];
    try {
      final url = await tablesDB.listRows(
        databaseId: '68cfc4e70012fb5e5417',
        tableId: 'url',
      );
      if (url.rows.isEmpty) {
        throw ServerException(message: 'No Configs Found', statusCode: 404);
      }
      final data =
          (url.rows).map((e) {
            final config = e.data['url'] as String;
            final V2RayURL parser = FlutterV2ray.parseFromURL(config);
            final fullJson = parser.getFullConfiguration();

            final configModel = ConfigModel(
              configjson: fullJson,
              importedFrom: 's',
              remark: parser.remark,
              port: parser.port,
              address: parser.address,
              uri: parser.url,
              dateAdded: DateTime.now().toString(),
              id: e.$id,
              country: e.data['country'] as String,
              isSelected: id == e.$id,
            );
            final configs = configModel.toMap(configModel);
            cacheConfig.add(configs);
            return configModel;
          }).toList();

      sl<CacheHelper>().cacheConfigs(cacheConfig);
      return data.cast<Config>();
    } on ServerException {
      rethrow;
    } catch (e) {
      print(e);
      throw ServerException(
        message: 'Getting Configs From Server Failed',
        statusCode: 500,
      );
    }
  }
}
