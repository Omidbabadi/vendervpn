import 'package:vendervpn/core/common/entities/config.dart';

class ConfigModel extends Config {
  const ConfigModel({
    required super.configjson,
    required super.importedFrom,
    required super.remark,
    required super.port,
    required super.address,
    required super.uri,
    required super.dateAdded,
    required super.id,
    required super.isSelected,
    super.country,
  });

  const ConfigModel.empty()
    : this(
        address: 'Test String',
        configjson: 'Test String',
        importedFrom: 'Test String',
        port: 0,
        remark: 'Test String',
        uri: 'Test String',
        dateAdded: 'Test String',
        id: 'Test String',
        isSelected: false,
        country: 'Test String',
      );

  ConfigModel copyWith({
    String? configjson,
    String? importedFrom,
    String? remark,
    int? port,
    String? address,
    String? uri,
    String? dateAdded,
    String? id,
    String? country,
    bool? isSelected,
  }) => ConfigModel(
    configjson: configjson ?? this.configjson,
    importedFrom: importedFrom ?? this.importedFrom,
    remark: remark ?? this.remark,
    port: port ?? this.port,
    address: address ?? this.address,
    uri: uri ?? this.uri,
    dateAdded: dateAdded ?? this.dateAdded,
    id: id ?? this.id,
    isSelected: isSelected ?? this.isSelected,
    country: country ?? this.country,
  );
}
