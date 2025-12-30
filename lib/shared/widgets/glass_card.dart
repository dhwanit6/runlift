import 'dart:ui';
import 'package:flutter/material.dart';
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
    this.blur = 10.0, // Reduced from 20
    this.opacity = 0.08,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: backgroundColor ?? Colors.white.withAlphaValue(opacity),
            border: border ??
                Border.all(
                  color: Colors.white.withAlphaValue(0.1),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
