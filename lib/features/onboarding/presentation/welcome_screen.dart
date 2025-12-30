import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/atmospheric_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                
                // App Branding
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 40, color: Colors.black),
                ),

                const SizedBox(height: 40),

                // Large Title
                Text(
                  'RUNLIFT',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  '28 DAYS TO 5K',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Precision training for the modern athlete. No fluff. Just results.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // CTA
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.push('/onboarding/goals'),
                    child: const Text('START TRANSFORMATION'),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'ALREADY A MEMBER? SIGN IN',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 1,
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
}
