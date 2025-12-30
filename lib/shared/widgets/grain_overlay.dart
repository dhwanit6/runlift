import 'dart:math';
import 'package:flutter/material.dart';

/// A subtle film-grain/noise overlay to simulate physical materials.
/// This eliminates the "flat digital" feel and adds high-end texture.
/// Uses a CustomPainter for performant, local noise generation.
class GrainOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;

  const GrainOverlay({
    required this.child,
    this.opacity = 0.03,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _NoisePainter(opacity: opacity),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final Random _random = Random(42); // Fixed seed for consistent pattern

  _NoisePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const step = 4.0; // Larger step = better performance

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final brightness = _random.nextDouble();
        paint.color = Colors.white.withAlpha((brightness * opacity * 255).toInt());
        canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
