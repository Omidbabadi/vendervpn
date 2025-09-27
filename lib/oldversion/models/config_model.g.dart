// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigModelAdapter extends TypeAdapter<ConfigModel> {
  @override
  final int typeId = 0;

  @override
  ConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigModel(
      id: fields[7] as String?,
      configjson: fields[0] as String,
      importedFrom: fields[1] as String,
      remark: fields[2] as String,
      port: fields[3] as int,
      address: fields[4] as String,
      uri: fields[5] as String,
      dateAdded: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConfigModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.configjson)
      ..writeByte(1)
      ..write(obj.importedFrom)
      ..writeByte(2)
      ..write(obj.remark)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.uri)
      ..writeByte(6)
      ..write(obj.dateAdded)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
