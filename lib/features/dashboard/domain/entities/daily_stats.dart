import 'package:equatable/equatable.dart';

/// Daily macro statistics with targets
class DailyStats extends Equatable {
  final DateTime date;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int calorieTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int logCount;

  const DailyStats({
    required this.date,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    this.logCount = 0,
  });

  // Progress percentages (capped at 1.0 for UI)
  double get calorieProgress => (calories / calorieTarget).clamp(0.0, 1.5);
  double get proteinProgress => (protein / proteinTarget).clamp(0.0, 1.5);
  double get carbsProgress => (carbs / carbsTarget).clamp(0.0, 1.5);
  double get fatProgress => (fat / fatTarget).clamp(0.0, 1.5);

  // Remaining values
  int get caloriesRemaining => (calorieTarget - calories).clamp(0, calorieTarget);
  double get proteinRemaining => (proteinTarget - protein).clamp(0, proteinTarget.toDouble());
  double get carbsRemaining => (carbsTarget - carbs).clamp(0, carbsTarget.toDouble());
  double get fatRemaining => (fatTarget - fat).clamp(0, fatTarget.toDouble());

  // Over/under status
  bool get isOverCalories => calories > calorieTarget;
  bool get isUnderProtein => protein < (proteinTarget * 0.8);
  bool get isOverFat => fat > fatTarget;

  // Perfect day check (within 10% of all targets)
  bool get isPerfectDay {
    final calInRange = (calories / calorieTarget) >= 0.9 && (calories / calorieTarget) <= 1.1;
    final proteinInRange = (protein / proteinTarget) >= 0.9;
    final carbsInRange = (carbs / carbsTarget) >= 0.8 && (carbs / carbsTarget) <= 1.2;
    final fatInRange = (fat / fatTarget) <= 1.1;
    return calInRange && proteinInRange && carbsInRange && fatInRange;
  }

  // Has any entries
  bool get hasLogs => logCount > 0;

  DailyStats copyWith({
    DateTime? date,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? calorieTarget,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    int? logCount,
  }) {
    return DailyStats(
      date: date ?? this.date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      logCount: logCount ?? this.logCount,
    );
  }

  /// Add a food entry to stats
  DailyStats addFood({
    required int addCalories,
    required double addProtein,
    required double addCarbs,
    required double addFat,
  }) {
    return copyWith(
      calories: calories + addCalories,
      protein: protein + addProtein,
      carbs: carbs + addCarbs,
      fat: fat + addFat,
      logCount: logCount + 1,
    );
  }

  @override
  List<Object?> get props => [
        date,
        calories,
        protein,
        carbs,
        fat,
        calorieTarget,
        proteinTarget,
        carbsTarget,
        fatTarget,
        logCount,
      ];
}

/// Weekly statistics for analytics
class WeeklyStats extends Equatable {
  final DateTime weekStart;
  final List<DailyStats> dailyStats;
  final int avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;
  final int perfectDays;
  final int loggedDays;

  const WeeklyStats({
    required this.weekStart,
    required this.dailyStats,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.perfectDays,
    required this.loggedDays,
  });

  factory WeeklyStats.fromDailyStats(List<DailyStats> stats) {
    if (stats.isEmpty) {
      return WeeklyStats(
        weekStart: DateTime.now(),
        dailyStats: [],
        avgCalories: 0,
        avgProtein: 0,
        avgCarbs: 0,
        avgFat: 0,
        perfectDays: 0,
        loggedDays: 0,
      );
    }

    final loggedDays = stats.where((s) => s.hasLogs).length;
    final divisor = loggedDays > 0 ? loggedDays : 1;

    return WeeklyStats(
      weekStart: stats.first.date,
      dailyStats: stats,
      avgCalories: (stats.fold<int>(0, (sum, s) => sum + s.calories) / divisor).round(),
      avgProtein: stats.fold<double>(0, (sum, s) => sum + s.protein) / divisor,
      avgCarbs: stats.fold<double>(0, (sum, s) => sum + s.carbs) / divisor,
      avgFat: stats.fold<double>(0, (sum, s) => sum + s.fat) / divisor,
      perfectDays: stats.where((s) => s.isPerfectDay).length,
      loggedDays: loggedDays,
    );
  }

  @override
  List<Object?> get props => [
        weekStart,
        dailyStats,
        avgCalories,
        avgProtein,
        avgCarbs,
        avgFat,
        perfectDays,
        loggedDays,
      ];
}
