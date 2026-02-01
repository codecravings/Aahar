import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../food_entry/domain/entities/food_log.dart';
import '../../../food_entry/presentation/providers/food_log_provider.dart';
import '../../../food_entry/presentation/screens/food_entry_screen.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedHistoryDateProvider);
    final logs = ref.watch(historyLogsProvider);
    final stats = ref.watch(historyDateStatsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.calendar),
            onPressed: () => _selectDate(context, ref, selectedDate),
            tooltip: 'Pick Date',
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Week strip
          SliverToBoxAdapter(
            child: _WeekStrip(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                ref.read(selectedHistoryDateProvider.notifier).state = date;
              },
            ).animate().fadeIn(duration: 300.ms),
          ),

          // Date header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateLabel(selectedDate),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        DateFormat.yMMMd().format(selectedDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  if (logs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${logs.length} ${logs.length == 1 ? 'entry' : 'entries'}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.neonGreen,
                            ),
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 100.ms),
            ),
          ),

          // Macro summary rings
          if (logs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MacroSummary(
                  stats: stats,
                  settings: settings,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
              ),
            ),

          // Food log list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Food Log',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),

          // Food log list
          if (logs.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyHistoryCard(date: selectedDate)
                  .animate()
                  .fadeIn(delay: 250.ms),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = logs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key('history_${log.id}'),
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
                              .read(historyLogsProvider.notifier)
                              .deleteFoodLog(log.id);
                          // Also refresh dashboard providers
                          ref.read(todaysFoodLogsProvider.notifier).refresh();
                          ref.read(yesterdaysFoodLogsProvider.notifier).refresh();
                        },
                        child: _HistoryFoodLogTile(
                          log: log,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FoodEntryScreen(existingLog: log),
                              ),
                            );
                            // Refresh after editing
                            ref.read(historyLogsProvider.notifier).refresh();
                            // Also refresh dashboard providers
                            ref.read(todaysFoodLogsProvider.notifier).refresh();
                            ref.read(yesterdaysFoodLogsProvider.notifier).refresh();
                          },
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (250 + index * 50).ms)
                          .slideX(begin: 0.05),
                    );
                  },
                  childCount: logs.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat.EEEE().format(date);
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: AppTheme.background,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(selectedHistoryDateProvider.notifier).state = picked;
    }
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Show last 7 days
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dayStart = DateTime(day.year, day.month, day.day);
          final isSelected = dayStart == selected;
          final isToday = dayStart == today;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onDateSelected(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.neonGreen.withOpacity(0.2)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.neonGreen
                      : isToday
                          ? AppTheme.neonBlue.withOpacity(0.5)
                          : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(day).substring(0, 2),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.neonGreen
                              : AppTheme.textTertiary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.neonGreen
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MacroSummary extends StatelessWidget {
  final HistoryDateStats stats;
  final dynamic settings;

  const _MacroSummary({
    required this.stats,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniRing(
            value: stats.calories,
            target: settings.calorieTarget,
            label: 'cal',
            color: AppTheme.caloriesColor,
          ),
          _MiniRing(
            value: stats.protein.round(),
            target: settings.proteinTarget,
            label: 'P',
            color: AppTheme.proteinColor,
          ),
          _MiniRing(
            value: stats.carbs.round(),
            target: settings.carbsTarget,
            label: 'C',
            color: AppTheme.carbsColor,
          ),
          _MiniRing(
            value: stats.fat.round(),
            target: settings.fatTarget,
            label: 'F',
            color: AppTheme.fatColor,
          ),
        ],
      ),
    );
  }
}

class _MiniRing extends StatelessWidget {
  final int value;
  final int target;
  final String label;
  final Color color;

  const _MiniRing({
    required this.value,
    required this.target,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? value / target : 0.0;
    final isOver = value > target;

    return Column(
      children: [
        ProgressRing(
          progress: progress,
          size: 50,
          strokeWidth: 4,
          color: isOver ? AppTheme.warning : color,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOver ? AppTheme.warning : color,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isOver ? AppTheme.warning : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '/ $target',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
        ),
      ],
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  final DateTime date;

  const _EmptyHistoryCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    final isToday = selected == today;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              isToday ? 'No meals logged yet' : 'No entries for this day',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? 'Start tracking your nutrition!'
                  : 'Looks like you took a break',
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

class _HistoryFoodLogTile extends StatelessWidget {
  final FoodLog log;
  final VoidCallback? onTap;

  const _HistoryFoodLogTile({required this.log, this.onTap});

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.name ?? log.mealType.label,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat.jm().format(log.timestamp),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MacroChip(
                      value: '${log.calories}',
                      color: AppTheme.caloriesColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.protein.toStringAsFixed(0)}g P',
                      color: AppTheme.proteinColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.carbs.toStringAsFixed(0)}g C',
                      color: AppTheme.carbsColor,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      value: '${log.fat.toStringAsFixed(0)}g F',
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
  final Color color;

  const _MacroChip({
    required this.value,
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
