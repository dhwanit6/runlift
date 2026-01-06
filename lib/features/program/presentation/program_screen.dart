import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../data/training_provider.dart';
import '../../../domain/models/training_program.dart';

class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

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
                  '4-WEEK',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PROGRAM',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '3 run days + 4 active recovery days per week',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // Week Cards
                ..._buildProgramWeeks(context, trainingState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgramWeeks(BuildContext context, TrainingState trainingState) {
    final program = trainingState.program;
    final currentDay = trainingState.currentDay;

    return program.weeks.map((week) {
      final isActive = week.weekNumber == ((currentDay - 1) ~/ 7 + 1);
      final completedDays = trainingState.completedDays.where((d) => (d - 1) ~/ 7 + 1 == week.weekNumber).length;

      
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _buildWeekCard(
          context,
          week.weekNumber,
          week.name,
          isActive,
          completedDays,
          week.days.map((d) => d.workout.name).toList(),
          week,
          trainingState,
        ),
      );
    }).toList();
  }

  Widget _buildWeekCard(
    BuildContext context, 
    int weekNum, 
    String title, 
    bool isActive, 
    int completedDays, 
    List<String> days,
    TrainingWeek weekData,
    TrainingState trainingState,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: isActive ? 0.12 : 0.06,
      border: Border.all(
        color: isActive ? AppTheme.primary : Colors.white.withAlphaValue(0.08),
        width: isActive ? 2 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : Colors.white.withAlphaValue(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$weekNum',
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white54,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
                      'WEEK $weekNum • ${weekData.totalDistanceKm} KM',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        color: isActive ? AppTheme.primary : Colors.white54,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: isActive ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isActive && weekNum > (trainingState.currentDay - 1) ~/ 7 + 1)
                const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 22),
              if (isActive || weekNum <= (trainingState.currentDay - 1) ~/ 7 + 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: completedDays == 7 ? AppTheme.success : AppTheme.primary.withAlphaValue(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedDays/7',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            weekData.focus,
            style: TextStyle(
              color: isActive ? Colors.white54 : Colors.white24,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final dayNum = (weekNum - 1) * 7 + index + 1;
              final dayData = weekData.days[index];
              final isCompleted = trainingState.completedDays.contains(dayNum);
              final isToday = trainingState.currentDay == dayNum;
              final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final isRunDay = dayData.workout.type == WorkoutType.run;

              return GestureDetector(
                onTap: () => _showMissionBriefing(context, dayData, dayNum),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isRunDay ? AppTheme.primary : AppTheme.success)
                        : isToday
                            ? AppTheme.primary.withAlphaValue(0.2)
                            : Colors.white.withAlphaValue(isActive ? 0.06 : 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: AppTheme.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[index],
                        style: TextStyle(
                          color: isCompleted ? Colors.black : (isActive ? Colors.white70 : Colors.white30),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : (isRunDay ? Icons.directions_run_rounded : 
                               dayData.workout.type == WorkoutType.rest ? Icons.nightlight_round : 
                               Icons.self_improvement_rounded),
                        size: 16,
                        color: isCompleted ? Colors.black : (isActive ? Colors.white.withAlphaValue(0.4) : Colors.white.withAlphaValue(0.2)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMissionBriefing(BuildContext context, TrainingDay dayData, int dayNum) {
    final workout = dayData.workout;
    final isRun = workout.type == WorkoutType.run;
    final isRest = workout.type == WorkoutType.rest;
    final color = isRun ? AppTheme.primary : (isRest ? AppTheme.success : AppTheme.secondary);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: color.withAlphaValue(0.5))),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withAlphaValue(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withAlphaValue(0.3)),
                          ),
                          child: Text(
                            'DAY $dayNum INTELLIGENCE',
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (isRest)
                          const Icon(Icons.nightlight_round, color: AppTheme.success)
                        else
                          Icon(isRun ? Icons.directions_run : Icons.fitness_center, color: color),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      workout.name.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.description,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    Row(
                      children: [
                        _buildBriefingStat(
                          context, 
                          Icons.timer_outlined, 
                          '${workout.estimatedDuration.inMinutes} MIN', 
                          'DURATION',
                        ),
                        const SizedBox(width: 24),
                        _buildBriefingStat(
                          context, 
                          isRun ? Icons.speed : Icons.monitor_weight_outlined, 
                          isRun ? 'N/A' : '${workout.targetRpe}/10', 
                          isRun ? 'PACE' : 'INTENSITY',
                        ),
                        const SizedBox(width: 24),
                        _buildBriefingStat(
                          context, 
                          Icons.backpack_outlined, 
                          isRun ? 'SHOES' : 'GYM', 
                          'GEAR',
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlphaValue(0.1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('DISMISS BRIEFING'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBriefingStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
