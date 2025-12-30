import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Simplified atmospheric background with static gradient.
/// No animations to ensure maximum performance.
class AtmosphericBackground extends StatelessWidget {
  final Widget? child;

  const AtmosphericBackground({
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0F1C), // Deep navy
            AppTheme.background, // Deep black
            Color(0xFF0D0518), // Deep purple tint
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
