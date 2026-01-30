import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../domain/entities/streak.dart';
import '../providers/streak_provider.dart';

class StreaksScreen extends ConsumerWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final achievements = ref.watch(allAchievementsProvider);
    final heatmapData = ref.watch(heatmapDataProvider);
    final progress = ref.watch(achievementProgressProvider);

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
                  'Streaks & Achievements',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            // Stats cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: PhosphorIcons.fire,
                        label: 'Current Streak',
                        value: '${streak.currentStreak}',
                        unit: 'days',
                        color: AppTheme.neonOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: PhosphorIcons.trophy,
                        label: 'Best Streak',
                        value: '${streak.longestStreak}',
                        unit: 'days',
                        color: AppTheme.neonPurple,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              ),
            ),

            // Level & XP Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LevelCard(streak: streak)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.1),
              ),
            ),

            // Heatmap Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Heatmap',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last 90 days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _HeatmapGrid(data: heatmapData),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              ),
            ),

            // Achievements Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievements',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${progress.unlocked}/${progress.total} unlocked',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    Text(
                      '+${progress.totalXpEarned} XP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.neonGreen,
                          ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ),
            ),

            // Achievement grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = achievements[index];
                    return _AchievementCard(achievement: achievement)
                        .animate()
                        .fadeIn(delay: (450 + index * 50).ms)
                        .slideY(begin: 0.1);
                  },
                  childCount: achievements.length,
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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

class _LevelCard extends StatelessWidget {
  final UserStreak streak;

  const _LevelCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ProgressRing(
            progress: streak.levelProgress,
            size: 80,
            strokeWidth: 8,
            color: AppTheme.neonGreen,
            child: Text(
              '${streak.level}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${streak.level}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${streak.totalXp} XP total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: streak.levelProgress,
                          backgroundColor: AppTheme.surfaceLighter,
                          valueColor: const AlwaysStoppedAnimation(
                            AppTheme.neonGreen,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${streak.xpToNextLevel} XP to go',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.neonGreen,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Map<DateTime, int> data;

  const _HeatmapGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedDates = data.keys.toList()..sort();
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];

    for (final date in sortedDates.reversed) {
      currentWeek.add(date);
      if (date.weekday == DateTime.monday || currentWeek.length == 7) {
        weeks.add(currentWeek.reversed.toList());
        currentWeek = [];
      }
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek.reversed.toList());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.reversed.map((week) {
          return Column(
            children: week.map((date) {
              final count = data[date] ?? 0;
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(count),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Color _getHeatmapColor(int count) {
    if (count == 0) return AppTheme.surfaceLight;
    if (count == 1) return AppTheme.neonGreen.withOpacity(0.3);
    if (count == 2) return AppTheme.neonGreen.withOpacity(0.5);
    if (count == 3) return AppTheme.neonGreen.withOpacity(0.7);
    return AppTheme.neonGreen;
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isUnlocked
          ? AppTheme.neonGreen.withOpacity(0.5)
          : Colors.white.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 32,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isUnlocked
                      ? AppTheme.textPrimary
                      : AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isUnlocked ? '+${achievement.xpReward} XP' : achievement.description,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isUnlocked
                      ? AppTheme.neonGreen
                      : AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
