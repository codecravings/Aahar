import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';

part 'user_settings.g.dart';

/// User preferences and settings
@HiveType(typeId: 6)
class UserSettings extends Equatable {
  @HiveField(0)
  final int calorieTarget;

  @HiveField(1)
  final int proteinTarget;

  @HiveField(2)
  final int carbsTarget;

  @HiveField(3)
  final int fatTarget;

  @HiveField(4)
  final String selectedModelId;

  @HiveField(5)
  final bool notificationsEnabled;

  @HiveField(6)
  final String? reminderTime;

  @HiveField(7)
  final AccentColor accentColor;

  @HiveField(8)
  final bool hapticFeedback;

  @HiveField(9)
  final bool showConfidence;

  @HiveField(10)
  final String? userName;

  const UserSettings({
    this.calorieTarget = AppConstants.defaultCalorieTarget,
    this.proteinTarget = AppConstants.defaultProteinTarget,
    this.carbsTarget = AppConstants.defaultCarbsTarget,
    this.fatTarget = AppConstants.defaultFatTarget,
    this.selectedModelId = 'gemini-2.0-flash',
    this.notificationsEnabled = true,
    this.reminderTime,
    this.accentColor = AccentColor.neonGreen,
    this.hapticFeedback = true,
    this.showConfidence = true,
    this.userName,
  });

  /// Get the selected Gemini model
  AIModel get selectedModel => AIModel.fromId(selectedModelId);

  UserSettings copyWith({
    int? calorieTarget,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    String? selectedModelId,
    bool? notificationsEnabled,
    String? reminderTime,
    AccentColor? accentColor,
    bool? hapticFeedback,
    bool? showConfidence,
    String? userName,
  }) {
    return UserSettings(
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      accentColor: accentColor ?? this.accentColor,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showConfidence: showConfidence ?? this.showConfidence,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
        calorieTarget,
        proteinTarget,
        carbsTarget,
        fatTarget,
        selectedModelId,
        notificationsEnabled,
        reminderTime,
        accentColor,
        hapticFeedback,
        showConfidence,
        userName,
      ];
}

@HiveType(typeId: 7)
enum AccentColor {
  @HiveField(0)
  neonGreen('Neon Green', 0xFF00FF88),

  @HiveField(1)
  neonPurple('Neon Purple', 0xFFB24BF3),

  @HiveField(2)
  neonBlue('Neon Blue', 0xFF00D4FF),

  @HiveField(3)
  neonOrange('Neon Orange', 0xFFFF6B35),

  @HiveField(4)
  neonPink('Neon Pink', 0xFFFF2E97);

  final String label;
  final int colorValue;

  const AccentColor(this.label, this.colorValue);
}
