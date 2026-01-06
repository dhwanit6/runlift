import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/color_utils.dart';

/// Simplified GlassCard - minimal blur, no heavy effects
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? backgroundColor;

  const GlassCard({
    required this.child,
    this.padding,
    this.blur = 30.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: backgroundColor == null ? AppTheme.surfaceGradient : null,
            color: backgroundColor,
            border: border ??
                Border.all(
                  color: Colors.white.withAlphaValue(0.15),
                  width: 0.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
