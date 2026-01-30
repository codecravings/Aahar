import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../streaks/presentation/providers/streak_provider.dart';
import '../../domain/entities/food_log.dart';
import '../providers/food_log_provider.dart';

class FoodEntryScreen extends ConsumerStatefulWidget {
  final FoodLog? existingLog;

  const FoodEntryScreen({super.key, this.existingLog});

  @override
  ConsumerState<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends ConsumerState<FoodEntryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _vitaminDController = TextEditingController();
  final _ironController = TextEditingController();
  final _calciumController = TextEditingController();
  final _notesController = TextEditingController();

  MealType _selectedMealType = MealType.lunch;
  bool _isSubmitting = false;
  bool _showMoreNutrients = false;
  String? _selectedEmoji;
  String? _photoPath;
  bool get _isEditMode => widget.existingLog != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEditMode) {
      _populateFromExisting(widget.existingLog!);
      _tabController.index = 1; // Go to manual tab for editing
    } else {
      _determineMealType();
    }
  }

  void _populateFromExisting(FoodLog log) {
    _nameController.text = log.name ?? '';
    _caloriesController.text = log.calories.toString();
    _proteinController.text = log.protein.toString();
    _carbsController.text = log.carbs.toString();
    _fatController.text = log.fat.toString();
    _selectedMealType = log.mealType;
    _selectedEmoji = log.emoji;
    _photoPath = log.photoPath;
    _notesController.text = log.notes ?? '';

    if (log.fiber != null) _fiberController.text = log.fiber.toString();
    if (log.sugar != null) _sugarController.text = log.sugar.toString();
    if (log.sodium != null) _sodiumController.text = log.sodium.toString();
    if (log.vitaminD != null) _vitaminDController.text = log.vitaminD.toString();
    if (log.iron != null) _ironController.text = log.iron.toString();
    if (log.calcium != null) _calciumController.text = log.calcium.toString();

    if (log.fiber != null ||
        log.sugar != null ||
        log.sodium != null ||
        log.vitaminD != null ||
        log.iron != null ||
        log.calcium != null) {
      _showMoreNutrients = true;
    }
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
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _vitaminDController.dispose();
    _ironController.dispose();
    _calciumController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null) {
      setState(() {
        _photoPath = image.path;
        _selectedEmoji = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickAddOptions = ref.watch(quickAddOptionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_isEditMode ? 'Edit Food' : 'Add Food'),
        leading: IconButton(
          icon: const Icon(PhosphorIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: _isEditMode
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.neonGreen,
                labelColor: AppTheme.neonGreen,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(text: 'Quick Add'),
                  Tab(text: 'Manual'),
                ],
              ),
      ),
      body: _isEditMode
          ? _ManualEntryTab(
              formKey: _formKey,
              nameController: _nameController,
              caloriesController: _caloriesController,
              proteinController: _proteinController,
              carbsController: _carbsController,
              fatController: _fatController,
              fiberController: _fiberController,
              sugarController: _sugarController,
              sodiumController: _sodiumController,
              vitaminDController: _vitaminDController,
              ironController: _ironController,
              calciumController: _calciumController,
              notesController: _notesController,
              selectedMealType: _selectedMealType,
              onMealTypeChanged: (type) {
                setState(() => _selectedMealType = type);
              },
              isSubmitting: _isSubmitting,
              onSubmit: _submitManualEntry,
              showMoreNutrients: _showMoreNutrients,
              onToggleMoreNutrients: () {
                setState(() => _showMoreNutrients = !_showMoreNutrients);
              },
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() {
                  _selectedEmoji = emoji;
                  _photoPath = null;
                });
              },
              photoPath: _photoPath,
              onPickPhoto: _pickPhoto,
              onRemovePhoto: () {
                setState(() => _photoPath = null);
              },
              isEditMode: true,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _QuickAddTab(
                  options: quickAddOptions,
                  selectedMealType: _selectedMealType,
                  onMealTypeChanged: (type) {
                    setState(() => _selectedMealType = type);
                  },
                  onOptionSelected: (option) => _addQuickOption(option),
                ),
                _ManualEntryTab(
                  formKey: _formKey,
                  nameController: _nameController,
                  caloriesController: _caloriesController,
                  proteinController: _proteinController,
                  carbsController: _carbsController,
                  fatController: _fatController,
                  fiberController: _fiberController,
                  sugarController: _sugarController,
                  sodiumController: _sodiumController,
                  vitaminDController: _vitaminDController,
                  ironController: _ironController,
                  calciumController: _calciumController,
                  notesController: _notesController,
                  selectedMealType: _selectedMealType,
                  onMealTypeChanged: (type) {
                    setState(() => _selectedMealType = type);
                  },
                  isSubmitting: _isSubmitting,
                  onSubmit: _submitManualEntry,
                  showMoreNutrients: _showMoreNutrients,
                  onToggleMoreNutrients: () {
                    setState(() => _showMoreNutrients = !_showMoreNutrients);
                  },
                  selectedEmoji: _selectedEmoji,
                  onEmojiSelected: (emoji) {
                    setState(() {
                      _selectedEmoji = emoji;
                      _photoPath = null;
                    });
                  },
                  photoPath: _photoPath,
                  onPickPhoto: _pickPhoto,
                  onRemovePhoto: () {
                    setState(() => _photoPath = null);
                  },
                  isEditMode: false,
                ),
              ],
            ),
    );
  }

  Future<void> _addQuickOption(QuickAddOption option) async {
    HapticFeedback.mediumImpact();

    final stats = ref.read(dailyStatsProvider);

    await ref.read(todaysFoodLogsProvider.notifier).addFoodLog(
          name: option.name,
          calories: option.calories,
          protein: option.protein,
          carbs: option.carbs,
          fat: option.fat,
          source: FoodLogSource.quickAdd,
          mealType: _selectedMealType,
        );

    await ref
        .read(streakProvider.notifier)
        .recordLog(isPerfectDay: stats.isPerfectDay);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Added ${option.name}'),
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
      Navigator.of(context).pop();
    }
  }

  double? _parseOptionalDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _submitManualEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final stats = ref.read(dailyStatsProvider);

      if (_isEditMode) {
        final updated = widget.existingLog!.copyWith(
          name: _nameController.text.isNotEmpty ? _nameController.text : null,
          calories: int.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fat: double.parse(_fatController.text),
          mealType: _selectedMealType,
          fiber: _parseOptionalDouble(_fiberController.text),
          sugar: _parseOptionalDouble(_sugarController.text),
          sodium: _parseOptionalDouble(_sodiumController.text),
          vitaminD: _parseOptionalDouble(_vitaminDController.text),
          iron: _parseOptionalDouble(_ironController.text),
          calcium: _parseOptionalDouble(_calciumController.text),
          emoji: _selectedEmoji,
          photoPath: _photoPath,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await ref.read(todaysFoodLogsProvider.notifier).updateFoodLog(updated);
      } else {
        await ref.read(todaysFoodLogsProvider.notifier).addFoodLog(
              name: _nameController.text.isNotEmpty ? _nameController.text : null,
              calories: int.parse(_caloriesController.text),
              protein: double.parse(_proteinController.text),
              carbs: double.parse(_carbsController.text),
              fat: double.parse(_fatController.text),
              source: FoodLogSource.manual,
              mealType: _selectedMealType,
              fiber: _parseOptionalDouble(_fiberController.text),
              sugar: _parseOptionalDouble(_sugarController.text),
              sodium: _parseOptionalDouble(_sodiumController.text),
              vitaminD: _parseOptionalDouble(_vitaminDController.text),
              iron: _parseOptionalDouble(_ironController.text),
              calcium: _parseOptionalDouble(_calciumController.text),
              emoji: _selectedEmoji,
              photoPath: _photoPath,
              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            );

        await ref
            .read(streakProvider.notifier)
            .recordLog(isPerfectDay: stats.isPerfectDay);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIcons.check_circle, color: AppTheme.neonGreen),
                const SizedBox(width: 12),
                Text(_isEditMode ? 'Entry updated!' : 'Food entry added!'),
              ],
            ),
            backgroundColor: AppTheme.surfaceLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _QuickAddTab extends StatelessWidget {
  final List<QuickAddOption> options;
  final MealType selectedMealType;
  final ValueChanged<MealType> onMealTypeChanged;
  final ValueChanged<QuickAddOption> onOptionSelected;

  const _QuickAddTab({
    required this.options,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Meal type selector
        _MealTypeSelector(
          selectedMealType: selectedMealType,
          onMealTypeChanged: onMealTypeChanged,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 24),

        Text(
          'Quick Add',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 4),
        Text(
          'Tap to add common foods',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),

        // Quick add grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return _QuickAddCard(
              option: option,
              onTap: () => onOptionSelected(option),
            ).animate().fadeIn(delay: (200 + index * 50).ms).slideY(begin: 0.1);
          },
        ),
      ],
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  final QuickAddOption option;
  final VoidCallback onTap;

  const _QuickAddCard({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            option.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            option.name,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${option.calories} cal \u2022 ${option.protein.toStringAsFixed(0)}g P',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

const _foodEmojis = [
  '🍕', '🍔', '🌮', '🥗', '🍜', '🍛', '🥘', '🍱',
  '🥙', '🧆', '🍝', '🍲', '🥣', '🍙', '🍘', '🥟',
  '🍳', '🥞', '🧇', '🥐', '🍞', '🥖', '🧀', '🥩',
  '🍗', '🥚', '🥜', '🫘', '🥦', '🥕', '🍎', '🍌',
];

class _ManualEntryTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextEditingController fiberController;
  final TextEditingController sugarController;
  final TextEditingController sodiumController;
  final TextEditingController vitaminDController;
  final TextEditingController ironController;
  final TextEditingController calciumController;
  final TextEditingController notesController;
  final MealType selectedMealType;
  final ValueChanged<MealType> onMealTypeChanged;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool showMoreNutrients;
  final VoidCallback onToggleMoreNutrients;
  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;
  final String? photoPath;
  final ValueChanged<ImageSource> onPickPhoto;
  final VoidCallback onRemovePhoto;
  final bool isEditMode;

  const _ManualEntryTab({
    required this.formKey,
    required this.nameController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.fiberController,
    required this.sugarController,
    required this.sodiumController,
    required this.vitaminDController,
    required this.ironController,
    required this.calciumController,
    required this.notesController,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.isSubmitting,
    required this.onSubmit,
    required this.showMoreNutrients,
    required this.onToggleMoreNutrients,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    required this.photoPath,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Photo / Emoji section
          _PhotoEmojiSection(
            photoPath: photoPath,
            selectedEmoji: selectedEmoji,
            onPickPhoto: onPickPhoto,
            onRemovePhoto: onRemovePhoto,
            onEmojiSelected: onEmojiSelected,
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          // Meal type selector
          _MealTypeSelector(
            selectedMealType: selectedMealType,
            onMealTypeChanged: onMealTypeChanged,
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 24),

          // Food name (optional)
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Food Name (optional)',
              prefixIcon: Icon(PhosphorIcons.fork_knife),
            ),
            textCapitalization: TextCapitalization.sentences,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05),
          const SizedBox(height: 16),

          // Calories
          TextFormField(
            controller: caloriesController,
            decoration: InputDecoration(
              labelText: 'Calories',
              prefixIcon: Icon(PhosphorIcons.fire, color: AppTheme.caloriesColor),
              suffixText: 'kcal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter calories';
              }
              return null;
            },
          ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.05),
          const SizedBox(height: 16),

          // Protein
          TextFormField(
            controller: proteinController,
            decoration: InputDecoration(
              labelText: 'Protein',
              prefixIcon: Icon(PhosphorIcons.barbell, color: AppTheme.proteinColor),
              suffixText: 'g',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter protein';
              }
              return null;
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
          const SizedBox(height: 16),

          // Carbs
          TextFormField(
            controller: carbsController,
            decoration: InputDecoration(
              labelText: 'Carbs',
              prefixIcon: Icon(Icons.grain, color: AppTheme.carbsColor),
              suffixText: 'g',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter carbs';
              }
              return null;
            },
          ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05),
          const SizedBox(height: 16),

          // Fat
          TextFormField(
            controller: fatController,
            decoration: InputDecoration(
              labelText: 'Fat',
              prefixIcon: Icon(PhosphorIcons.drop, color: AppTheme.fatColor),
              suffixText: 'g',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter fat';
              }
              return null;
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05),
          const SizedBox(height: 16),

          // More Nutrients expandable
          GlassCard(
            onTap: onToggleMoreNutrients,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  showMoreNutrients
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
          ).animate().fadeIn(delay: 320.ms),

          if (showMoreNutrients) ...[
            const SizedBox(height: 16),
            _buildOptionalField(context, fiberController, 'Fiber', 'g'),
            const SizedBox(height: 12),
            _buildOptionalField(context, sugarController, 'Sugar', 'g'),
            const SizedBox(height: 12),
            _buildOptionalField(context, sodiumController, 'Sodium', 'mg'),
            const SizedBox(height: 12),
            _buildOptionalField(context, vitaminDController, 'Vitamin D', 'mcg'),
            const SizedBox(height: 12),
            _buildOptionalField(context, ironController, 'Iron', 'mg'),
            const SizedBox(height: 12),
            _buildOptionalField(context, calciumController, 'Calcium', 'mg'),
          ],

          const SizedBox(height: 16),

          // Notes field
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(PhosphorIcons.note),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ).animate().fadeIn(delay: 340.ms).slideX(begin: 0.05),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.background,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditMode ? PhosphorIcons.check : PhosphorIcons.plus),
                        const SizedBox(width: 8),
                        Text(isEditMode ? 'Update Entry' : 'Add Entry'),
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildOptionalField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String unit,
  ) {
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
}

class _PhotoEmojiSection extends StatefulWidget {
  final String? photoPath;
  final String? selectedEmoji;
  final ValueChanged<ImageSource> onPickPhoto;
  final VoidCallback onRemovePhoto;
  final ValueChanged<String> onEmojiSelected;

  const _PhotoEmojiSection({
    required this.photoPath,
    required this.selectedEmoji,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.onEmojiSelected,
  });

  @override
  State<_PhotoEmojiSection> createState() => _PhotoEmojiSectionState();
}

class _PhotoEmojiSectionState extends State<_PhotoEmojiSection> {
  bool _showEmojiGrid = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo preview or emoji display
          if (widget.photoPath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.photoPath!),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onRemovePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(PhosphorIcons.x, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            )
          else if (widget.selectedEmoji != null)
            Center(
              child: Text(
                widget.selectedEmoji!,
                style: const TextStyle(fontSize: 48),
              ),
            ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onPickPhoto(ImageSource.camera),
                  icon: const Icon(PhosphorIcons.camera, size: 18),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onPickPhoto(ImageSource.gallery),
                  icon: const Icon(PhosphorIcons.image, size: 18),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _showEmojiGrid = !_showEmojiGrid);
                  },
                  icon: const Icon(PhosphorIcons.smiley, size: 18),
                  label: const Text('Emoji'),
                ),
              ),
            ],
          ),

          // Emoji grid
          if (_showEmojiGrid) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _foodEmojis.map((emoji) {
                final isSelected = emoji == widget.selectedEmoji;
                return GestureDetector(
                  onTap: () {
                    widget.onEmojiSelected(emoji);
                    setState(() => _showEmojiGrid = false);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.neonGreen.withOpacity(0.2)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppTheme.neonGreen)
                          : null,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealTypeSelector extends StatelessWidget {
  final MealType selectedMealType;
  final ValueChanged<MealType> onMealTypeChanged;

  const _MealTypeSelector({
    required this.selectedMealType,
    required this.onMealTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: MealType.values.map((type) {
          final isSelected = type == selectedMealType;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onMealTypeChanged(type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.neonGreen.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.neonGreen : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }
}
