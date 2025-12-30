import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../data/training_provider.dart';
import '../../../domain/models/training_program.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    
    // Show loading state
    if (trainingState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    
    // Use safe getters from TrainingState
    final completedDaysCount = trainingState.completedDays.length;
    final totalDays = trainingState.program.totalDays;
    final progressFactor = trainingState.completionPercentage;
    final totalKm = trainingState.totalDistanceKm;

    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'YOUR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PROGRESS',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 40,
                  ),
                ),

                const SizedBox(height: 40),

                // Hero Stat
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  opacity: 0.12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(progressFactor * 100).toInt()}%',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 56,
                                color: AppTheme.primary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'TOTAL PROGRAM COMPLETION',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 11,
                                letterSpacing: 2,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progressFactor,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white.withAlphaValue(0.1),
                              color: AppTheme.primary,
                            ),
                            Text(
                              '$completedDaysCount/$totalDays',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Grid
                Row(
                  children: [
                    Expanded(child: _buildStatTile(context, '$completedDaysCount', 'COMPLETED', Icons.fitness_center_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatTile(context, '${totalKm.toStringAsFixed(1)}', 'DISTANCE KM', Icons.trending_up_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatTile(context, '${trainingState.program.weeks.length}', 'WEEKS', Icons.calendar_today_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatTile(context, completedDaysCount >= 1 ? '${trainingState.completedDays.where((d) => (d-1)~/7 == 0).length}' : '0', 'W1 STREAK', Icons.local_fire_department_rounded)),
                  ],
                ),

                const SizedBox(height: 40),

                // Weekly Consistency
                Text(
                  'CONSISTENCY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: List.generate(4, (index) {
                      final weekNum = index + 1;
                      final completedInWeek = trainingState.completedDays.where((d) => (d - 1) ~/ 7 == index).length;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == 3 ? 0 : 16),
                        child: _buildWeekBar(context, 'W$weekNum', completedInWeek, 7),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 40),

                // Milestones
                Text(
                  'MILESTONES',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                _buildMilestone(context, 'First steps', 'Completed your first workout', completedDaysCount >= 1, Icons.flag_rounded),
                const SizedBox(height: 10),
                _buildMilestone(context, 'Consistent', 'Finished 3 days in a row', completedDaysCount >= 3, Icons.local_fire_department_rounded),
                const SizedBox(height: 10),
                _buildMilestone(context, 'Week 1 Survivor', 'Finished all Week 1 workouts', completedDaysCount >= 7, Icons.calendar_today_rounded),
                const SizedBox(height: 10),
                _buildMilestone(context, 'Halfway there', 'Completed 14 days of training', completedDaysCount >= 14, Icons.timer_rounded),
                const SizedBox(height: 10),
                _buildMilestone(context, '5K Finisher', 'Complete the 5K test run', completedDaysCount >= 26, Icons.emoji_events_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildStatTile(BuildContext context, String value, String label, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 32,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlphaValue(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBar(BuildContext context, String week, int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            week,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withAlphaValue(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: completed == total ? AppTheme.success : AppTheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            '$completed/$total',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: completed == total ? AppTheme.success : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestone(BuildContext context, String title, String description, bool isUnlocked, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      opacity: isUnlocked ? 0.1 : 0.04,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? AppTheme.primary : Colors.white.withAlphaValue(0.08),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.black : Colors.white30,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked ? Colors.white54 : Colors.white.withAlphaValue(0.2),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
        ],
      ),
    );
  }
}
