import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../domain/models/training_program.dart';
import '../../../data/training_provider.dart';
import '../../../domain/models/injury.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    
    // Show loading state while data is being fetched
    if (trainingState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    
    final injuryService = ref.watch(injuryServiceProvider);
    final today = trainingState.today;
    final prediction = injuryService.getPrediction(today.dayNumber);
    final workout = today.workout;

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
                  'WEEK ${today.weekNumber} • DAY ${today.dayNumber}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  today.isRestDay ? 'REST & RECOVER' : workout.name,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 36,
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  today.motivationBefore,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                if (prediction.expectedDiscomforts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildInjuryAlert(context, prediction),
                ],

                const SizedBox(height: 32),

                // Today's Workout Card
                if (!today.isRestDay)
                  _buildWorkoutCard(context, today, workout)
                else
                  _buildRestCard(context, today),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, '${trainingState.completedDays.length}', 'TOTAL DAYS', Icons.local_fire_department_rounded, AppTheme.secondary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, '${trainingState.completedDays.where((d) => (d-1)~/7 + 1 == today.weekNumber).length}/7', 'THIS WEEK', Icons.calendar_today_rounded, AppTheme.primary)),
                  ],
                ),

                const SizedBox(height: 24),

                // Weekly Overview
                Text(
                  'WEEKLY PROGRESS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final dayNum = (today.weekNumber - 1) * 7 + index + 1;
                      final isCompleted = trainingState.completedDays.contains(dayNum);
                      final dayData = trainingState.program.getDay(dayNum);
                      final isRunDay = dayData?.workout.type == WorkoutType.run;
                      final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      
                      return _buildDayPill(context, dayNames[index], isCompleted, isRunDay);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInjuryAlert(BuildContext context, InjuryPrediction prediction) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.15,
      border: Border.all(color: Colors.orange.withAlphaValue(0.3)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BODY CHECK: ${prediction.expectedDiscomforts.first.symptom}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  prediction.expectedDiscomforts.first.reassuranceMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, TrainingDay today, Workout workout) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      opacity: 0.12,
      border: Border.all(color: AppTheme.primary.withAlphaValue(0.3), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: workout.type == WorkoutType.run ? AppTheme.primary : AppTheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  workout.type.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlphaValue(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer_rounded, color: AppTheme.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            workout.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            workout.description,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (workout.type == WorkoutType.run)
            _buildRunIntervalsSummary(context, workout)
          else if (workout.exercises != null)
            _buildStrengthSummary(context, workout),
          const SizedBox(height: 24),
          _buildDurationBar(context, workout),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/workout/${workout.id}'),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text('START WORKOUT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestCard(BuildContext context, TrainingDay today) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(Icons.nightlight_round, color: AppTheme.secondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'REST DAY',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            today.workout.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildRunIntervalsSummary(BuildContext context, Workout workout) {
    if (workout.intervals == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        _buildInfoChip(context, '${workout.intervals![0].duration.inMinutes} min', 'RUN'),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 16),
        const SizedBox(width: 8),
        _buildInfoChip(context, '${workout.intervals![1].duration.inMinutes} min', 'WALK'),
        const SizedBox(width: 8),
        const Icon(Icons.close_rounded, color: Colors.white24, size: 16),
        const SizedBox(width: 8),
        _buildInfoChip(context, '${workout.intervalRepeats ?? 1}', 'ROUNDS'),
      ],
    );
  }

  Widget _buildStrengthSummary(BuildContext context, Workout workout) {
    return Row(
      children: [
        _buildInfoChip(context, '${workout.exercises?.length}', 'EXERCISES'),
        const SizedBox(width: 8),
        _buildInfoChip(context, '${workout.circuitRounds}', 'ROUNDS'),
        const SizedBox(width: 8),
        _buildInfoChip(context, '${workout.targetRpe}', 'RPE'),
      ],
    );
  }

  Widget _buildDurationBar(BuildContext context, Workout workout) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlphaValue(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Duration',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
          Text(
            '${workout.estimatedDuration.inMinutes} minutes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlphaValue(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
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

  Widget _buildDayPill(BuildContext context, String day, bool isCompleted, bool isRunDay) {
    return Container(
      width: 38,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted
            ? (isRunDay ? AppTheme.primary : AppTheme.success)
            : Colors.white.withAlphaValue(0.06),
        borderRadius: BorderRadius.circular(12),
        border: isRunDay && !isCompleted
            ? Border.all(color: AppTheme.primary.withAlphaValue(0.4), width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isCompleted ? Colors.black : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            isCompleted
                ? Icons.check_rounded
                : (isRunDay ? Icons.directions_run_rounded : Icons.self_improvement_rounded),
            size: 14,
            color: isCompleted ? Colors.black : Colors.white30,
          ),
        ],
      ),
    );
  }
}
