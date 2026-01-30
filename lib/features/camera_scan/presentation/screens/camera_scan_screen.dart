import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../food_entry/domain/entities/food_log.dart';
import '../../../food_entry/presentation/providers/food_log_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../streaks/presentation/providers/streak_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/camera_scan_provider.dart';

class CameraScanScreen extends ConsumerStatefulWidget {
  const CameraScanScreen({super.key});

  @override
  ConsumerState<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends ConsumerState<CameraScanScreen> {
  MealType _selectedMealType = MealType.lunch;

  @override
  void initState() {
    super.initState();
    _determineMealType();
  }

  void _determineMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      _selectedMealType = MealType.breakfast;
    } else if (hour < 15) {
      _selectedMealType = MealType.lunch;
    } else if (hour < 20) {
      _selectedMealType = MealType.dinner;
    } else {
      _selectedMealType = MealType.snack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(cameraScanProvider);
    final modelName = ref.watch(currentModelNameProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('AI Food Scan'),
        leading: IconButton(
          icon: const Icon(PhosphorIcons.x),
          onPressed: () {
            ref.read(cameraScanProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIcons.robot,
                  color: AppTheme.neonPurple,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  modelName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.neonPurple,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: _buildContent(scanState, settings),
              ),
              _buildBottomActions(scanState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CameraScanState scanState, settings) {
    if (scanState.isIdle) {
      return _IdleState(
        onCameraPressed: () {
          HapticFeedback.mediumImpact();
          ref.read(cameraScanProvider.notifier).captureImage();
        },
        onGalleryPressed: () {
          HapticFeedback.mediumImpact();
          ref.read(cameraScanProvider.notifier).pickImage();
        },
      );
    }

    if (scanState.isCaptured) {
      return _CapturedState(
        imagePath: scanState.capturedImage!.compressedPath,
        onAnalyze: (userHint) {
          HapticFeedback.mediumImpact();
          ref
              .read(cameraScanProvider.notifier)
              .analyzeWithHint(userHint: userHint);
        },
        onRetake: () {
          ref.read(cameraScanProvider.notifier).reset();
        },
      );
    }

    if (scanState.isLoading) {
      return _LoadingState(
        statusMessage: scanState.statusMessage ?? 'Processing...',
        imagePath: scanState.capturedImage?.compressedPath,
      );
    }

    if (scanState.hasError) {
      return _ErrorState(
        error: scanState.error?.message ?? 'Unknown error occurred',
        onRetry: () {
          ref.read(cameraScanProvider.notifier).retryAnalysis();
        },
        onReset: () {
          ref.read(cameraScanProvider.notifier).reset();
        },
      );
    }

    if (scanState.isComplete && scanState.analysisResult != null) {
      return _EditableResultState(
        result: scanState.analysisResult!,
        imagePath: scanState.capturedImage?.compressedPath,
        showConfidence: settings.showConfidence,
        selectedMealType: _selectedMealType,
        onMealTypeChanged: (type) {
          setState(() => _selectedMealType = type);
        },
        onSave: (editedCalories, editedProtein, editedCarbs, editedFat, notes,
            fiber, sugar, sodium, vitaminD, iron, calcium) {
          _saveEditedResult(
            scanState,
            editedCalories,
            editedProtein,
            editedCarbs,
            editedFat,
            notes,
            fiber,
            sugar,
            sodium,
            vitaminD,
            iron,
            calcium,
          );
        },
        onRetry: () {
          ref.read(cameraScanProvider.notifier).retryAnalysis();
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomActions(CameraScanState scanState) {
    if (scanState.isIdle || scanState.isLoading) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  Future<void> _saveEditedResult(
    CameraScanState scanState,
    int calories,
    double protein,
    double carbs,
    double fat,
    String? notes,
    double? fiber,
    double? sugar,
    double? sodium,
    double? vitaminD,
    double? iron,
    double? calcium,
  ) async {
    if (scanState.analysisResult == null) return;

    HapticFeedback.heavyImpact();

    final result = scanState.analysisResult!;
    final stats = ref.read(dailyStatsProvider);

    await ref.read(todaysFoodLogsProvider.notifier).addFoodLog(
          name: result.foodName,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          source: FoodLogSource.aiScan,
          mealType: _selectedMealType,
          imagePath: scanState.capturedImage?.compressedPath,
          aiConfidence: result.confidence,
          description: result.description,
          notes: notes,
          fiber: fiber,
          sugar: sugar,
          sodium: sodium,
          vitaminD: vitaminD,
          iron: iron,
          calcium: calcium,
        );

    final unlockedAchievements = await ref
        .read(streakProvider.notifier)
        .recordLog(isPerfectDay: stats.isPerfectDay);

    ref.read(cameraScanProvider.notifier).reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(PhosphorIcons.check_circle, color: AppTheme.neonGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added $calories cal \u2022 ${protein.toStringAsFixed(0)}g protein',
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      for (final achievement in unlockedAchievements) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Achievement Unlocked!'),
                        Text(
                          achievement.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: const TextStyle(color: AppTheme.neonGreen),
                  ),
                ],
              ),
              backgroundColor: AppTheme.neonPurple.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      Navigator.of(context).pop();
    }
  }
}

class _IdleState extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _IdleState({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppTheme.neonPurple.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: const Icon(
            PhosphorIcons.camera,
            size: 80,
            color: AppTheme.neonPurple,
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.8, 0.8),
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 32),
        Text(
          'Scan Your Food',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'AI will analyze and estimate macros',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: PhosphorIcons.camera,
              label: 'Camera',
              color: AppTheme.neonPurple,
              onPressed: onCameraPressed,
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
            const SizedBox(width: 24),
            _ActionButton(
              icon: PhosphorIcons.image,
              label: 'Gallery',
              color: AppTheme.neonBlue,
              onPressed: onGalleryPressed,
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
          ],
        ),
      ],
    );
  }
}

class _CapturedState extends StatefulWidget {
  final String imagePath;
  final void Function(String? userHint) onAnalyze;
  final VoidCallback onRetake;

  const _CapturedState({
    required this.imagePath,
    required this.onAnalyze,
    required this.onRetake,
  });

  @override
  State<_CapturedState> createState() => _CapturedStateState();
}

class _CapturedStateState extends State<_CapturedState> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          Text(
            'Describe your food (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'Helps AI identify the food more accurately',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'e.g. "Paneer butter masala with 2 rotis"',
              prefixIcon: Icon(PhosphorIcons.pencil_simple),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRetake,
                  icon: const Icon(PhosphorIcons.arrow_counter_clockwise),
                  label: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final hint = _descriptionController.text.trim();
                    widget.onAnalyze(hint.isNotEmpty ? hint : null);
                  },
                  icon: const Icon(PhosphorIcons.robot),
                  label: const Text('Analyze'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String statusMessage;
  final String? imagePath;

  const _LoadingState({
    required this.statusMessage,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(imagePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1500.ms,
                color: AppTheme.neonPurple.withOpacity(0.3),
              )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              PhosphorIcons.robot,
              size: 60,
              color: AppTheme.neonPurple,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 800.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
                duration: 800.ms,
              ),
        const SizedBox(height: 32),
        Text(
          statusMessage,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonPurple,
              ),
        ).animate(onPlay: (c) => c.repeat()).fadeIn().then().fadeOut(),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: AppTheme.surfaceLight,
            valueColor: const AlwaysStoppedAnimation(AppTheme.neonPurple),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            PhosphorIcons.warning,
            size: 64,
            color: AppTheme.error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Analysis Failed',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(PhosphorIcons.arrow_counter_clockwise),
              label: const Text('Start Over'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(PhosphorIcons.arrow_clockwise),
              label: const Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditableResultState extends StatefulWidget {
  final dynamic result;
  final String? imagePath;
  final bool showConfidence;
  final MealType selectedMealType;
  final ValueChanged<MealType> onMealTypeChanged;
  final void Function(int calories, double protein, double carbs, double fat,
      String? notes, double? fiber, double? sugar, double? sodium,
      double? vitaminD, double? iron, double? calcium) onSave;
  final VoidCallback onRetry;

  const _EditableResultState({
    required this.result,
    this.imagePath,
    required this.showConfidence,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.onSave,
    required this.onRetry,
  });

  @override
  State<_EditableResultState> createState() => _EditableResultStateState();
}

class _EditableResultStateState extends State<_EditableResultState> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  final _notesController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _vitaminDController = TextEditingController();
  final _ironController = TextEditingController();
  final _calciumController = TextEditingController();
  bool _showMoreNutrients = false;

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.result.calories.toString());
    _proteinController =
        TextEditingController(text: widget.result.protein.toStringAsFixed(1));
    _carbsController =
        TextEditingController(text: widget.result.carbs.toStringAsFixed(1));
    _fatController =
        TextEditingController(text: widget.result.fat.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _vitaminDController.dispose();
    _ironController.dispose();
    _calciumController.dispose();
    super.dispose();
  }

  double? _parseOptional(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Image preview
          if (widget.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(widget.imagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 20),

          // Food name
          if (widget.result.foodName != null)
            Text(
              widget.result.foodName!,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),

          // Confidence badge
          if (widget.showConfidence)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getConfidenceColor(widget.result.confidence)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getConfidenceColor(widget.result.confidence)
                      .withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getConfidenceIcon(widget.result.confidence),
                    color: _getConfidenceColor(widget.result.confidence),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(widget.result.confidence * 100).toInt()}% confidence',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:
                              _getConfidenceColor(widget.result.confidence),
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),

          // AI Description
          if (widget.result.description != null &&
              widget.result.description!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info,
                    color: AppTheme.neonBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.result.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 175.ms),

          const SizedBox(height: 24),

          // Editable macro fields
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Macros',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                _EditableMacroField(
                  label: 'Calories',
                  controller: _caloriesController,
                  unit: 'kcal',
                  color: AppTheme.caloriesColor,
                  icon: PhosphorIcons.fire,
                  isInteger: true,
                ),
                const SizedBox(height: 12),
                _EditableMacroField(
                  label: 'Protein',
                  controller: _proteinController,
                  unit: 'g',
                  color: AppTheme.proteinColor,
                  icon: PhosphorIcons.barbell,
                ),
                const SizedBox(height: 12),
                _EditableMacroField(
                  label: 'Carbs',
                  controller: _carbsController,
                  unit: 'g',
                  color: AppTheme.carbsColor,
                  icon: Icons.grain,
                ),
                const SizedBox(height: 12),
                _EditableMacroField(
                  label: 'Fat',
                  controller: _fatController,
                  unit: 'g',
                  color: AppTheme.fatColor,
                  icon: PhosphorIcons.drop,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 16),

          // More Nutrients expandable
          GlassCard(
            onTap: () {
              setState(() => _showMoreNutrients = !_showMoreNutrients);
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _showMoreNutrients
                      ? PhosphorIcons.caret_up
                      : PhosphorIcons.caret_down,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'More Nutrients (optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 220.ms),

          if (_showMoreNutrients) ...[
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOptionalField('Fiber', _fiberController, 'g'),
                  const SizedBox(height: 10),
                  _buildOptionalField('Sugar', _sugarController, 'g'),
                  const SizedBox(height: 10),
                  _buildOptionalField('Sodium', _sodiumController, 'mg'),
                  const SizedBox(height: 10),
                  _buildOptionalField('Vitamin D', _vitaminDController, 'mcg'),
                  const SizedBox(height: 10),
                  _buildOptionalField('Iron', _ironController, 'mg'),
                  const SizedBox(height: 10),
                  _buildOptionalField('Calcium', _calciumController, 'mg'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Notes field
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(PhosphorIcons.note),
                border: InputBorder.none,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ).animate().fadeIn(delay: 240.ms),

          const SizedBox(height: 20),

          // Meal type selector
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: MealType.values.map((type) {
                    final isSelected = type == widget.selectedMealType;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onMealTypeChanged(type);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.neonGreen.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.neonGreen
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? AppTheme.neonGreen
                                        : AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(PhosphorIcons.arrow_clockwise),
                  label: const Text('Rescan'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final calories =
                        int.tryParse(_caloriesController.text) ?? 0;
                    final protein =
                        double.tryParse(_proteinController.text) ?? 0;
                    final carbs =
                        double.tryParse(_carbsController.text) ?? 0;
                    final fat = double.tryParse(_fatController.text) ?? 0;
                    final notes = _notesController.text.isNotEmpty
                        ? _notesController.text
                        : null;
                    widget.onSave(
                      calories,
                      protein,
                      carbs,
                      fat,
                      notes,
                      _parseOptional(_fiberController.text),
                      _parseOptional(_sugarController.text),
                      _parseOptional(_sodiumController.text),
                      _parseOptional(_vitaminDController.text),
                      _parseOptional(_ironController.text),
                      _parseOptional(_calciumController.text),
                    );
                  },
                  icon: const Icon(PhosphorIcons.check),
                  label: const Text('Add to Log'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionalField(
      String label, TextEditingController controller, String unit) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.neonGreen;
    if (confidence >= 0.5) return AppTheme.warning;
    return AppTheme.error;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return PhosphorIcons.check_circle;
    if (confidence >= 0.5) return PhosphorIcons.warning_circle;
    return PhosphorIcons.x_circle;
  }
}

class _EditableMacroField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Color color;
  final IconData icon;
  final bool isInteger;

  const _EditableMacroField({
    required this.label,
    required this.controller,
    required this.unit,
    required this.color,
    required this.icon,
    this.isInteger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              suffixText: unit,
              suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
            keyboardType: isInteger
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: isInteger
                ? [FilteringTextInputFormatter.digitsOnly]
                : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          ),
        ),
      ],
    );
  }
}
