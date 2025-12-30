import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/models/training_program.dart';

/// Widget to display exercise animations using Lottie
/// Falls back to icon if animation is not available
class ExerciseAnimationViewer extends StatefulWidget {
  final Exercise exercise;
  final bool autoPlay;
  final double? height;

  const ExerciseAnimationViewer({
    required this.exercise,
    this.autoPlay = true,
    this.height,
    super.key,
  });

  @override
  State<ExerciseAnimationViewer> createState() => _ExerciseAnimationViewerState();
}

class _ExerciseAnimationViewerState extends State<ExerciseAnimationViewer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isPlaying = widget.autoPlay;
    if (widget.autoPlay) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAnimation = widget.exercise.animationPath != null;

    return Container(
      height: widget.height ?? 250,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(10),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animation or Fallback Icon
          if (hasAnimation)
            Lottie.asset(
              widget.exercise.animationPath!,
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                if (widget.autoPlay) {
                  _controller.repeat();
                }
              },
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon();
              },
            )
          else
            _buildFallbackIcon(),

          // Play/Pause Button
          if (hasAnimation)
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

          // Exercise Name Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Reps/Duration Overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.exercise.displayReps,
                style: const TextStyle(
                  color: Color(0xFF4FFFB0),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getExerciseIcon(),
          size: 80,
          color: Colors.white.withAlpha(60),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.exercise.description ?? 'No animation available',
            style: TextStyle(
              color: Colors.white.withAlpha(120),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  IconData _getExerciseIcon() {
    final name = widget.exercise.name.toLowerCase();
    if (name.contains('plank')) return Icons.airline_seat_flat;
    if (name.contains('squat')) return Icons.accessibility_new;
    if (name.contains('lunge')) return Icons.directions_walk;
    if (name.contains('push')) return Icons.fitness_center;
    if (name.contains('stretch')) return Icons.self_improvement;
    if (name.contains('bridge')) return Icons.architecture;
    if (name.contains('run')) return Icons.directions_run;
    return Icons.fitness_center;
  }
}
