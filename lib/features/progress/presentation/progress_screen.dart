import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../data/training_provider.dart';
import '../../../data/stats_service.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final lifetimeStatsAsync = ref.watch(lifetimeStatsProvider);
    
    if (trainingState.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    
    final completedDaysCount = trainingState.completedDays.length;

    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: completedDaysCount == 0
              ? _buildEmptyState(context)
              : _buildProgressView(context, trainingState, lifetimeStatsAsync),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined, 
                size: 64, 
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Progress Awaits',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete your first workout to start\ntracking your journey to 5K.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: Colors.white54, 
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: AppTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Head to TODAY to begin',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView(
    BuildContext context, 
    TrainingState trainingState,
    AsyncValue<Map<String, dynamic>> lifetimeStatsAsync,
  ) {
    final progress = trainingState.currentDay / 28;
    final completedCount = trainingState.completedDays.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'YOUR',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PROGRESS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Main Progress Card
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.white12,
                              color: AppTheme.primary,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JOURNEY TO 5K',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Day ${trainingState.currentDay} of 28',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedCount workouts completed',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Row
          lifetimeStatsAsync.when(
            data: (stats) {
              final km = ((stats['km'] as num? ?? 0.0).toDouble()).toStringAsFixed(1);
              final streak = (stats['streak'] as num? ?? 0).toString();
              
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      km,
                      'KM TOTAL',
                      Icons.straighten,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      streak,
                      'DAY STREAK',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 32),
          
          // Week by Week Breakdown
          const Text(
            'WEEKLY BREAKDOWN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildWeekCard(context, 1, 'FOUNDATION', trainingState, 1, 7),
          const SizedBox(height: 12),
          _buildWeekCard(context, 2, 'BUILD UP', trainingState, 8, 14),
          const SizedBox(height: 12),
          _buildWeekCard(context, 3, 'BREAKTHROUGH', trainingState, 15, 21),
          const SizedBox(height: 12),
          _buildWeekCard(context, 4, '5K PUSH', trainingState, 22, 28),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(
    BuildContext context,
    int weekNum,
    String name,
    TrainingState state,
    int startDay,
    int endDay,
  ) {
    final completedInWeek = state.completedDays
        .where((d) => d >= startDay && d <= endDay)
        .length;
    final isCurrentWeek = state.currentDay >= startDay && state.currentDay <= endDay;
    final isCompleted = completedInWeek == 7;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withAlpha(30)
                  : isCurrentWeek 
                      ? AppTheme.primary.withAlpha(30)
                      : Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : Text(
                      'W$weekNum',
                      style: TextStyle(
                        color: isCurrentWeek ? AppTheme.primary : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK $weekNum: $name',
                  style: TextStyle(
                    color: isCurrentWeek ? AppTheme.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedInWeek/7 days completed',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: completedInWeek / 7,
              strokeWidth: 4,
              backgroundColor: Colors.white12,
              color: isCompleted ? Colors.green : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
