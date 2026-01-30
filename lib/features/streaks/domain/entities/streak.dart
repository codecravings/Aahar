import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'streak.g.dart';

/// User streak and XP data
@HiveType(typeId: 3)
class UserStreak extends Equatable {
  @HiveField(0)
  final int currentStreak;

  @HiveField(1)
  final int longestStreak;

  @HiveField(2)
  final DateTime? lastLogDate;

  @HiveField(3)
  final int totalXp;

  @HiveField(4)
  final int totalLogs;

  @HiveField(5)
  final int perfectDays;

  @HiveField(6)
  final List<DateTime> logDates;

  const UserStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLogDate,
    this.totalXp = 0,
    this.totalLogs = 0,
    this.perfectDays = 0,
    this.logDates = const [],
  });

  /// Current level based on XP
  int get level => (totalXp / 500).floor() + 1;

  /// XP progress within current level
  double get levelProgress => (totalXp % 500) / 500;

  /// XP needed for next level
  int get xpToNextLevel => 500 - (totalXp % 500);

  /// Check if streak is active (logged today or yesterday)
  bool get isStreakActive {
    if (lastLogDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLog = DateTime(lastLogDate!.year, lastLogDate!.month, lastLogDate!.day);
    final difference = today.difference(lastLog).inDays;
    return difference <= 1;
  }

  /// Check if logged today
  bool get loggedToday {
    if (lastLogDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLog = DateTime(lastLogDate!.year, lastLogDate!.month, lastLogDate!.day);
    return today.isAtSameMomentAs(lastLog);
  }

  /// Get heatmap data for last N days
  Map<DateTime, int> getHeatmapData(int days) {
    final now = DateTime.now();
    final map = <DateTime, int>{};

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      map[date] = 0;
    }

    for (final logDate in logDates) {
      final normalizedDate = DateTime(logDate.year, logDate.month, logDate.day);
      if (map.containsKey(normalizedDate)) {
        map[normalizedDate] = (map[normalizedDate] ?? 0) + 1;
      }
    }

    return map;
  }

  UserStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLogDate,
    int? totalXp,
    int? totalLogs,
    int? perfectDays,
    List<DateTime>? logDates,
  }) {
    return UserStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      totalXp: totalXp ?? this.totalXp,
      totalLogs: totalLogs ?? this.totalLogs,
      perfectDays: perfectDays ?? this.perfectDays,
      logDates: logDates ?? this.logDates,
    );
  }

  /// Record a new log
  UserStreak recordLog({required bool isPerfectDay, required int xpEarned}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already logged today
    if (loggedToday) {
      return copyWith(
        totalXp: totalXp + xpEarned,
        perfectDays: isPerfectDay ? perfectDays + 1 : perfectDays,
      );
    }

    // Calculate new streak
    int newStreak;
    if (lastLogDate == null) {
      newStreak = 1;
    } else {
      final lastLog = DateTime(lastLogDate!.year, lastLogDate!.month, lastLogDate!.day);
      final difference = today.difference(lastLog).inDays;
      if (difference == 1) {
        newStreak = currentStreak + 1;
      } else if (difference == 0) {
        newStreak = currentStreak;
      } else {
        newStreak = 1; // Streak broken
      }
    }

    final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

    return copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastLogDate: now,
      totalXp: totalXp + xpEarned + (newStreak * 5), // Streak bonus
      totalLogs: totalLogs + 1,
      perfectDays: isPerfectDay ? perfectDays + 1 : perfectDays,
      logDates: [...logDates, now],
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastLogDate,
        totalXp,
        totalLogs,
        perfectDays,
        logDates,
      ];
}

/// Achievement definition
@HiveType(typeId: 4)
class Achievement extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final int xpReward;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final DateTime? unlockedAt;

  @HiveField(7)
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.category,
  });

  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      xpReward: xpReward,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      category: category,
    );
  }

  @override
  List<Object?> get props => [id, title, description, emoji, xpReward, isUnlocked, unlockedAt, category];
}

@HiveType(typeId: 5)
enum AchievementCategory {
  @HiveField(0)
  streak,

  @HiveField(1)
  logging,

  @HiveField(2)
  nutrition,

  @HiveField(3)
  milestone,
}

/// Predefined achievements
class Achievements {
  static const List<Achievement> all = [
    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Hat-trick',
      description: '3 day logging streak',
      emoji: '🎯',
      xpReward: 50,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: '7 day logging streak',
      emoji: '🗓️',
      xpReward: 100,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Monster',
      description: '30 day logging streak',
      emoji: '🔥',
      xpReward: 500,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Centurion',
      description: '100 day logging streak',
      emoji: '👑',
      xpReward: 1000,
      category: AchievementCategory.streak,
    ),

    // Logging achievements
    Achievement(
      id: 'first_log',
      title: 'First Step',
      description: 'Log your first meal',
      emoji: '🚀',
      xpReward: 25,
      category: AchievementCategory.logging,
    ),
    Achievement(
      id: 'logs_50',
      title: 'Dedicated',
      description: 'Log 50 meals',
      emoji: '📝',
      xpReward: 100,
      category: AchievementCategory.logging,
    ),
    Achievement(
      id: 'logs_500',
      title: 'Obsessed',
      description: 'Log 500 meals',
      emoji: '🏆',
      xpReward: 500,
      category: AchievementCategory.logging,
    ),
    Achievement(
      id: 'ai_scan_first',
      title: 'AI Explorer',
      description: 'Use AI scan for the first time',
      emoji: '🤖',
      xpReward: 50,
      category: AchievementCategory.logging,
    ),

    // Nutrition achievements
    Achievement(
      id: 'perfect_day_first',
      title: 'Perfect Day',
      description: 'Hit all your macro targets',
      emoji: '⭐',
      xpReward: 100,
      category: AchievementCategory.nutrition,
    ),
    Achievement(
      id: 'perfect_week',
      title: 'Perfect Week',
      description: '7 perfect days in a row',
      emoji: '💫',
      xpReward: 500,
      category: AchievementCategory.nutrition,
    ),
    Achievement(
      id: 'protein_king',
      title: 'Protein King',
      description: 'Hit protein goal 30 days',
      emoji: '💪',
      xpReward: 300,
      category: AchievementCategory.nutrition,
    ),

    // Milestone achievements
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach level 5',
      emoji: '⬆️',
      xpReward: 100,
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'level_10',
      title: 'Veteran',
      description: 'Reach level 10',
      emoji: '🎖️',
      xpReward: 250,
      category: AchievementCategory.milestone,
    ),
    Achievement(
      id: 'level_25',
      title: 'Legend',
      description: 'Reach level 25',
      emoji: '🏅',
      xpReward: 500,
      category: AchievementCategory.milestone,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
