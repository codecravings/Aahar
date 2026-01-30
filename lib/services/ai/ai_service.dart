import 'dart:typed_data';
import '../../core/errors/result.dart';

/// AI analysis result from food image
class FoodAnalysisResult {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double confidence;
  final String? foodName;
  final String? description;
  final List<FoodItem>? detectedItems;

  const FoodAnalysisResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.foodName,
    this.description,
    this.detectedItems,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Handle both single item and multiple items
    final items = json['items'] as List<dynamic>?;

    if (items != null && items.isNotEmpty) {
      // Multiple food items detected
      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      final detectedItems = <FoodItem>[];

      for (final item in items) {
        final foodItem = FoodItem.fromJson(item as Map<String, dynamic>);
        detectedItems.add(foodItem);
        totalCalories += foodItem.calories;
        totalProtein += foodItem.protein;
        totalCarbs += foodItem.carbs;
        totalFat += foodItem.fat;
      }

      return FoodAnalysisResult(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
        foodName: detectedItems.map((i) => i.name).join(', '),
        description: json['description'] as String?,
        detectedItems: detectedItems,
      );
    }

    // Single item response
    return FoodAnalysisResult(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
      foodName: json['food_name'] as String?,
      description: json['description'] as String?,
    );
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.5;

  String get confidenceLabel {
    if (isHighConfidence) return 'High';
    if (isMediumConfidence) return 'Medium';
    return 'Low';
  }
}

/// Individual food item in multi-food analysis
class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? portion;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.portion,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String? ?? 'Unknown',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      portion: json['portion'] as String?,
    );
  }
}

/// Abstract AI service interface for dependency injection
abstract class AIService {
  /// Analyze a food image and return macro estimates
  /// [userHint] is an optional description from the user about the food
  Future<Result<FoodAnalysisResult>> analyzeFood(Uint8List imageBytes, {String? userHint});

  /// Get the model identifier
  String get modelId;

  /// Get human-readable model name
  String get modelName;

  /// Check if the service is available
  Future<bool> isAvailable();
}
