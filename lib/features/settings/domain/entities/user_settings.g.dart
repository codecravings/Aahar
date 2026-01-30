// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'user_settings.dart';

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 6;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      calorieTarget: fields[0] as int,
      proteinTarget: fields[1] as int,
      carbsTarget: fields[2] as int,
      fatTarget: fields[3] as int,
      selectedModelId: fields[4] as String,
      notificationsEnabled: fields[5] as bool,
      reminderTime: fields[6] as String?,
      accentColor: fields[7] as AccentColor,
      hapticFeedback: fields[8] as bool,
      showConfidence: fields[9] as bool,
      userName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.calorieTarget)
      ..writeByte(1)
      ..write(obj.proteinTarget)
      ..writeByte(2)
      ..write(obj.carbsTarget)
      ..writeByte(3)
      ..write(obj.fatTarget)
      ..writeByte(4)
      ..write(obj.selectedModelId)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.reminderTime)
      ..writeByte(7)
      ..write(obj.accentColor)
      ..writeByte(8)
      ..write(obj.hapticFeedback)
      ..writeByte(9)
      ..write(obj.showConfidence)
      ..writeByte(10)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccentColorAdapter extends TypeAdapter<AccentColor> {
  @override
  final int typeId = 7;

  @override
  AccentColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccentColor.neonGreen;
      case 1:
        return AccentColor.neonPurple;
      case 2:
        return AccentColor.neonBlue;
      case 3:
        return AccentColor.neonOrange;
      case 4:
        return AccentColor.neonPink;
      default:
        return AccentColor.neonGreen;
    }
  }

  @override
  void write(BinaryWriter writer, AccentColor obj) {
    switch (obj) {
      case AccentColor.neonGreen:
        writer.writeByte(0);
        break;
      case AccentColor.neonPurple:
        writer.writeByte(1);
        break;
      case AccentColor.neonBlue:
        writer.writeByte(2);
        break;
      case AccentColor.neonOrange:
        writer.writeByte(3);
        break;
      case AccentColor.neonPink:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccentColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
