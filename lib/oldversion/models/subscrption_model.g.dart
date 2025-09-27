// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscrption_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscrptionModelAdapter extends TypeAdapter<SubscrptionModel> {
  @override
  final int typeId = 2;

  @override
  SubscrptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscrptionModel(
      id: fields[2] as String?,
      attachedConfigs: (fields[1] as List?)?.cast<ConfigModel>(),
      subURL: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubscrptionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.subURL)
      ..writeByte(1)
      ..write(obj.attachedConfigs)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscrptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
