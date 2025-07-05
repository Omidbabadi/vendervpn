/*
class ConfigModel {
  final String configjson;
  final String importedFrom;
  final String remark;
  final int port;
  final String address;
  final String uri;
  final String dateAdded;
  final String id;

  ConfigModel({
    required this.configjson,
    required this.remark,
    required this.port,
    required this.address,
    required this.uri,
    required this.importedFrom,
    required this.id,
    required this.dateAdded,
  });

  factory ConfigModel.fropMap(Map<String, dynamic> map) {
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
}
*/

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

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
}
