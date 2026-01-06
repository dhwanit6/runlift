import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../domain/models/training_program.dart';
import '../../../data/training_provider.dart';
import '../../../data/active_workout_provider.dart';
import '../../../shared/widgets/skeleton_loading.dart';
import '../../../core/constants/app_strings.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final theme = Theme.of(context);
    
    if (trainingState.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: AtmosphericBackground(
          child: SafeArea(
            child: TodayScreenSkeleton(),
          ),
        ),
      );
    }
    
    final today = trainingState.today;
    final workout = today.workout;
    final progress = trainingState.currentDay / 28;

    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Editorial Hierarchy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAY ${trainingState.currentDay}'.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primary,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TODAY',
                            style: theme.textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    _buildProgressRing(progress),
                  ],
                ),
                
                const SizedBox(height: 40),

                // Injury Warning
                if (today.injuryNote != null) ...[
                  _buildInjuryWarning(context, today.injuryNote!),
                  const SizedBox(height: 24),
                ],
                
                // Main workout card - Bento Centerpiece
                if (!today.isRestDay)
                  _buildWorkoutCard(context, ref, today, workout)
                else
                  _buildRestDayCard(context, ref),
                
                const SizedBox(height: 24),
                
                // Weekly Overview - Bento Support
                _buildWeekProgress(context, trainingState),
                
                const SizedBox(height: 24),
                
                // Global Stats - Bento HUD
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${trainingState.completedDays.length}',
                        'COMPLETED',
                        Icons.check_rounded,
                        AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${28 - trainingState.completedDays.length}',
                        'REMAINING',
                        Icons.timer_outlined,
                        AppTheme.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Secondary Action - Skip
                if (trainingState.currentDay < 28)
                  Center(
                    child: TextButton(
                      onPressed: () => _showSkipConfirmation(context, ref),
                      child: Text(
                        AppStrings.skipToday.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(double progress) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(20), width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withAlpha(10),
                  color: AppTheme.primary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PROGRESS',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTag(WorkoutType type) {
    final isRun = type == WorkoutType.run;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isRun ? AppTheme.primary : Colors.purple).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isRun ? AppTheme.primary : Colors.purple).withAlpha(60),
          width: 1,
        ),
      ),
      child: Text(
        isRun ? 'RUN' : 'STRENGTH',
        style: TextStyle(
          color: isRun ? AppTheme.primary : Colors.purpleAccent,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WidgetRef ref, TrainingDay today, Workout workout) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final isThisWorkoutActive = activeWorkout.workout?.id == workout.id;
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeTag(workout.type),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.estimatedDuration.inMinutes} MIN',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            workout.name,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            workout.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          PremiumButton(
            label: isThisWorkoutActive ? 'RESUME WORKOUT' : 'START WORKOUT',
            icon: isThisWorkoutActive ? Icons.play_arrow_rounded : Icons.flash_on_rounded,
            onPressed: () => context.push('/workout/${workout.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'REST DAY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Active recovery is essential for progress. Focus on mobility and hydration.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRecoveryItem(Icons.water_drop_rounded, 'Hydrate'),
              _buildRecoveryItem(Icons.bedtime_rounded, 'Sleep'),
              _buildRecoveryItem(Icons.restaurant_rounded, 'Fuel'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              label: 'SKIP REST',
              isSecondary: true,
              onPressed: () => _showSkipConfirmation(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.withAlpha(150), size: 24),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekProgress(BuildContext context, TrainingState state) {
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final currentWeekStart = ((state.currentDay - 1) ~/ 7) * 7 + 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'WEEK ${((state.currentDay - 1) ~/ 7) + 1} PROGRESS'.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNum = currentWeekStart + index;
            final isCompleted = state.completedDays.contains(dayNum);
            final isToday = dayNum == state.currentDay;
            
            return _buildDayIndicator(weekDays[index], isCompleted, isToday);
          }),
        ),
      ],
    );
  }

  Widget _buildDayIndicator(String label, bool isCompleted, bool isToday) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isToday ? AppTheme.primary : Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isToday 
                ? AppTheme.primary.withAlpha(40)
                : isCompleted 
                    ? AppTheme.success.withAlpha(30)
                    : Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(14),
            border: isToday 
                ? Border.all(color: AppTheme.primary, width: 2)
                : Border.all(color: Colors.white.withAlpha(10), width: 1),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check_rounded, color: AppTheme.success, size: 20)
                : isToday
                  ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle))
                  : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryWarning(BuildContext context, String note) {
    return GlassCard(
      backgroundColor: Colors.orange.withAlpha(15),
      border: Border.all(color: Colors.orange.withAlpha(40), width: 1),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INJURY PROTOCOL',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSkipConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Skip Protocol?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          AppStrings.skipConfirmation,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(trainingProvider.notifier).skipDay();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withAlpha(50),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('SKIP', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
