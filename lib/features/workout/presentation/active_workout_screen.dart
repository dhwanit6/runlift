import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/exercise_animation_viewer.dart';
import '../../../domain/models/training_program.dart';
import '../../../data/training_provider.dart';
import '../../../data/audio_service.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;
  
  const ActiveWorkoutScreen({required this.workoutId, super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Workout? _workout;
  TrainingDay? _today;
  bool _isInitialized = false;
  
  int currentIntervalIndex = 0;
  int currentRepeat = 1;
  int secondsRemaining = 0;
  bool isActive = false;
  bool isPaused = false;
  Timer? _timer;
  final AudioService _audioService = AudioService();
  
  // For strength/recovery
  List<bool> completedExercises = [];

  @override
  void initState() {
    super.initState();
    _audioService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkout();
    });
  }

  void _initializeWorkout() {
    // Use the validated workout provider
    final trainingDay = ref.read(trainingDayByWorkoutIdProvider(widget.workoutId));
    
    if (trainingDay == null) {
      // Fallback to current day if workout ID doesn't match
      final state = ref.read(trainingProvider);
      _today = state.today;
      _workout = _today!.workout;
    } else {
      _today = trainingDay;
      _workout = trainingDay.workout;
    }
    
    final workout = _workout!;
    
    if (workout.type == WorkoutType.run && workout.intervals != null && workout.intervals!.isNotEmpty) {
      secondsRemaining = workout.intervals![0].duration.inSeconds;
    } else if (workout.exercises != null && workout.exercises!.isNotEmpty) {
      completedExercises = List.filled(workout.exercises!.length, false);
      secondsRemaining = workout.estimatedDuration.inSeconds;
    } else {
      secondsRemaining = workout.estimatedDuration.inSeconds;
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _startWorkout() async {
    await _audioService.playStartSound();
    setState(() {
      isActive = true;
      isPaused = false;
    });
    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (secondsRemaining > 0) {
            // Play countdown beeps for last 3 seconds
            if (secondsRemaining <= 3) {
              _audioService.playCountdownBeep();
            }
            secondsRemaining--;
          } else {
            _handleIntervalEnd();
          }
        });
      }
    });
  }

  Future<void> _handleIntervalEnd() async {
    await _audioService.playIntervalBeep();
    
    final workout = _workout!;
    if (workout.type == WorkoutType.run && workout.intervals != null) {
      if (currentIntervalIndex < workout.intervals!.length - 1) {
        currentIntervalIndex++;
        secondsRemaining = workout.intervals![currentIntervalIndex].duration.inSeconds;
      } else if (currentRepeat < (workout.intervalRepeats ?? 1)) {
        currentRepeat++;
        currentIntervalIndex = 0;
        secondsRemaining = workout.intervals![0].duration.inSeconds;
      } else {
        _finishWorkout();
      }
    } else {
      _finishWorkout();
    }
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    await _audioService.playCompletionSound();
    
    if (_today != null) {
      await ref.read(trainingProvider.notifier).completeDay(_today!.dayNumber);
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.black.withAlphaValue(0.9),
        title: const Text('WORKOUT COMPLETE!', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        content: Text(_today?.motivationAfter ?? 'Great job!', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop();
            },
            child: const Text('FINISH', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!isActive) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withAlphaValue(0.9),
        title: const Text('EXIT WORKOUT?', style: TextStyle(color: Colors.white)),
        content: const Text('Your progress for this workout will be lost.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('STAY', style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('EXIT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until initialized
    if (!_isInitialized || _workout == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    
    final workout = _workout!;
    
    return PopScope(
      canPop: !isActive,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && isActive) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        body: AtmosphericBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(workout),
                  const Spacer(),
                  if (!isActive) _buildStartView(workout)
                  else if (workout.type == WorkoutType.run) _buildRunView(workout)
                  else _buildStrengthView(workout),
                  const Spacer(),
                  if (isActive) _buildControls(workout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Workout workout) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            if (isActive) {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.close_rounded, color: Colors.white54),
        ),
        Column(
          children: [
            Text(
              workout.name.toUpperCase(),
              style: const TextStyle(color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              'DAY ${_today?.dayNumber ?? 1}',
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildStartView(Workout workout) {
    return Column(
      children: [
        Text(
          'READY TO START?',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
        Text(
          workout.description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 120,
          height: 120,
          child: ElevatedButton(
            onPressed: _startWorkout,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 64),
          ),
        ),
      ],
    );
  }

  Widget _buildRunView(Workout workout) {
    if (workout.intervals == null || workout.intervals!.isEmpty) {
      return const Center(child: Text('No intervals available', style: TextStyle(color: Colors.white54)));
    }
    
    final currentInterval = workout.intervals![currentIntervalIndex];
    final isRun = currentInterval.type == IntervalType.run;

    return Column(
      children: [
        Text(
          isRun ? 'RUNNING' : 'WALKING',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isRun ? AppTheme.primary : AppTheme.secondary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _formatTime(secondsRemaining),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 96,
            fontWeight: FontWeight.w900,
            fontFamily: 'Monospace',
          ),
        ),
        if (workout.intervalRepeats != null && workout.intervalRepeats! > 1)
          Text(
            'ROUND $currentRepeat / ${workout.intervalRepeats}',
            style: const TextStyle(color: Colors.white24, letterSpacing: 2),
          ),
        const SizedBox(height: 48),
        Text(
          currentInterval.instruction ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildStrengthView(Workout workout) {
    if (workout.exercises == null || workout.exercises!.isEmpty) {
      return const Center(child: Text('No exercises available', style: TextStyle(color: Colors.white54)));
    }
    
    return Expanded(
      child: Column(
        children: [
          Text(
            _formatTime(secondsRemaining),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primary.withAlphaValue(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: workout.exercises!.length,
              itemBuilder: (context, index) {
                final ex = workout.exercises![index];
                final isCompleted = completedExercises[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    opacity: isCompleted ? 0.05 : 0.12,
                    border: Border.all(
                      color: isCompleted ? Colors.transparent : AppTheme.primary.withAlphaValue(0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise header with checkbox
                        CheckboxListTile(
                          value: isCompleted,
                          onChanged: (val) {
                            setState(() {
                              completedExercises[index] = val!;
                            });
                          },
                          title: Text(
                            ex.name,
                            style: TextStyle(
                              color: isCompleted ? Colors.white24 : Colors.white,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            ex.displayReps,
                            style: TextStyle(color: isCompleted ? Colors.white12 : AppTheme.primary),
                          ),
                          secondary: Icon(
                            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isCompleted ? AppTheme.success : Colors.white24,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: AppTheme.primary,
                          checkColor: Colors.black,
                        ),
                        
                        // Animation viewer (expandable)
                        if (!isCompleted && ex.animationPath != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ExerciseAnimationViewer(
                              exercise: ex,
                              autoPlay: false,
                              height: 200,
                            ),
                          ),
                        
                        // Description if available
                        if (ex.description != null && ex.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                            child: Text(
                              ex.description!,
                              style: TextStyle(
                                color: isCompleted ? Colors.white12 : Colors.white54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (completedExercises.isNotEmpty && completedExercises.every((e) => e))
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishWorkout,
                  child: const Text('ALL EXERCISES COMPLETE'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(Workout workout) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (workout.intervals != null && workout.intervals!.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                if (currentIntervalIndex > 0) {
                  currentIntervalIndex--;
                  secondsRemaining = workout.intervals![currentIntervalIndex].duration.inSeconds;
                  _audioService.playIntervalBeep();
                }
              });
            },
            icon: const Icon(Icons.skip_previous_rounded, size: 36, color: Colors.white24),
          ),
        const SizedBox(width: 24),
        FloatingActionButton.large(
          onPressed: () => setState(() => isPaused = !isPaused),
          backgroundColor: AppTheme.primary,
          child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 48, color: Colors.black),
        ),
        const SizedBox(width: 24),
        if (workout.intervals != null && workout.intervals!.isNotEmpty)
          IconButton(
            onPressed: () {
              _audioService.playIntervalBeep();
              _handleIntervalEnd();
            },
            icon: const Icon(Icons.skip_next_rounded, size: 36, color: Colors.white24),
          ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
