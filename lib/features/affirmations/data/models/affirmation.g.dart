// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'affirmation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AffirmationAdapter extends TypeAdapter<Affirmation> {
  @override
  final int typeId = 0;

  @override
  Affirmation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Affirmation(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      displayCount: fields[4] as int,
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Affirmation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.displayCount)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AffirmationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
