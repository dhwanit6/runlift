import 'package:flutter/material.dart';

/// A shimmer loading effect widget for skeleton loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  const ShimmerLoading({
    required this.child,
    this.isLoading = true,
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF1A1A2E),
                Color(0xFF2A2A3E),
                Color(0xFF1A1A2E),
              ],
              stops: [
                0.0,
                0.5 + _animation.value * 0.25,
                1.0,
              ],
              transform: _SlideGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double slidePercent;
  
  const _SlideGradientTransform(this.slidePercent);
  
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// Skeleton placeholder widgets
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const SkeletonBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  
  const SkeletonText({
    this.width = 100,
    this.height = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, borderRadius: 4);
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  
  const SkeletonCircle({this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(15),
      ),
    );
  }
}

/// Pre-built skeleton for TodayScreen
class TodayScreenSkeleton extends StatelessWidget {
  const TodayScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week/Day badge skeleton
            const SkeletonBox(width: 120, height: 28, borderRadius: 20),
            const SizedBox(height: 16),
            // Title skeleton
            const SkeletonText(width: 200, height: 32),
            const SizedBox(height: 12),
            // Subtitle skeleton
            const SkeletonText(width: 280, height: 16),
            const SizedBox(height: 8),
            const SkeletonText(width: 220, height: 16),
            const SizedBox(height: 40),
            // Workout card skeleton
            const SkeletonBox(height: 180, borderRadius: 16),
            const SizedBox(height: 24),
            // Button skeleton
            const SkeletonBox(height: 56, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton for ProgramScreen
class ProgramScreenSkeleton extends StatelessWidget {
  const ProgramScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonText(width: 80, height: 14),
            const SizedBox(height: 4),
            const SkeletonText(width: 150, height: 40),
            const SizedBox(height: 40),
            // Week cards skeleton
            for (int i = 0; i < 4; i++) ...[
              const SkeletonBox(height: 120, borderRadius: 16),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton for ProgressScreen  
class ProgressScreenSkeleton extends StatelessWidget {
  const ProgressScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 40, color: Colors.white.withAlpha(15)),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(width: 180, height: 28),
                    SizedBox(height: 4),
                    SkeletonText(width: 140, height: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Circular progress skeleton
            const Center(child: SkeletonCircle(size: 200)),
            const SizedBox(height: 40),
            // Stats row skeleton
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SkeletonBox(width: 80, height: 60, borderRadius: 12),
                SkeletonBox(width: 80, height: 60, borderRadius: 12),
                SkeletonBox(width: 80, height: 60, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
