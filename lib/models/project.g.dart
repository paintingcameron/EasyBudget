// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      fields[0] as String,
      fields[1] as String,
      fields[2] as double,
    )
      .._allocated = fields[3] as double
      .._bought = fields[4] as bool
      .._date_created = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._desc)
      ..writeByte(2)
      ..write(obj._goal)
      ..writeByte(3)
      ..write(obj._allocated)
      ..writeByte(4)
      ..write(obj._bought)
      ..writeByte(5)
      ..write(obj._date_created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
