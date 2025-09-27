
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/common/entities/config.dart';

part 'config_model.g.dart';

@HiveType(typeId: 0)
class ConfigModel extends HiveObject {
  @HiveField(0)
  final String configjson;

  @HiveField(1)
  final String importedFrom;

  @HiveField(2)
  final String remark;

  @HiveField(3)
  final int port;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final String uri;

  @HiveField(6)
  final String dateAdded;

  @HiveField(7)
  final String id;

  ConfigModel({
    String? id,
    required this.configjson,
    required this.importedFrom,
    required this.remark,
    required this.port,
    required this.address,
    required this.uri,
    required this.dateAdded,
  }) : id = id ?? const Uuid().v4();

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      configjson: map['configJson'],
      remark: map['remark'],
      port: map['port'],
      address: map['address'],
      uri: map['uri'],
      importedFrom: map['importedFrom'],
      id: map['id'],
      dateAdded: map['dateAdded'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'configjson': configjson,
      'remark': remark,
      'port': port,
      'address': address,
      'uri': 'uri',
      'importedFrom': importedFrom,
      'id': id,
      'dateAdded': dateAdded,
    };
  }

  factory ConfigModel.fromEntity(Config entity) {
    return ConfigModel(
      address: entity.address,
      configjson: entity.configjson,
      dateAdded: entity.dateAdded,
      id: entity.id,
      importedFrom: entity.importedFrom,
      port: entity.port,
      remark: entity.remark,
      uri: entity.uri,
    );
  }

  Config toEntity() {
    return Config(
      address: address,
      configjson: configjson,
      dateAdded: dateAdded,
      id: id,
      importedFrom: importedFrom,
      port: port,
      remark: remark,
      uri: uri,
    );
  }
}
