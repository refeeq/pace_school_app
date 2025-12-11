// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'students_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentModelAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 2;

  @override
  StudentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentModel(
      studcode: fields[0] as String,
      fullname: fields[1] as String,
      datumClass: fields[2] as String,
      section: fields[3] as String,
      studStat: fields[4] as String,
      acdyear: fields[5] as String,
      acYearId: fields[6] as String,
      photo: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.studcode)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.datumClass)
      ..writeByte(3)
      ..write(obj.section)
      ..writeByte(4)
      ..write(obj.studStat)
      ..writeByte(5)
      ..write(obj.acdyear)
      ..writeByte(6)
      ..write(obj.acYearId)
      ..writeByte(7)
      ..write(obj.photo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
