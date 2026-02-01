import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/database/database_service.dart';
import '../../../food_entry/domain/entities/food_log.dart';
import '../../../food_entry/presentation/providers/food_log_provider.dart';

/// Provider for selected history date
final selectedHistoryDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for food logs of selected history date
final historyLogsProvider = StateNotifierProvider<HistoryLogsNotifier, List<FoodLog>>((ref) {
  final repository = ref.watch(foodLogRepositoryProvider);
  final selectedDate = ref.watch(selectedHistoryDateProvider);
  return HistoryLogsNotifier(repository, selectedDate);
});

/// State notifier for history logs
class HistoryLogsNotifier extends StateNotifier<List<FoodLog>> {
  final FoodLogRepository _repository;
  final DateTime _selectedDate;

  HistoryLogsNotifier(this._repository, this._selectedDate) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    state = _repository.getFoodLogsForDate(_selectedDate);
  }

  Future<void> updateFoodLog(FoodLog log) async {
    await _repository.updateFoodLog(log);
    _loadLogs();
  }

  Future<void> deleteFoodLog(String id) async {
    await _repository.deleteFoodLog(id);
    _loadLogs();
  }

  void refresh() {
    _loadLogs();
  }
}

/// Provider for history date stats (macros for selected date)
final historyDateStatsProvider = Provider<HistoryDateStats>((ref) {
  final logs = ref.watch(historyLogsProvider);

  final calories = logs.fold<int>(0, (sum, log) => sum + log.calories);
  final protein = logs.fold<double>(0, (sum, log) => sum + log.protein);
  final carbs = logs.fold<double>(0, (sum, log) => sum + log.carbs);
  final fat = logs.fold<double>(0, (sum, log) => sum + log.fat);

  return HistoryDateStats(
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    logCount: logs.length,
  );
});

/// Stats for history date
class HistoryDateStats {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int logCount;

  const HistoryDateStats({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.logCount,
  });
}
