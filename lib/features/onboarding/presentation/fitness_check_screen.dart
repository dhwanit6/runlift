import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';

class FitnessCheckScreen extends StatefulWidget {
  const FitnessCheckScreen({super.key});

  @override
  State<FitnessCheckScreen> createState() => _FitnessCheckScreenState();
}

class _FitnessCheckScreenState extends State<FitnessCheckScreen> {
  String? selectedLevel;

  final levels = [
    {
      'id': 'recruit',
      'title': 'RECRUIT',
      'subtitle': 'Sedentary or minimal activity',
      'desc': 'Starting from zero. Focus on building foundation.',
    },
    {
      'id': 'scout',
      'title': 'SCOUT',
      'subtitle': 'Occasional walks or light gym',
      'desc': 'Moderate fitness. Ready for progressive load.',
    },
    {
      'id': 'vanguard',
      'title': 'VANGUARD',
      'subtitle': 'Regular cardio or sports',
      'desc': 'High baseline. Focus on technical pace.',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CALIBRATE',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  'FITNESS LEVEL',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                
                const SizedBox(height: 40),

                Expanded(
                  child: ListView.separated(
                    itemCount: levels.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final id = level['id'] as String;
                      final isSelected = selectedLevel == id;

                      return _buildLevelCard(level, isSelected);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (selectedLevel != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/auth'),
                      child: const Text('CALIBRATE & CONTINUE'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedLevel = level['id'] as String),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        opacity: isSelected ? 0.15 : 0.08,
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.white.withAlphaValue(0.1),
          width: isSelected ? 2 : 1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected ? AppTheme.primary : Colors.white,
                      ),
                    ),
                    Text(
                      level['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 24),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Text(
                level['desc'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
