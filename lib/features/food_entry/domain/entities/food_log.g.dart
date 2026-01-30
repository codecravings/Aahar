// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'food_log.dart';

class FoodLogAdapter extends TypeAdapter<FoodLog> {
  @override
  final int typeId = 0;

  @override
  FoodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLog(
      id: fields[0] as String,
      name: fields[1] as String?,
      calories: fields[2] as int,
      protein: fields[3] as double,
      carbs: fields[4] as double,
      fat: fields[5] as double,
      timestamp: fields[6] as DateTime,
      source: fields[7] as FoodLogSource,
      imagePath: fields[8] as String?,
      aiConfidence: fields[9] as double?,
      notes: fields[10] as String?,
      mealType: fields[11] as MealType,
      description: fields[12] as String?,
      fiber: fields[13] as double?,
      sugar: fields[14] as double?,
      sodium: fields[15] as double?,
      vitaminD: fields[16] as double?,
      iron: fields[17] as double?,
      calcium: fields[18] as double?,
      emoji: fields[19] as String?,
      photoPath: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLog obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.fat)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.aiConfidence)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.mealType)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.fiber)
      ..writeByte(14)
      ..write(obj.sugar)
      ..writeByte(15)
      ..write(obj.sodium)
      ..writeByte(16)
      ..write(obj.vitaminD)
      ..writeByte(17)
      ..write(obj.iron)
      ..writeByte(18)
      ..write(obj.calcium)
      ..writeByte(19)
      ..write(obj.emoji)
      ..writeByte(20)
      ..write(obj.photoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodLogSourceAdapter extends TypeAdapter<FoodLogSource> {
  @override
  final int typeId = 1;

  @override
  FoodLogSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodLogSource.manual;
      case 1:
        return FoodLogSource.aiScan;
      case 2:
        return FoodLogSource.quickAdd;
      default:
        return FoodLogSource.manual;
    }
  }

  @override
  void write(BinaryWriter writer, FoodLogSource obj) {
    switch (obj) {
      case FoodLogSource.manual:
        writer.writeByte(0);
        break;
      case FoodLogSource.aiScan:
        writer.writeByte(1);
        break;
      case FoodLogSource.quickAdd:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 2;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      case 3:
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
      case MealType.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
