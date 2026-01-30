import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/database/database_service.dart';
import '../../domain/entities/streak.dart';

/// Provider for streak repository
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository();
});

/// Provider for achievement repository
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

/// Provider for user streak state
final streakProvider = StateNotifierProvider<StreakNotifier, UserStreak>((ref) {
  final repository = ref.watch(streakRepositoryProvider);
  final achievementRepository = ref.watch(achievementRepositoryProvider);
  return StreakNotifier(repository, achievementRepository);
});

/// Streak state notifier
class StreakNotifier extends StateNotifier<UserStreak> {
  final StreakRepository _repository;
  final AchievementRepository _achievementRepository;

  StreakNotifier(this._repository, this._achievementRepository)
      : super(const UserStreak()) {
    _loadStreak();
  }

  void _loadStreak() {
    state = _repository.getStreak();
  }

  /// Record a new food log
  Future<List<Achievement>> recordLog({required bool isPerfectDay}) async {
    final xpEarned = AppConstants.xpPerLog + (isPerfectDay ? AppConstants.xpPerPerfectDay : 0);
    state = await _repository.recordLog(isPerfectDay: isPerfectDay, xpEarned: xpEarned);

    // Check for unlocked achievements
    return _checkAchievements();
  }

  /// Check and unlock achievements
  Future<List<Achievement>> _checkAchievements() async {
    final unlocked = <Achievement>[];

    // Streak achievements
    if (state.currentStreak >= 3) {
      final achievement = await _achievementRepository.unlockAchievement('streak_3');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.currentStreak >= 7) {
      final achievement = await _achievementRepository.unlockAchievement('streak_7');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.currentStreak >= 30) {
      final achievement = await _achievementRepository.unlockAchievement('streak_30');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.currentStreak >= 100) {
      final achievement = await _achievementRepository.unlockAchievement('streak_100');
      if (achievement != null) unlocked.add(achievement);
    }

    // Logging achievements
    if (state.totalLogs >= 1) {
      final achievement = await _achievementRepository.unlockAchievement('first_log');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.totalLogs >= 50) {
      final achievement = await _achievementRepository.unlockAchievement('logs_50');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.totalLogs >= 500) {
      final achievement = await _achievementRepository.unlockAchievement('logs_500');
      if (achievement != null) unlocked.add(achievement);
    }

    // Level achievements
    if (state.level >= 5) {
      final achievement = await _achievementRepository.unlockAchievement('level_5');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.level >= 10) {
      final achievement = await _achievementRepository.unlockAchievement('level_10');
      if (achievement != null) unlocked.add(achievement);
    }
    if (state.level >= 25) {
      final achievement = await _achievementRepository.unlockAchievement('level_25');
      if (achievement != null) unlocked.add(achievement);
    }

    // Perfect day achievements
    if (state.perfectDays >= 1) {
      final achievement = await _achievementRepository.unlockAchievement('perfect_day_first');
      if (achievement != null) unlocked.add(achievement);
    }

    // Add XP from unlocked achievements
    for (final achievement in unlocked) {
      await _repository.addXp(achievement.xpReward);
    }

    // Reload state to get updated XP
    _loadStreak();

    return unlocked;
  }

  void refresh() {
    _loadStreak();
  }
}

/// Provider for all achievements
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAllAchievements();
});

/// Provider for unlocked achievements
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getUnlockedAchievements();
});

/// Provider for heatmap data
final heatmapDataProvider = Provider<Map<DateTime, int>>((ref) {
  final streak = ref.watch(streakProvider);
  return streak.getHeatmapData(90); // Last 90 days
});

/// Provider for achievement progress
final achievementProgressProvider = Provider<AchievementProgress>((ref) {
  final achievements = ref.watch(allAchievementsProvider);
  final unlocked = achievements.where((a) => a.isUnlocked).length;
  final total = achievements.length;

  return AchievementProgress(
    unlocked: unlocked,
    total: total,
    totalXpEarned: achievements
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.xpReward),
  );
});

/// Achievement progress data
class AchievementProgress {
  final int unlocked;
  final int total;
  final int totalXpEarned;

  const AchievementProgress({
    required this.unlocked,
    required this.total,
    required this.totalXpEarned,
  });

  double get progressPercentage => total > 0 ? unlocked / total : 0;
}
