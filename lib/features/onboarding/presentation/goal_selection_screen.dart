import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../data/haptic_service.dart';

class GoalSelectionScreen extends ConsumerStatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  ConsumerState<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends ConsumerState<GoalSelectionScreen> {
  String? selectedGoal;

  final goals = [
    {
      'id': '5k',
      'title': 'COUCH TO 5K',
      'subtitle': 'Zero to runner in 4 weeks',
      'icon': Icons.directions_run_rounded,
      'locked': false,
    },
    {
      'id': 'elite',
      'title': 'ELITE PACE',
      'subtitle': 'Shave minutes off your PR',
      'icon': Icons.speed_rounded,
      'locked': true,
    },
    {
      'id': 'endurance',
      'title': 'ENDURANCE X',
      'subtitle': 'The path to 10K and beyond',
      'icon': Icons.terrain_rounded,
      'locked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'CHOOSE YOUR',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Center(
                  child: Text(
                    'OBJECTIVE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                
                const SizedBox(height: 40),

                Expanded(
                  child: ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final id = goal['id'] as String;
                      final isSelected = selectedGoal == id;
                      final isLocked = goal['locked'] as bool;

                      return _buildGoalCard(goal, isSelected, isLocked);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (selectedGoal != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/onboarding/fitness'),
                      child: const Text('CONFIRM SELECTION'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, bool isSelected, bool isLocked) {
    return GestureDetector(
      onTap: () {
        final haptics = ref.read(hapticServiceProvider);
        if (isLocked) {
          haptics.medium();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${goal['title']} unlocks after you complete Couch to 5K'),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          haptics.tap();
          setState(() => selectedGoal = goal['id'] as String);
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        opacity: isSelected ? 0.15 : 0.08,
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.white.withAlphaValue(0.1),
          width: isSelected ? 2 : 1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white.withAlphaValue(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                goal['icon'] as IconData,
                color: isSelected ? Colors.black : (isLocked ? Colors.white30 : Colors.white70),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isLocked ? Colors.white30 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLocked ? Colors.white.withAlphaValue(0.2) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.lock_outline, color: Colors.white30, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
