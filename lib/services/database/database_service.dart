import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../features/food_entry/domain/entities/food_log.dart';
import '../../features/settings/domain/entities/user_settings.dart';
import '../../features/streaks/domain/entities/streak.dart';

/// Service for local database operations using Hive
class DatabaseService {
  static bool _initialized = false;

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FoodLogAdapter());
    Hive.registerAdapter(FoodLogSourceAdapter());
    Hive.registerAdapter(MealTypeAdapter());
    Hive.registerAdapter(UserStreakAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(AchievementCategoryAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(AccentColorAdapter());

    // Open boxes
    await Hive.openBox<FoodLog>(AppConstants.foodLogsBox);
    await Hive.openBox<UserSettings>(AppConstants.settingsBox);
    await Hive.openBox<UserStreak>(AppConstants.streaksBox);
    await Hive.openBox<Achievement>(AppConstants.achievementsBox);

    _initialized = true;
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}

/// Repository for food log operations
class FoodLogRepository {
  Box<FoodLog> get _box => Hive.box<FoodLog>(AppConstants.foodLogsBox);

  /// Add a new food log
  Future<void> addFoodLog(FoodLog log) async {
    await _box.put(log.id, log);
  }

  /// Get a food log by ID
  FoodLog? getFoodLog(String id) {
    return _box.get(id);
  }

  /// Update an existing food log
  Future<void> updateFoodLog(FoodLog log) async {
    await _box.put(log.id, log);
  }

  /// Delete a food log
  Future<void> deleteFoodLog(String id) async {
    await _box.delete(id);
  }

  /// Get all food logs
  List<FoodLog> getAllFoodLogs() {
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get food logs for a specific date
  List<FoodLog> getFoodLogsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _box.values
        .where((log) =>
            log.timestamp.isAfter(startOfDay) &&
            log.timestamp.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get food logs for a date range
  List<FoodLog> getFoodLogsForDateRange(DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));

    return _box.values
        .where((log) =>
            log.timestamp.isAfter(startOfDay) &&
            log.timestamp.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get total macros for a specific date
  Map<String, num> getMacrosForDate(DateTime date) {
    final logs = getFoodLogsForDate(date);

    return {
      'calories': logs.fold<int>(0, (sum, log) => sum + log.calories),
      'protein': logs.fold<double>(0, (sum, log) => sum + log.protein),
      'carbs': logs.fold<double>(0, (sum, log) => sum + log.carbs),
      'fat': logs.fold<double>(0, (sum, log) => sum + log.fat),
    };
  }

  /// Get logs grouped by date
  Map<DateTime, List<FoodLog>> getLogsGroupedByDate(int days) {
    final now = DateTime.now();
    final result = <DateTime, List<FoodLog>>{};

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      result[date] = getFoodLogsForDate(date);
    }

    return result;
  }

  /// Get count of logs
  int get logCount => _box.length;

  /// Clear all logs
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Watch for changes
  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}

/// Repository for user settings
class SettingsRepository {
  Box<UserSettings> get _box => Hive.box<UserSettings>(AppConstants.settingsBox);

  static const String _settingsKey = 'user_settings';

  /// Get current settings
  UserSettings getSettings() {
    return _box.get(_settingsKey) ?? const UserSettings();
  }

  /// Save settings
  Future<void> saveSettings(UserSettings settings) async {
    await _box.put(_settingsKey, settings);
  }

  /// Update specific setting
  Future<UserSettings> updateSettings({
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
  }) async {
    final current = getSettings();
    final updated = current.copyWith(
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      carbsTarget: carbsTarget,
      fatTarget: fatTarget,
      selectedModelId: selectedModelId,
      notificationsEnabled: notificationsEnabled,
      reminderTime: reminderTime,
      accentColor: accentColor,
      hapticFeedback: hapticFeedback,
      showConfidence: showConfidence,
      userName: userName,
    );
    await saveSettings(updated);
    return updated;
  }

  /// Watch for changes
  Stream<BoxEvent> watch() {
    return _box.watch(key: _settingsKey);
  }
}

/// Repository for streak and XP data
class StreakRepository {
  Box<UserStreak> get _box => Hive.box<UserStreak>(AppConstants.streaksBox);

  static const String _streakKey = 'user_streak';

  /// Get current streak data
  UserStreak getStreak() {
    return _box.get(_streakKey) ?? const UserStreak();
  }

  /// Save streak data
  Future<void> saveStreak(UserStreak streak) async {
    await _box.put(_streakKey, streak);
  }

  /// Record a new food log
  Future<UserStreak> recordLog({required bool isPerfectDay, required int xpEarned}) async {
    final current = getStreak();
    final updated = current.recordLog(isPerfectDay: isPerfectDay, xpEarned: xpEarned);
    await saveStreak(updated);
    return updated;
  }

  /// Add XP
  Future<UserStreak> addXp(int amount) async {
    final current = getStreak();
    final updated = current.copyWith(totalXp: current.totalXp + amount);
    await saveStreak(updated);
    return updated;
  }

  /// Watch for changes
  Stream<BoxEvent> watch() {
    return _box.watch(key: _streakKey);
  }
}

/// Repository for achievements
class AchievementRepository {
  Box<Achievement> get _box => Hive.box<Achievement>(AppConstants.achievementsBox);

  /// Initialize achievements if not exists
  Future<void> initializeAchievements() async {
    if (_box.isEmpty) {
      for (final achievement in Achievements.all) {
        await _box.put(achievement.id, achievement);
      }
    }
  }

  /// Get all achievements
  List<Achievement> getAllAchievements() {
    return _box.values.toList();
  }

  /// Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return _box.values.where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<Achievement> getLockedAchievements() {
    return _box.values.where((a) => !a.isUnlocked).toList();
  }

  /// Unlock an achievement
  Future<Achievement?> unlockAchievement(String id) async {
    final achievement = _box.get(id);
    if (achievement == null || achievement.isUnlocked) return null;

    final unlocked = achievement.unlock();
    await _box.put(id, unlocked);
    return unlocked;
  }

  /// Check achievement by ID
  Achievement? getAchievement(String id) {
    return _box.get(id);
  }

  /// Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _box.values.where((a) => a.category == category).toList();
  }
}
