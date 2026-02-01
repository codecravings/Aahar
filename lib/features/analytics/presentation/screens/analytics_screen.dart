import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../dashboard/domain/entities/daily_stats.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final monthlyStats = ref.watch(monthlyStatsProvider);
    final allTimeStats = ref.watch(allTimeStatsProvider);
    final settings = ref.watch(settingsProvider);

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
                child: Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            // Period selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _PeriodSelector(
                  selected: period,
                  onChanged: (p) {
                    HapticFeedback.lightImpact();
                    ref.read(analyticsPeriodProvider.notifier).state = p;
                  },
                ).animate().fadeIn(delay: 50.ms),
              ),
            ),

            // Content based on period
            if (period == AnalyticsPeriod.week) ...[
              ..._buildWeeklyView(context, weeklyStats, settings),
            ] else if (period == AnalyticsPeriod.month) ...[
              ..._buildMonthlyView(context, monthlyStats, settings),
            ] else ...[
              ..._buildAllTimeView(context, allTimeStats, settings),
            ],

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeeklyView(
    BuildContext context,
    WeeklyStats weeklyStats,
    dynamic settings,
  ) {
    return [
      // Summary cards
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Calories',
                  value: '${weeklyStats.avgCalories}',
                  unit: 'kcal',
                  icon: PhosphorIcons.fire,
                  color: AppTheme.caloriesColor,
                  target: settings.calorieTarget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Protein',
                  value: weeklyStats.avgProtein.toStringAsFixed(0),
                  unit: 'g',
                  icon: PhosphorIcons.barbell,
                  color: AppTheme.proteinColor,
                  target: settings.proteinTarget,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        ),
      ),

      // Week stats row
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Logged Days',
                  value: '${weeklyStats.loggedDays}/7',
                  color: AppTheme.neonBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  label: 'Perfect Days',
                  value: '${weeklyStats.perfectDays}',
                  color: AppTheme.neonGreen,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
        ),
      ),

      // Calorie chart
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _CalorieChart(
            dailyStats: weeklyStats.dailyStats,
            target: settings.calorieTarget,
            title: 'Calories This Week',
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ),
      ),

      // Macro breakdown
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Macro Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Average daily intake',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
        ),
      ),

      // Macro pie chart
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _MacroPieChart(
            protein: weeklyStats.avgProtein,
            carbs: weeklyStats.avgCarbs,
            fat: weeklyStats.avgFat,
          ).animate().fadeIn(delay: 300.ms).scale(
                begin: const Offset(0.9, 0.9),
                curve: Curves.easeOut,
              ),
        ),
      ),

      // Daily breakdown
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'Daily Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 350.ms),
        ),
      ),

      // Daily cards
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final stats = weeklyStats.dailyStats[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DayCard(
                  stats: stats,
                  calorieTarget: settings.calorieTarget,
                  proteinTarget: settings.proteinTarget,
                ).animate().fadeIn(delay: (400 + index * 50).ms).slideX(
                      begin: 0.05,
                    ),
              );
            },
            childCount: weeklyStats.dailyStats.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMonthlyView(
    BuildContext context,
    MonthlyStats monthlyStats,
    dynamic settings,
  ) {
    return [
      // Trend insights card
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _TrendInsightsCard(
            stats: monthlyStats,
            settings: settings,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        ),
      ),

      // Summary cards
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Calories',
                  value: '${monthlyStats.avgCalories}',
                  unit: 'kcal',
                  icon: PhosphorIcons.fire,
                  color: AppTheme.caloriesColor,
                  target: settings.calorieTarget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Protein',
                  value: monthlyStats.avgProtein.toStringAsFixed(0),
                  unit: 'g',
                  icon: PhosphorIcons.barbell,
                  color: AppTheme.proteinColor,
                  target: settings.proteinTarget,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
        ),
      ),

      // Calendar heatmap
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _CalendarHeatmap(
            dailyStats: monthlyStats.dailyStats,
            calorieTarget: settings.calorieTarget,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ),
      ),

      // Macro breakdown
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Macro Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Average daily intake (30 days)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
        ),
      ),

      // Macro pie chart
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _MacroPieChart(
            protein: monthlyStats.avgProtein,
            carbs: monthlyStats.avgCarbs,
            fat: monthlyStats.avgFat,
          ).animate().fadeIn(delay: 300.ms).scale(
                begin: const Offset(0.9, 0.9),
                curve: Curves.easeOut,
              ),
        ),
      ),
    ];
  }

  List<Widget> _buildAllTimeView(
    BuildContext context,
    AllTimeStats allTimeStats,
    dynamic settings,
  ) {
    return [
      // All-time insights
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _AllTimeInsightsCard(
            stats: allTimeStats,
            settings: settings,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        ),
      ),

      // Summary cards
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Calories',
                  value: '${allTimeStats.avgCalories}',
                  unit: 'kcal',
                  icon: PhosphorIcons.fire,
                  color: AppTheme.caloriesColor,
                  target: settings.calorieTarget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Avg Protein',
                  value: allTimeStats.avgProtein.toStringAsFixed(0),
                  unit: 'g',
                  icon: PhosphorIcons.barbell,
                  color: AppTheme.proteinColor,
                  target: settings.proteinTarget,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // Stats grid
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Total Days',
                  value: '${allTimeStats.totalLoggedDays}',
                  color: AppTheme.neonBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  label: 'Perfect Days',
                  value: '${allTimeStats.perfectDays}',
                  color: AppTheme.neonGreen,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 12)),

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Total Logs',
                  value: '${allTimeStats.totalLogs}',
                  color: AppTheme.neonPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  label: 'Consistency',
                  value: '${allTimeStats.consistencyRate.toStringAsFixed(0)}%',
                  color: AppTheme.neonOrange,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
        ),
      ),

      // Macro breakdown
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Macro Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'All-time average daily intake',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
        ),
      ),

      // Macro pie chart
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _MacroPieChart(
            protein: allTimeStats.avgProtein,
            carbs: allTimeStats.avgCarbs,
            fat: allTimeStats.avgFat,
          ).animate().fadeIn(delay: 350.ms).scale(
                begin: const Offset(0.9, 0.9),
                curve: Curves.easeOut,
              ),
        ),
      ),
    ];
  }
}

class _PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodChip(
            label: 'Week',
            isSelected: selected == AnalyticsPeriod.week,
            onTap: () => onChanged(AnalyticsPeriod.week),
          ),
          _PeriodChip(
            label: 'Month',
            isSelected: selected == AnalyticsPeriod.month,
            onTap: () => onChanged(AnalyticsPeriod.month),
          ),
          _PeriodChip(
            label: 'All Time',
            isSelected: selected == AnalyticsPeriod.allTime,
            onTap: () => onChanged(AnalyticsPeriod.allTime),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.neonGreen.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.neonGreen : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppTheme.neonGreen : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}

class _TrendInsightsCard extends StatelessWidget {
  final MonthlyStats stats;
  final dynamic settings;

  const _TrendInsightsCard({
    required this.stats,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppTheme.neonBlue.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  PhosphorIcons.trend_up,
                  color: AppTheme.neonBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Monthly Insights',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InsightRow(
            icon: PhosphorIcons.calendar_check,
            label: 'Consistency',
            value: '${stats.consistencyRate.toStringAsFixed(0)}%',
            subtext: '${stats.loggedDays} of ${stats.totalDays} days logged',
            color: stats.consistencyRate >= 80
                ? AppTheme.neonGreen
                : stats.consistencyRate >= 50
                    ? AppTheme.warning
                    : AppTheme.error,
          ),
          const Divider(color: AppTheme.surfaceLight, height: 24),
          _InsightRow(
            icon: PhosphorIcons.star,
            label: 'Perfect Days',
            value: '${stats.perfectDays}',
            subtext: 'Days hitting all targets',
            color: AppTheme.neonGreen,
          ),
          if (stats.bestProteinDay != null) ...[
            const Divider(color: AppTheme.surfaceLight, height: 24),
            _InsightRow(
              icon: PhosphorIcons.trophy,
              label: 'Best Protein Day',
              value: '${stats.bestProteinDay!.protein.toStringAsFixed(0)}g',
              subtext: DateFormat.MMMd().format(stats.bestProteinDay!.date),
              color: AppTheme.proteinColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _AllTimeInsightsCard extends StatelessWidget {
  final AllTimeStats stats;
  final dynamic settings;

  const _AllTimeInsightsCard({
    required this.stats,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppTheme.neonPurple.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  PhosphorIcons.chart_line_up,
                  color: AppTheme.neonPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'All-Time Stats',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats.firstLogDate != null) ...[
            _InsightRow(
              icon: PhosphorIcons.flag,
              label: 'Journey Started',
              value: DateFormat.yMMMd().format(stats.firstLogDate!),
              subtext: '${DateTime.now().difference(stats.firstLogDate!).inDays} days ago',
              color: AppTheme.neonBlue,
            ),
            const Divider(color: AppTheme.surfaceLight, height: 24),
          ],
          _InsightRow(
            icon: PhosphorIcons.percent,
            label: 'Consistency Rate',
            value: '${stats.consistencyRate.toStringAsFixed(0)}%',
            subtext: 'Days logged since start',
            color: stats.consistencyRate >= 80
                ? AppTheme.neonGreen
                : stats.consistencyRate >= 50
                    ? AppTheme.warning
                    : AppTheme.error,
          ),
          if (stats.bestProteinDay != null) ...[
            const Divider(color: AppTheme.surfaceLight, height: 24),
            _InsightRow(
              icon: PhosphorIcons.trophy,
              label: 'Best Protein Day',
              value: '${stats.bestProteinDay!.protein.toStringAsFixed(0)}g',
              subtext: DateFormat.MMMd().format(stats.bestProteinDay!.date),
              color: AppTheme.proteinColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtext;
  final Color color;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                subtext,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _CalendarHeatmap extends StatelessWidget {
  final List<DailyStats> dailyStats;
  final int calorieTarget;

  const _CalendarHeatmap({
    required this.dailyStats,
    required this.calorieTarget,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      );
    }

    // Create a map for quick lookup
    final statsMap = <DateTime, DailyStats>{};
    for (final stat in dailyStats) {
      final key = DateTime(stat.date.year, stat.date.month, stat.date.day);
      statsMap[key] = stat;
    }

    // Get the date range for the last 30 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heatmap',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Last 30 days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Calendar grid - 5 rows x 7 days (35 cells, showing last 30)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              // Calculate the date for this cell (starting from 34 days ago)
              final date = today.subtract(Duration(days: 34 - index));

              // Skip future dates
              if (date.isAfter(today)) {
                return const SizedBox();
              }

              final stat = statsMap[date];
              final hasData = stat != null && stat.hasLogs;
              final intensity = _getIntensity(stat, calorieTarget);

              return Tooltip(
                message: hasData
                    ? '${DateFormat.MMMd().format(date)}: ${stat.calories} cal'
                    : DateFormat.MMMd().format(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(intensity, hasData),
                    borderRadius: BorderRadius.circular(4),
                    border: DateUtils.isSameDay(date, today)
                        ? Border.all(color: AppTheme.neonGreen, width: 2)
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              const SizedBox(width: 8),
              ...[0.0, 0.25, 0.5, 0.75, 1.0].map((intensity) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(intensity, intensity > 0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
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

  double _getIntensity(DailyStats? stat, int target) {
    if (stat == null || !stat.hasLogs) return 0;
    // Intensity based on how close to target (0.5 = at target, 1 = over)
    final ratio = stat.calories / target;
    if (ratio < 0.5) return 0.25;
    if (ratio < 0.9) return 0.5;
    if (ratio <= 1.1) return 0.75;
    return 1.0;
  }

  Color _getHeatmapColor(double intensity, bool hasData) {
    if (!hasData) {
      return AppTheme.surfaceLight;
    }
    // Green shades based on intensity
    return AppTheme.neonGreen.withOpacity(0.2 + (intensity * 0.6));
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final int target;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final numValue = int.tryParse(value) ?? 0;
    final percentOfTarget = target > 0 ? (numValue / target * 100).round() : 0;

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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentOfTarget%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieChart extends StatelessWidget {
  final List<DailyStats> dailyStats;
  final int target;
  final String title;

  const _CalorieChart({
    required this.dailyStats,
    required this.target,
    this.title = 'Calories',
  });

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (target * 1.3).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.surfaceLighter,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = dailyStats[group.x.toInt()];
                      return BarTooltipItem(
                        '${day.calories} cal',
                        const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dailyStats.length) {
                          final day = dailyStats[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat.E().format(day.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: target / 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: target.toDouble(),
                      color: AppTheme.neonGreen.withOpacity(0.5),
                      strokeWidth: 2,
                      dashArray: [10, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (line) => 'Target',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.neonGreen,
                            ),
                      ),
                    ),
                  ],
                ),
                barGroups: List.generate(
                  dailyStats.length,
                  (index) {
                    final day = dailyStats[index];
                    final isOverTarget = day.calories > target;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: day.calories.toDouble(),
                          color: isOverTarget
                              ? AppTheme.warning
                              : AppTheme.caloriesColor,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroPieChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const _MacroPieChart({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total == 0) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      );
    }

    final proteinPercent = (protein / total * 100).round();
    final carbsPercent = (carbs / total * 100).round();
    final fatPercent = (fat / total * 100).round();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: protein,
                      color: AppTheme.proteinColor,
                      radius: 30,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: carbs,
                      color: AppTheme.carbsColor,
                      radius: 30,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: fat,
                      color: AppTheme.fatColor,
                      radius: 30,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: AppTheme.proteinColor,
                label: 'Protein',
                value: '${protein.toStringAsFixed(0)}g',
                percent: '$proteinPercent%',
              ),
              const SizedBox(height: 12),
              _LegendItem(
                color: AppTheme.carbsColor,
                label: 'Carbs',
                value: '${carbs.toStringAsFixed(0)}g',
                percent: '$carbsPercent%',
              ),
              const SizedBox(height: 12),
              _LegendItem(
                color: AppTheme.fatColor,
                label: 'Fat',
                value: '${fat.toStringAsFixed(0)}g',
                percent: '$fatPercent%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '$value ($percent)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DailyStats stats;
  final int calorieTarget;
  final int proteinTarget;

  const _DayCard({
    required this.stats,
    required this.calorieTarget,
    required this.proteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(stats.date, DateTime.now());
    final dayName = isToday ? 'Today' : DateFormat.EEEE().format(stats.date);
    final dateStr = DateFormat.MMMd().format(stats.date);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isToday
          ? AppTheme.neonGreen.withOpacity(0.5)
          : Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isToday
                            ? AppTheme.neonGreen
                            : AppTheme.textPrimary,
                      ),
                ),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),

          // Macros
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroValue(
                  value: '${stats.calories}',
                  label: 'cal',
                  color: stats.calories > calorieTarget
                      ? AppTheme.warning
                      : AppTheme.caloriesColor,
                ),
                _MacroValue(
                  value: stats.protein.toStringAsFixed(0),
                  label: 'P',
                  color: stats.protein >= proteinTarget
                      ? AppTheme.neonGreen
                      : AppTheme.proteinColor,
                ),
                _MacroValue(
                  value: stats.carbs.toStringAsFixed(0),
                  label: 'C',
                  color: AppTheme.carbsColor,
                ),
                _MacroValue(
                  value: stats.fat.toStringAsFixed(0),
                  label: 'F',
                  color: AppTheme.fatColor,
                ),
              ],
            ),
          ),

          // Perfect day indicator
          if (stats.isPerfectDay)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIcons.star_fill,
                color: AppTheme.neonGreen,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class _MacroValue extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MacroValue({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
        ),
      ],
    );
  }
}
