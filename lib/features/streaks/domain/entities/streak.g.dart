// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStreakAdapter extends TypeAdapter<UserStreak> {
  @override
  final int typeId = 3;

  @override
  UserStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStreak(
      currentStreak: fields[0] as int,
      longestStreak: fields[1] as int,
      lastLogDate: fields[2] as DateTime?,
      totalXp: fields[3] as int,
      totalLogs: fields[4] as int,
      perfectDays: fields[5] as int,
      logDates: (fields[6] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStreak obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.longestStreak)
      ..writeByte(2)
      ..write(obj.lastLogDate)
      ..writeByte(3)
      ..write(obj.totalXp)
      ..writeByte(4)
      ..write(obj.totalLogs)
      ..writeByte(5)
      ..write(obj.perfectDays)
      ..writeByte(6)
      ..write(obj.logDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 4;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      emoji: fields[3] as String,
      xpReward: fields[4] as int,
      isUnlocked: fields[5] as bool,
      unlockedAt: fields[6] as DateTime?,
      category: fields[7] as AchievementCategory,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.xpReward)
      ..writeByte(5)
      ..write(obj.isUnlocked)
      ..writeByte(6)
      ..write(obj.unlockedAt)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementCategoryAdapter extends TypeAdapter<AchievementCategory> {
  @override
  final int typeId = 5;

  @override
  AchievementCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementCategory.streak;
      case 1:
        return AchievementCategory.logging;
      case 2:
        return AchievementCategory.nutrition;
      case 3:
        return AchievementCategory.milestone;
      default:
        return AchievementCategory.streak;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementCategory obj) {
    switch (obj) {
      case AchievementCategory.streak:
        writer.writeByte(0);
        break;
      case AchievementCategory.logging:
        writer.writeByte(1);
        break;
      case AchievementCategory.nutrition:
        writer.writeByte(2);
        break;
      case AchievementCategory.milestone:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
