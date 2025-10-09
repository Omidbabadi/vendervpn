import 'package:appwrite/appwrite.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

import '../../../../core/common/entities/config.dart';

abstract class ConfigsRemoteDatasrc {
  Future<List<Config>> getConfigs();
}

class ConfigsRemoteDatasrcImpl implements ConfigsRemoteDatasrc {
  const ConfigsRemoteDatasrcImpl(this._client);
  final Client _client;
  @override
  Future<List<Config>> getConfigs() async {
    final TablesDB tablesDB = TablesDB(_client);
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
            final V2RayURL parser = V2ray.parseFromURL(config);
            final fullJson = parser.getFullConfiguration();
            return ConfigModel(
              configjson: fullJson,
              importedFrom: 's',
              remark: parser.remark,
              port: parser.port,
              address: parser.address,
              uri: parser.url,
              dateAdded: DateTime.now().toString(),
              id: 'id',
            );
          }).toList();
      print(data[0].configjson);
      return data;
    } catch (e) {
      throw ServerException(
        message: 'Getting Configs From Server Failed',
        statusCode: 500,
      );
    }
  }
}
