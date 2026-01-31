// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_quick_add.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomQuickAddAdapter extends TypeAdapter<CustomQuickAdd> {
  @override
  final int typeId = 8;

  @override
  CustomQuickAdd read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomQuickAdd(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      calories: fields[3] as int,
      protein: fields[4] as double,
      carbs: fields[5] as double,
      fat: fields[6] as double,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomQuickAdd obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.fat)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomQuickAddAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
