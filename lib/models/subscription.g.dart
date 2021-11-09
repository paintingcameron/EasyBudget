// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 2;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      fields[0] as String,
      fields[1] as String,
      fields[2] as double,
      fields[3] as int,
      fields[4] as String,
      fields[5] as DateTime,
      fields[6] as DateTime,
      fields[7] as bool,
      fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._desc)
      ..writeByte(2)
      ..write(obj._amount)
      ..writeByte(3)
      ..write(obj._period)
      ..writeByte(4)
      ..write(obj._type)
      ..writeByte(5)
      ..write(obj._startDate)
      ..writeByte(6)
      ..write(obj._lastPaid)
      ..writeByte(7)
      ..write(obj._paused)
      ..writeByte(8)
      ..write(obj._initPay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
