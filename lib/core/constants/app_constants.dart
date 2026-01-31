import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Aahar';
  static const String appVersion = '1.0.0';

  // Logo
  static const String logoPath = 'assets/images/logo0.png';

  // Gemini API - loaded from .env
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // OpenAI API - loaded from .env
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String openaiBaseUrl = 'https://api.openai.com/v1';

  // Default Macro Targets
  static const int defaultCalorieTarget = 2000;
  static const int defaultProteinTarget = 150;
  static const int defaultCarbsTarget = 250;
  static const int defaultFatTarget = 65;

  // Image Processing
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  // Streak & XP
  static const int xpPerLog = 10;
  static const int xpPerPerfectDay = 50;
  static const int xpPerStreakDay = 5;
  static const int streakBonusMultiplier = 2;

  // Hive Boxes
  static const String foodLogsBox = 'food_logs';
  static const String settingsBox = 'settings';
  static const String streaksBox = 'streaks';
  static const String achievementsBox = 'achievements';
  static const String userBox = 'user';
  static const String customQuickAddBox = 'custom_quick_add';
}

/// AI Provider types
enum AIProvider { gemini, openai }

/// AI Model configurations
enum AIModel {
  flash('gemini-2.0-flash', 'Gemini 2.0 Flash', 'Fast & Efficient', AIProvider.gemini),
  pro('gemini-2.5-pro', 'Gemini 2.5 Pro', 'Most Accurate', AIProvider.gemini),
  flashLite('gemini-2.0-flash-lite', 'Gemini 2.0 Flash Lite', 'Fast & Cheap', AIProvider.gemini),
  gpt5Mini('gpt-5-mini', 'GPT-5 Mini', 'OpenAI - Fast & Smart', AIProvider.openai);

  final String modelId;
  final String displayName;
  final String description;
  final AIProvider provider;

  const AIModel(this.modelId, this.displayName, this.description, this.provider);

  static AIModel fromId(String id) {
    return AIModel.values.firstWhere(
      (m) => m.modelId == id,
      orElse: () => AIModel.flash,
    );
  }
}

/// Performance states for motivation engine
enum PerformanceState {
  proteinLow,
  proteinHigh,
  caloriesLow,
  caloriesHigh,
  caloriesPerfect,
  perfectDay,
  streakActive,
  streakBroken,
  newStreak,
  milestone,
  comeback,
}
