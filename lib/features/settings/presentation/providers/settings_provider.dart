import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/gemini_service.dart';
import '../../../../services/database/database_service.dart';
import '../../domain/entities/user_settings.dart';

/// Provider for settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider for user settings state
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// Settings state notifier
class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const UserSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _repository.getSettings();
  }

  Future<void> updateCalorieTarget(int target) async {
    state = await _repository.updateSettings(calorieTarget: target);
  }

  Future<void> updateProteinTarget(int target) async {
    state = await _repository.updateSettings(proteinTarget: target);
  }

  Future<void> updateCarbsTarget(int target) async {
    state = await _repository.updateSettings(carbsTarget: target);
  }

  Future<void> updateFatTarget(int target) async {
    state = await _repository.updateSettings(fatTarget: target);
  }

  Future<void> updateAllTargets({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    state = await _repository.updateSettings(
      calorieTarget: calories,
      proteinTarget: protein,
      carbsTarget: carbs,
      fatTarget: fat,
    );
  }

  Future<void> updateSelectedModel(GeminiModel model) async {
    state = await _repository.updateSettings(selectedModelId: model.modelId);
  }

  Future<void> updateAccentColor(AccentColor color) async {
    state = await _repository.updateSettings(accentColor: color);
  }

  Future<void> updateNotifications(bool enabled) async {
    state = await _repository.updateSettings(notificationsEnabled: enabled);
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    state = await _repository.updateSettings(hapticFeedback: enabled);
  }

  Future<void> updateShowConfidence(bool show) async {
    state = await _repository.updateSettings(showConfidence: show);
  }

  Future<void> updateUserName(String name) async {
    state = await _repository.updateSettings(userName: name);
  }
}

/// Provider for selected AI model
final selectedModelProvider = Provider<GeminiModel>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.selectedModel;
});

/// Provider for AI service based on selected model
final aiServiceProvider = Provider<AIService>((ref) {
  final model = ref.watch(selectedModelProvider);
  return AIServiceFactory.create(model);
});

/// Provider for available AI models
final availableModelsProvider = Provider<List<GeminiModel>>((ref) {
  return GeminiModel.values.toList();
});
