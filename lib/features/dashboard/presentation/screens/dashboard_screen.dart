import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/motivation_engine.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../food_entry/domain/entities/food_log.dart';
import '../../../food_entry/presentation/providers/food_log_provider.dart';
import '../../../food_entry/presentation/screens/food_entry_screen.dart';
import '../../../streaks/presentation/providers/streak_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dailyStatsProvider);
    final streak = ref.watch(streakProvider);
    final motivation = ref.watch(motivationMessageProvider);
    final greeting = ref.watch(greetingProvider);
    final todaysLogs = ref.watch(todaysFoodLogsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Streak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ).animate().fadeIn(duration: 400.ms).slideX(
                                  begin: -0.1,
                                  curve: Curves.easeOut,
                                ),
                            const SizedBox(height: 4),
                            Text(
                              'Track your gains today',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          ],
                        ),
                        // Streak badge
                        _StreakBadge(streak: streak.currentStreak)
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Motivation card
                    _MotivationCard(message: motivation)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOut),
                  ],
                ),
              ),
            ),

            // Main macro ring
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _CalorieRing(
                  calories: stats.calories,
                  target: stats.calorieTarget,
                  remaining: stats.caloriesRemaining,
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      curve: Curves.easeOut,
                    ),
              ),
            ),

            // Macro cards grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  MacroCard(
                    label: 'Protein',
                    value: stats.protein.toStringAsFixed(0),
                    unit: 'g',
                    color: AppTheme.proteinColor,
                    icon: PhosphorIcons.barbell,
                    progress: stats.proteinProgress,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  MacroCard(
                    label: 'Carbs',
                    value: stats.carbs.toStringAsFixed(0),
                    unit: 'g',
                    color: AppTheme.carbsColor,
                    icon: Icons.grain,
                    progress: stats.carbsProgress,
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2),
                  MacroCard(
                    label: 'Fat',
                    value: stats.fat.toStringAsFixed(0),
                    unit: 'g',
                    color: AppTheme.fatColor,
                    icon: PhosphorIcons.drop,
                    progress: stats.fatProgress,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  MacroCard(
                    label: 'Logged',
                    value: stats.logCount.toString(),
                    unit: 'meals',
                    color: AppTheme.neonGreen,
                    icon: PhosphorIcons.note_pencil,
                    progress: stats.logCount / 4, // Assume 4 meals target
                  ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),
                ]),
              ),
            ),

            // Today's logs section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Log",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to full log
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ),
            ),

            // Food log list
            if (todaysLogs.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyLogCard().animate().fadeIn(delay: 750.ms),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = todaysLogs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(log.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              PhosphorIcons.trash,
                              color: AppTheme.error,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.surface,
                                title: const Text('Delete Entry'),
                                content: Text(
                                  'Delete "${log.name ?? log.mealType.label}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppTheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) {
                            ref
                                .read(todaysFoodLogsProvider.notifier)
                                .deleteFoodLog(log.id);
                          },
                          child: _FoodLogTile(
                            log: log,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FoodEntryScreen(existingLog: log),
                                ),
                              );
                            },
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (750 + index * 50).ms)
                            .slideX(begin: 0.05),
                      );
                    },
                    childCount: todaysLogs.length.clamp(0, 5),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonOrange.withOpacity(0.2),
            AppTheme.neonOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neonOrange.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neonOrange,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final MotivationMessage message;

  const _MotivationCard({required this.message});

  Color get _backgroundColor {
    switch (message.type) {
      case MessageType.celebration:
        return AppTheme.neonGreen.withOpacity(0.15);
      case MessageType.praise:
        return AppTheme.neonBlue.withOpacity(0.15);
      case MessageType.warning:
        return AppTheme.warning.withOpacity(0.15);
      case MessageType.encouragement:
        return AppTheme.neonPurple.withOpacity(0.15);
      case MessageType.neutral:
        return AppTheme.surfaceLight;
    }
  }

  Color get _borderColor {
    switch (message.type) {
      case MessageType.celebration:
        return AppTheme.neonGreen.withOpacity(0.5);
      case MessageType.praise:
        return AppTheme.neonBlue.withOpacity(0.5);
      case MessageType.warning:
        return AppTheme.warning.withOpacity(0.5);
      case MessageType.encouragement:
        return AppTheme.neonPurple.withOpacity(0.5);
      case MessageType.neutral:
        return Colors.white.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        message.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.4,
            ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  final int calories;
  final int target;
  final int remaining;

  const _CalorieRing({
    required this.calories,
    required this.target,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? calories / target : 0.0;
    final isOverTarget = calories > target;

    return Center(
      child: ProgressRing(
        progress: progress,
        size: 200,
        strokeWidth: 14,
        color: isOverTarget ? AppTheme.warning : AppTheme.caloriesColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$calories',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isOverTarget ? AppTheme.warning : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'of $target cal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOverTarget
                    ? AppTheme.warning.withOpacity(0.2)
                    : AppTheme.neonGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOverTarget ? '+${calories - target} over' : '$remaining left',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isOverTarget ? AppTheme.warning : AppTheme.neonGreen,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLogCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No meals logged yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your nutrition!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodLogTile extends StatelessWidget {
  final FoodLog log;
  final VoidCallback? onTap;

  const _FoodLogTile({required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Row(
        children: [
          // Meal type emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                log.mealType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.name ?? log.mealType.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MacroChip(
                      value: '${log.calories}',
                      label: 'cal',
                      color: AppTheme.caloriesColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.protein.toStringAsFixed(0)}g',
                      label: 'P',
                      color: AppTheme.proteinColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.carbs.toStringAsFixed(0)}g',
                      label: 'C',
                      color: AppTheme.carbsColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.fat.toStringAsFixed(0)}g',
                      label: 'F',
                      color: AppTheme.fatColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Source indicator
          if (log.source == FoodLogSource.aiScan)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                PhosphorIcons.robot,
                color: AppTheme.neonPurple,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MacroChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
