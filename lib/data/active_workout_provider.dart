import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/training_program.dart';
import 'training_provider.dart';
import 'voice_coach_service.dart';
import 'haptic_service.dart';

// Definining voice coach provider here if not already defined elsewhere
final voiceCoachServiceProvider = Provider((ref) => VoiceCoachService());

class ActiveWorkoutState {
  final Workout? workout;
  final List<RunInterval>? expandedIntervals;
  final int elapsedSeconds;
  final bool isRunning;
  final int currentIntervalIndex;
  final int intervalSecondsRemaining;
  final DateTime? startTime;
  final bool isCompleted;

  const ActiveWorkoutState({
    this.workout,
    this.expandedIntervals,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.currentIntervalIndex = 0,
    this.intervalSecondsRemaining = 0,
    this.startTime,
    this.isCompleted = false,
  });

  int get currentRound {
    final intervalsPerRound = workout?.intervals?.length ?? 1;
    return (currentIntervalIndex ~/ intervalsPerRound) + 1;
  }

  int get totalRounds {
    return workout?.intervalRepeats ?? 1;
  }

  int calculateCalories(double distanceMeters) {
    if (workout == null) return 0;
    
    if (workout!.type == WorkoutType.run) {
      // Running: ~70-75 calories per km for average weight
      if (distanceMeters < 50) return 0;
      return ((distanceMeters / 1000) * 72).toInt();
    } else {
      // Strength/Recovery: ~5-7 calories per minute
      return (elapsedSeconds / 60 * 6).toInt();
    }
  }

  ActiveWorkoutState copyWith({
    Workout? workout,
    List<RunInterval>? expandedIntervals,
    int? elapsedSeconds,
    bool? isRunning,
    int? currentIntervalIndex,
    int? intervalSecondsRemaining,
    DateTime? startTime,
    bool? isCompleted,
  }) {
    return ActiveWorkoutState(
      workout: workout ?? this.workout,
      expandedIntervals: expandedIntervals ?? this.expandedIntervals,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      currentIntervalIndex: currentIntervalIndex ?? this.currentIntervalIndex,
      intervalSecondsRemaining: intervalSecondsRemaining ?? this.intervalSecondsRemaining,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState> {
  Timer? _timer;
  static const _keyPrefix = 'active_workout_';

  @override
  ActiveWorkoutState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const ActiveWorkoutState();
  }

  Future<void> startWorkout(Workout workout) async {
    // Expand intervals based on repeats
    List<RunInterval> expanded = [];
    if (workout.intervals != null) {
      final repeats = workout.intervalRepeats ?? 1;
      for (int i = 0; i < repeats; i++) {
        expanded.addAll(workout.intervals!);
      }
    }

    state = ActiveWorkoutState(
      workout: workout,
      expandedIntervals: expanded,
      isRunning: true,
      startTime: DateTime.now(),
      intervalSecondsRemaining: expanded.isNotEmpty ? expanded[0].duration.inSeconds : workout.estimatedDuration.inSeconds,
    );

    // Initial announcement
    if (expanded.isNotEmpty) {
      ref.read(voiceCoachServiceProvider).announceInterval(expanded[0]);
    }

    _startTimer();
    _persist();
  }

  void pauseWorkout() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _persist();
  }

  void resumeWorkout() {
    state = state.copyWith(isRunning: true);
    _startTimer();
    _persist();
  }

  void stopWorkout() {
    _timer?.cancel();
    state = const ActiveWorkoutState(isCompleted: true);
    _clearPersistence();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.workout == null || !state.isRunning) return;

      final voiceCoach = ref.read(voiceCoachServiceProvider);
      int nextSeconds = state.elapsedSeconds + 1;
      int nextIntervalSeconds = state.intervalSecondsRemaining;
      int nextIntervalIndex = state.currentIntervalIndex;
      final intervals = state.expandedIntervals ?? [];

      if (intervals.isNotEmpty) {
        if (nextIntervalSeconds > 1) {
          nextIntervalSeconds--;
          
          // Voice cues
          if (nextIntervalSeconds == intervals[nextIntervalIndex].duration.inSeconds ~/ 2) {
            voiceCoach.announceHalfway();
          } else if (nextIntervalSeconds <= 3) {
            voiceCoach.announceFinalSeconds(nextIntervalSeconds);
            ref.read(hapticServiceProvider).tap();
          }
        } else {
          // Transition or Complete
          if (nextIntervalIndex + 1 < intervals.length) {
            nextIntervalIndex++;
            nextIntervalSeconds = intervals[nextIntervalIndex].duration.inSeconds;
            voiceCoach.announceInterval(intervals[nextIntervalIndex]);
            ref.read(hapticServiceProvider).heavy();
          } else {
            // WORKOUT FINISHED
            _timer?.cancel();
            state = state.copyWith(
              elapsedSeconds: nextSeconds,
              intervalSecondsRemaining: 0,
              isRunning: false,
              isCompleted: true,
            );
            _clearPersistence();
            return;
          }
        }
      } else {
        // No intervals (strength/recovery based on total time)
        if (nextSeconds >= state.workout!.estimatedDuration.inSeconds) {
          _timer?.cancel();
          state = state.copyWith(
            elapsedSeconds: nextSeconds,
            isRunning: false,
            isCompleted: true,
          );
          _clearPersistence();
          return;
        }
      }

      state = state.copyWith(
        elapsedSeconds: nextSeconds,
        intervalSecondsRemaining: nextIntervalSeconds,
        currentIntervalIndex: nextIntervalIndex,
      );
      
      if (nextSeconds % 5 == 0) {
        _persist();
      }
    });
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.workout == null) return;
      
      await prefs.setString('${_keyPrefix}workout_id', state.workout!.id);
      await prefs.setInt('${_keyPrefix}elapsed', state.elapsedSeconds);
      await prefs.setInt('${_keyPrefix}interval_index', state.currentIntervalIndex);
      await prefs.setInt('${_keyPrefix}interval_remaining', state.intervalSecondsRemaining);
      await prefs.setString('${_keyPrefix}start_time', state.startTime?.toIso8601String() ?? '');
      await prefs.setBool('${_keyPrefix}is_running', state.isRunning);
    } catch (e) {
      // Persistence error silently ignored in production
    }
  }

  Future<void> _clearPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_keyPrefix}workout_id');
    await prefs.remove('${_keyPrefix}elapsed');
    await prefs.remove('${_keyPrefix}interval_index');
    await prefs.remove('${_keyPrefix}interval_remaining');
    await prefs.remove('${_keyPrefix}start_time');
    await prefs.remove('${_keyPrefix}is_running');
  }

  Future<void> restoreIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutId = prefs.getString('${_keyPrefix}workout_id');
    if (workoutId == null) return;

    // We wait for training data to be ready
    final trainingState = ref.read(trainingProvider);
    if (trainingState.isLoading) return;

    // Find workout by ID across all days
    Workout? foundWorkout;
    for (var week in trainingState.program.weeks) {
      for (var day in week.days) {
        if (day.workout.id == workoutId) {
          foundWorkout = day.workout;
          break;
        }
      }
      if (foundWorkout != null) break;
    }

    if (foundWorkout != null) {
      final elapsed = prefs.getInt('${_keyPrefix}elapsed') ?? 0;
      final intervalIndex = prefs.getInt('${_keyPrefix}interval_index') ?? 0;
      final intervalRemaining = prefs.getInt('${_keyPrefix}interval_remaining') ?? 0;
      final startTimeStr = prefs.getString('${_keyPrefix}start_time');
      final isRunning = prefs.getBool('${_keyPrefix}is_running') ?? false;
      
      // Reconstruct expanded intervals
      List<RunInterval> expanded = [];
      if (foundWorkout.intervals != null) {
        final repeats = foundWorkout.intervalRepeats ?? 1;
        for (int i = 0; i < repeats; i++) {
          expanded.addAll(foundWorkout.intervals!);
        }
      }

      state = ActiveWorkoutState(
        workout: foundWorkout,
        expandedIntervals: expanded,
        elapsedSeconds: elapsed,
        currentIntervalIndex: intervalIndex,
        intervalSecondsRemaining: intervalRemaining,
        startTime: startTimeStr != null ? DateTime.tryParse(startTimeStr) : null,
        isRunning: isRunning,
      );

      if (isRunning) {
        _startTimer();
      }
    } else {
      // Saved workout not found
    }
  }
}

final activeWorkoutProvider = NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
  ActiveWorkoutNotifier.new,
);
