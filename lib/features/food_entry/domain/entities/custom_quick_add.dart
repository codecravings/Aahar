import 'package:hive/hive.dart';

part 'custom_quick_add.g.dart';

/// Custom user-defined quick add option
@HiveType(typeId: 8)
class CustomQuickAdd extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final int calories;

  @HiveField(4)
  final double protein;

  @HiveField(5)
  final double carbs;

  @HiveField(6)
  final double fat;

  @HiveField(7)
  final DateTime createdAt;

  CustomQuickAdd({
    required this.id,
    required this.name,
    required this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });

  CustomQuickAdd copyWith({
    String? id,
    String? name,
    String? emoji,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? createdAt,
  }) {
    return CustomQuickAdd(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
