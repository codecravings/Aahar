import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/motivation_engine.dart';
import '../../../food_entry/presentation/providers/food_log_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../streaks/presentation/providers/streak_provider.dart';
import '../../domain/entities/daily_stats.dart';

/// Provider for today's daily stats with targets
final dailyStatsProvider = Provider<DailyStats>((ref) {
  final macros = ref.watch(todaysMacrosProvider);
  final settings = ref.watch(settingsProvider);

  return DailyStats(
    date: DateTime.now(),
    calories: macros.calories,
    protein: macros.protein,
    carbs: macros.carbs,
    fat: macros.fat,
    calorieTarget: settings.calorieTarget,
    proteinTarget: settings.proteinTarget,
    carbsTarget: settings.carbsTarget,
    fatTarget: settings.fatTarget,
    logCount: macros.logCount,
  );
});

/// Provider for motivation message based on current stats
final motivationMessageProvider = Provider<MotivationMessage>((ref) {
  final stats = ref.watch(dailyStatsProvider);
  final streak = ref.watch(streakProvider);

  return MotivationEngine.evaluateDay(stats: stats, streak: streak);
});

/// Provider for greeting message
final greetingProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return MotivationEngine.getGreeting(settings.userName);
});

/// Provider for random tip
final randomTipProvider = Provider<String>((ref) {
  return MotivationEngine.getRandomTip();
});

/// Provider for weekly stats
final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  final repository = ref.watch(foodLogRepositoryProvider);
  final settings = ref.watch(settingsProvider);

  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  final dailyStatsList = <DailyStats>[];

  for (var i = 0; i < 7; i++) {
    final date = weekStart.add(Duration(days: i));
    if (date.isAfter(now)) break;

    final logs = repository.getFoodLogsForDate(date);
    final macros = logs.fold<Map<String, num>>(
      {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
      (acc, log) {
        acc['calories'] = (acc['calories'] as int) + log.calories;
        acc['protein'] = (acc['protein'] as double) + log.protein;
        acc['carbs'] = (acc['carbs'] as double) + log.carbs;
        acc['fat'] = (acc['fat'] as double) + log.fat;
        return acc;
      },
    );

    dailyStatsList.add(DailyStats(
      date: date,
      calories: macros['calories'] as int,
      protein: macros['protein'] as double,
      carbs: macros['carbs'] as double,
      fat: macros['fat'] as double,
      calorieTarget: settings.calorieTarget,
      proteinTarget: settings.proteinTarget,
      carbsTarget: settings.carbsTarget,
      fatTarget: settings.fatTarget,
      logCount: logs.length,
    ));
  }

  return WeeklyStats.fromDailyStats(dailyStatsList);
});

/// Provider for selected date (for viewing historical data)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for stats of selected date
final selectedDateStatsProvider = Provider<DailyStats>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(foodLogRepositoryProvider);
  final settings = ref.watch(settingsProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  // If selected date is today, use the reactive today's stats
  if (selected == today) {
    return ref.watch(dailyStatsProvider);
  }

  // Otherwise, fetch from repository
  final logs = repository.getFoodLogsForDate(selectedDate);
  final macros = logs.fold<Map<String, num>>(
    {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
    (acc, log) {
      acc['calories'] = (acc['calories'] as int) + log.calories;
      acc['protein'] = (acc['protein'] as double) + log.protein;
      acc['carbs'] = (acc['carbs'] as double) + log.carbs;
      acc['fat'] = (acc['fat'] as double) + log.fat;
      return acc;
    },
  );

  return DailyStats(
    date: selectedDate,
    calories: macros['calories'] as int,
    protein: macros['protein'] as double,
    carbs: macros['carbs'] as double,
    fat: macros['fat'] as double,
    calorieTarget: settings.calorieTarget,
    proteinTarget: settings.proteinTarget,
    carbsTarget: settings.carbsTarget,
    fatTarget: settings.fatTarget,
    logCount: logs.length,
  );
});

/// Dashboard view mode
enum DashboardViewMode { today, weekly }

/// Provider for dashboard view mode
final dashboardViewModeProvider = StateProvider<DashboardViewMode>((ref) {
  return DashboardViewMode.today;
});

/// Analytics period enum
enum AnalyticsPeriod { week, month, allTime }

/// Provider for analytics period
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  return AnalyticsPeriod.week;
});

/// Provider for monthly stats (last 30 days)
final monthlyStatsProvider = Provider<MonthlyStats>((ref) {
  final repository = ref.watch(foodLogRepositoryProvider);
  final settings = ref.watch(settingsProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final dailyStatsList = <DailyStats>[];

  for (var i = 0; i < 30; i++) {
    final date = today.subtract(Duration(days: i));
    final logs = repository.getFoodLogsForDate(date);
    final macros = logs.fold<Map<String, num>>(
      {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
      (acc, log) {
        acc['calories'] = (acc['calories'] as int) + log.calories;
        acc['protein'] = (acc['protein'] as double) + log.protein;
        acc['carbs'] = (acc['carbs'] as double) + log.carbs;
        acc['fat'] = (acc['fat'] as double) + log.fat;
        return acc;
      },
    );

    dailyStatsList.add(DailyStats(
      date: date,
      calories: macros['calories'] as int,
      protein: macros['protein'] as double,
      carbs: macros['carbs'] as double,
      fat: macros['fat'] as double,
      calorieTarget: settings.calorieTarget,
      proteinTarget: settings.proteinTarget,
      carbsTarget: settings.carbsTarget,
      fatTarget: settings.fatTarget,
      logCount: logs.length,
    ));
  }

  // Reverse so oldest is first
  return MonthlyStats.fromDailyStats(dailyStatsList.reversed.toList(), 30);
});

/// Provider for all-time stats
final allTimeStatsProvider = Provider<AllTimeStats>((ref) {
  final repository = ref.watch(foodLogRepositoryProvider);
  final settings = ref.watch(settingsProvider);

  final allLogs = repository.getAllFoodLogs();
  if (allLogs.isEmpty) {
    return AllTimeStats.empty();
  }

  // Group logs by date
  final logsByDate = <DateTime, List<dynamic>>{};
  for (final log in allLogs) {
    final dateKey = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
    logsByDate.putIfAbsent(dateKey, () => []).add(log);
  }

  final totalLoggedDays = logsByDate.length;
  final totalLogs = allLogs.length;

  // Calculate per-day stats
  var totalCalories = 0;
  var totalProtein = 0.0;
  var totalCarbs = 0.0;
  var totalFat = 0.0;
  var perfectDays = 0;
  DailyStats? bestProteinDay;
  var maxProtein = 0.0;
  DateTime? firstLogDate;

  for (final entry in logsByDate.entries) {
    final date = entry.key;
    final logs = entry.value;

    final dayCalories = logs.fold<int>(0, (sum, log) => sum + (log.calories as int));
    final dayProtein = logs.fold<double>(0, (sum, log) => sum + (log.protein as double));
    final dayCarbs = logs.fold<double>(0, (sum, log) => sum + (log.carbs as double));
    final dayFat = logs.fold<double>(0, (sum, log) => sum + (log.fat as double));

    totalCalories += dayCalories;
    totalProtein += dayProtein;
    totalCarbs += dayCarbs;
    totalFat += dayFat;

    final dayStats = DailyStats(
      date: date,
      calories: dayCalories,
      protein: dayProtein,
      carbs: dayCarbs,
      fat: dayFat,
      calorieTarget: settings.calorieTarget,
      proteinTarget: settings.proteinTarget,
      carbsTarget: settings.carbsTarget,
      fatTarget: settings.fatTarget,
      logCount: logs.length,
    );

    if (dayStats.isPerfectDay) {
      perfectDays++;
    }

    if (dayProtein > maxProtein) {
      maxProtein = dayProtein;
      bestProteinDay = dayStats;
    }

    if (firstLogDate == null || date.isBefore(firstLogDate)) {
      firstLogDate = date;
    }
  }

  // Calculate consistency (logged days / total days since first log)
  final now = DateTime.now();
  final daysSinceFirstLog = firstLogDate != null
      ? now.difference(firstLogDate).inDays + 1
      : 0;
  final consistencyRate = daysSinceFirstLog > 0
      ? (totalLoggedDays / daysSinceFirstLog * 100)
      : 0.0;

  return AllTimeStats(
    totalLoggedDays: totalLoggedDays,
    totalLogs: totalLogs,
    avgCalories: totalLoggedDays > 0 ? (totalCalories / totalLoggedDays).round() : 0,
    avgProtein: totalLoggedDays > 0 ? totalProtein / totalLoggedDays : 0,
    avgCarbs: totalLoggedDays > 0 ? totalCarbs / totalLoggedDays : 0,
    avgFat: totalLoggedDays > 0 ? totalFat / totalLoggedDays : 0,
    perfectDays: perfectDays,
    consistencyRate: consistencyRate,
    firstLogDate: firstLogDate,
    bestProteinDay: bestProteinDay,
  );
});
