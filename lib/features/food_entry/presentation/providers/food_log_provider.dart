import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/database/database_service.dart';
import '../../domain/entities/food_log.dart';
import '../../domain/entities/custom_quick_add.dart';

/// Provider for food log repository
final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return FoodLogRepository();
});

/// Provider for custom quick add repository
final customQuickAddRepositoryProvider = Provider<CustomQuickAddRepository>((ref) {
  return CustomQuickAddRepository();
});

/// Provider for today's food logs
final todaysFoodLogsProvider = StateNotifierProvider<TodaysFoodLogsNotifier, List<FoodLog>>((ref) {
  final repository = ref.watch(foodLogRepositoryProvider);
  return TodaysFoodLogsNotifier(repository);
});

/// State notifier for today's food logs
class TodaysFoodLogsNotifier extends StateNotifier<List<FoodLog>> {
  final FoodLogRepository _repository;
  final _uuid = const Uuid();

  TodaysFoodLogsNotifier(this._repository) : super([]) {
    _loadTodaysLogs();
  }

  void _loadTodaysLogs() {
    state = _repository.getFoodLogsForDate(DateTime.now());
  }

  Future<FoodLog> addFoodLog({
    String? name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required FoodLogSource source,
    required MealType mealType,
    String? imagePath,
    double? aiConfidence,
    String? notes,
    String? description,
    double? fiber,
    double? sugar,
    double? sodium,
    double? vitaminD,
    double? iron,
    double? calcium,
    String? emoji,
    String? photoPath,
  }) async {
    final log = FoodLog(
      id: _uuid.v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      timestamp: DateTime.now(),
      source: source,
      mealType: mealType,
      imagePath: imagePath,
      aiConfidence: aiConfidence,
      notes: notes,
      description: description,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      vitaminD: vitaminD,
      iron: iron,
      calcium: calcium,
      emoji: emoji,
      photoPath: photoPath,
    );

    await _repository.addFoodLog(log);
    _loadTodaysLogs();

    return log;
  }

  Future<void> updateFoodLog(FoodLog log) async {
    await _repository.updateFoodLog(log);
    _loadTodaysLogs();
  }

  Future<void> deleteFoodLog(String id) async {
    await _repository.deleteFoodLog(id);
    _loadTodaysLogs();
  }

  void refresh() {
    _loadTodaysLogs();
  }
}

/// Provider for food logs by specific date
final foodLogsByDateProvider = Provider.family<List<FoodLog>, DateTime>((ref, date) {
  final repository = ref.watch(foodLogRepositoryProvider);
  return repository.getFoodLogsForDate(date);
});

/// Provider for today's total macros
final todaysMacrosProvider = Provider<TodaysMacros>((ref) {
  final logs = ref.watch(todaysFoodLogsProvider);

  final calories = logs.fold<int>(0, (sum, log) => sum + log.calories);
  final protein = logs.fold<double>(0, (sum, log) => sum + log.protein);
  final carbs = logs.fold<double>(0, (sum, log) => sum + log.carbs);
  final fat = logs.fold<double>(0, (sum, log) => sum + log.fat);

  return TodaysMacros(
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    logCount: logs.length,
  );
});

/// Today's macro totals
class TodaysMacros {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int logCount;

  const TodaysMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.logCount,
  });

  /// Check if any food has been logged
  bool get hasLogs => logCount > 0;
}

/// Provider for custom quick add options (user-created)
final customQuickAddsProvider = StateNotifierProvider<CustomQuickAddsNotifier, List<CustomQuickAdd>>((ref) {
  final repository = ref.watch(customQuickAddRepositoryProvider);
  return CustomQuickAddsNotifier(repository);
});

/// State notifier for custom quick add options
class CustomQuickAddsNotifier extends StateNotifier<List<CustomQuickAdd>> {
  final CustomQuickAddRepository _repository;
  final _uuid = const Uuid();

  CustomQuickAddsNotifier(this._repository) : super([]) {
    _loadCustomQuickAdds();
  }

  void _loadCustomQuickAdds() {
    state = _repository.getAllCustomQuickAdds();
  }

  Future<void> addCustomQuickAdd({
    required String name,
    required String emoji,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final option = CustomQuickAdd(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      createdAt: DateTime.now(),
    );

    await _repository.addCustomQuickAdd(option);
    _loadCustomQuickAdds();
  }

  Future<void> deleteCustomQuickAdd(String id) async {
    await _repository.deleteCustomQuickAdd(id);
    _loadCustomQuickAdds();
  }
}

/// Provider for all quick add options (built-in + custom)
final quickAddOptionsProvider = Provider<List<QuickAddOption>>((ref) {
  // Built-in options
  final builtIn = const [
    QuickAddOption(
      name: 'Ande (2 boiled)',
      emoji: '🥚',
      calories: 140,
      protein: 12,
      carbs: 1,
      fat: 10,
    ),
    QuickAddOption(
      name: 'Chicken Breast (100g)',
      emoji: '🍗',
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
    ),
    QuickAddOption(
      name: 'Paneer (100g)',
      emoji: '🧀',
      calories: 265,
      protein: 18,
      carbs: 3,
      fat: 21,
    ),
    QuickAddOption(
      name: 'Roti (1 chapati)',
      emoji: '🫓',
      calories: 70,
      protein: 2.5,
      carbs: 15,
      fat: 0.5,
    ),
    QuickAddOption(
      name: 'Rice (1 cup cooked)',
      emoji: '🍚',
      calories: 200,
      protein: 4,
      carbs: 45,
      fat: 0.5,
    ),
    QuickAddOption(
      name: 'Dal (1 cup)',
      emoji: '🫘',
      calories: 150,
      protein: 12,
      carbs: 20,
      fat: 3,
    ),
    QuickAddOption(
      name: 'Whey Protein (1 scoop)',
      emoji: '🥤',
      calories: 155,
      protein: 30,
      carbs: 3,
      fat: 1.5,
    ),
    QuickAddOption(
      name: 'Banana',
      emoji: '🍌',
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fat: 0.4,
    ),
    QuickAddOption(
      name: 'Apple (medium)',
      emoji: '🍎',
      calories: 95,
      protein: 0.5,
      carbs: 25,
      fat: 0.3,
    ),
    QuickAddOption(
      name: 'Greek Yogurt (1 cup)',
      emoji: '🥛',
      calories: 150,
      protein: 15,
      carbs: 8,
      fat: 5,
    ),
    QuickAddOption(
      name: 'Peanut Butter (2 tbsp)',
      emoji: '🥜',
      calories: 190,
      protein: 8,
      carbs: 6,
      fat: 16,
    ),
  ];

  // Custom user-created options
  final custom = ref.watch(customQuickAddsProvider);
  final customOptions = custom.map((c) => QuickAddOption(
        name: c.name,
        emoji: c.emoji,
        calories: c.calories,
        protein: c.protein,
        carbs: c.carbs,
        fat: c.fat,
        isCustom: true,
        customId: c.id,
      )).toList();

  // Merge: custom first, then built-in
  return [...customOptions, ...builtIn];
});

/// Quick add preset option
class QuickAddOption {
  final String name;
  final String emoji;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool isCustom;
  final String? customId;

  const QuickAddOption({
    required this.name,
    required this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isCustom = false,
    this.customId,
  });
}
