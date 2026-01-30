import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/user_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final availableModels = ref.watch(availableModelsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // AI Model Section
          _SectionHeader(
            title: 'AI Model',
            icon: PhosphorIcons.robot,
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          _AIModelSelector(
            selectedModel: settings.selectedModel,
            availableModels: availableModels,
            onModelChanged: (model) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).updateSelectedModel(model);
            },
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05),

          const SizedBox(height: 32),

          // Macro Targets Section
          _SectionHeader(
            title: 'Daily Targets',
            icon: PhosphorIcons.target,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          _MacroTargetCard(
            label: 'Calories',
            value: settings.calorieTarget,
            unit: 'kcal',
            color: AppTheme.caloriesColor,
            icon: PhosphorIcons.fire,
            min: 1000,
            max: 5000,
            step: 50,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateCalorieTarget(value);
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
          const SizedBox(height: 12),
          _MacroTargetCard(
            label: 'Protein',
            value: settings.proteinTarget,
            unit: 'g',
            color: AppTheme.proteinColor,
            icon: PhosphorIcons.barbell,
            min: 50,
            max: 300,
            step: 5,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateProteinTarget(value);
            },
          ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05),
          const SizedBox(height: 12),
          _MacroTargetCard(
            label: 'Carbs',
            value: settings.carbsTarget,
            unit: 'g',
            color: AppTheme.carbsColor,
            icon: Icons.grain,
            min: 50,
            max: 500,
            step: 10,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateCarbsTarget(value);
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05),
          const SizedBox(height: 12),
          _MacroTargetCard(
            label: 'Fat',
            value: settings.fatTarget,
            unit: 'g',
            color: AppTheme.fatColor,
            icon: PhosphorIcons.drop,
            min: 20,
            max: 200,
            step: 5,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateFatTarget(value);
            },
          ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.05),

          const SizedBox(height: 32),

          // Appearance Section
          _SectionHeader(
            title: 'Appearance',
            icon: PhosphorIcons.palette,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          _AccentColorSelector(
            selectedColor: settings.accentColor,
            onColorChanged: (color) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).updateAccentColor(color);
            },
          ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.05),

          const SizedBox(height: 32),

          // Preferences Section
          _SectionHeader(
            title: 'Preferences',
            icon: PhosphorIcons.sliders,
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          _SettingsToggle(
            title: 'Haptic Feedback',
            subtitle: 'Vibration on actions',
            icon: PhosphorIcons.vibrate,
            value: settings.hapticFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateHapticFeedback(value);
            },
          ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.05),
          const SizedBox(height: 12),
          _SettingsToggle(
            title: 'Show AI Confidence',
            subtitle: 'Display confidence level on AI scans',
            icon: PhosphorIcons.chart_line,
            value: settings.showConfidence,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateShowConfidence(value);
            },
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),
          const SizedBox(height: 12),
          _SettingsToggle(
            title: 'Notifications',
            subtitle: 'Meal logging reminders',
            icon: PhosphorIcons.bell,
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateNotifications(value);
            },
          ).animate().fadeIn(delay: 650.ms).slideX(begin: 0.05),

          const SizedBox(height: 32),

          // About Section
          _SectionHeader(
            title: 'About',
            icon: PhosphorIcons.info,
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    AppConstants.logoPath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aahar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI-powered nutrition tracking\nwith gym-bro energy 💪',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 750.ms).slideX(begin: 0.05),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.neonGreen,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _AIModelSelector extends StatelessWidget {
  final GeminiModel selectedModel;
  final List<GeminiModel> availableModels;
  final ValueChanged<GeminiModel> onModelChanged;

  const _AIModelSelector({
    required this.selectedModel,
    required this.availableModels,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  PhosphorIcons.brain,
                  color: AppTheme.neonPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini Model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Select AI model for food analysis',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...availableModels.map((model) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModelOption(
                  model: model,
                  isSelected: model == selectedModel,
                  onTap: () => onModelChanged(model),
                ),
              )),
        ],
      ),
    );
  }
}

class _ModelOption extends StatelessWidget {
  final GeminiModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelOption({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonGreen.withOpacity(0.1)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.neonGreen
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.neonGreen
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.neonGreen
                      : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      PhosphorIcons.check,
                      size: 14,
                      color: AppTheme.background,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.neonGreen
                              : AppTheme.textPrimary,
                        ),
                  ),
                  Text(
                    model.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            if (model == GeminiModel.flash)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Fast',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.neonBlue,
                      ),
                ),
              ),
            if (model == GeminiModel.pro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Accurate',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.neonPurple,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MacroTargetCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;
  final IconData icon;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _MacroTargetCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '$value $unit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) ~/ step,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v.round());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$min',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              Text(
                '$max',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccentColorSelector extends StatelessWidget {
  final AccentColor selectedColor;
  final ValueChanged<AccentColor> onColorChanged;

  const _AccentColorSelector({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AccentColor.values.map((color) {
              final isSelected = color == selectedColor;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(color.colorValue),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(color.colorValue).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          PhosphorIcons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
