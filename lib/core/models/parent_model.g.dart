// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParentModelAdapter extends TypeAdapter<ParentModel> {
  @override
  final int typeId = 3;

  @override
  ParentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParentModel(
      name: fields[0] as String,
      famcode: fields[1] as String,
      mobile: fields[2] as String,
      email: fields[3] as String,
      relation: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ParentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.famcode)
      ..writeByte(2)
      ..write(obj.mobile)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.relation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
