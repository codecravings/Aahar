import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'food_log.g.dart';

/// Represents a single food entry with macro information
@HiveType(typeId: 0)
class FoodLog extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final int calories;

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double carbs;

  @HiveField(5)
  final double fat;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final FoodLogSource source;

  @HiveField(8)
  final String? imagePath;

  @HiveField(9)
  final double? aiConfidence;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final MealType mealType;

  @HiveField(12)
  final String? description;

  @HiveField(13)
  final double? fiber;

  @HiveField(14)
  final double? sugar;

  @HiveField(15)
  final double? sodium;

  @HiveField(16)
  final double? vitaminD;

  @HiveField(17)
  final double? iron;

  @HiveField(18)
  final double? calcium;

  @HiveField(19)
  final String? emoji;

  @HiveField(20)
  final String? photoPath;

  const FoodLog({
    required this.id,
    this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
    required this.source,
    this.imagePath,
    this.aiConfidence,
    this.notes,
    required this.mealType,
    this.description,
    this.fiber,
    this.sugar,
    this.sodium,
    this.vitaminD,
    this.iron,
    this.calcium,
    this.emoji,
    this.photoPath,
  });

  /// Total macros in grams
  double get totalMacros => protein + carbs + fat;

  /// Create a copy with modifications
  FoodLog copyWith({
    String? id,
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? timestamp,
    FoodLogSource? source,
    String? imagePath,
    double? aiConfidence,
    String? notes,
    MealType? mealType,
    String? description,
    double? fiber,
    double? sugar,
    double? sodium,
    double? vitaminD,
    double? iron,
    double? calcium,
    String? emoji,
    String? photoPath,
  }) {
    return FoodLog(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      notes: notes ?? this.notes,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      vitaminD: vitaminD ?? this.vitaminD,
      iron: iron ?? this.iron,
      calcium: calcium ?? this.calcium,
      emoji: emoji ?? this.emoji,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        calories,
        protein,
        carbs,
        fat,
        timestamp,
        source,
        imagePath,
        aiConfidence,
        notes,
        mealType,
        description,
        fiber,
        sugar,
        sodium,
        vitaminD,
        iron,
        calcium,
        emoji,
        photoPath,
      ];
}

/// Source of the food log entry
@HiveType(typeId: 1)
enum FoodLogSource {
  @HiveField(0)
  manual,

  @HiveField(1)
  aiScan,

  @HiveField(2)
  quickAdd,
}

/// Meal type classification
@HiveType(typeId: 2)
enum MealType {
  @HiveField(0)
  breakfast('Breakfast', '🌅'),

  @HiveField(1)
  lunch('Lunch', '☀️'),

  @HiveField(2)
  dinner('Dinner', '🌙'),

  @HiveField(3)
  snack('Snack', '🍿');

  final String label;
  final String emoji;

  const MealType(this.label, this.emoji);
}
