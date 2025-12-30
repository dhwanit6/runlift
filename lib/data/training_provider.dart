import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/training_program.dart';
import 'training_data.dart';
import '../domain/models/injury.dart';
import 'injury_data.dart';
import 'persistence_service.dart';

/// State of the training progress with complete type safety
class TrainingState {
  final TrainingProgram program;
  final int currentDay; // 1-28
  final List<int> completedDays;
  final DateTime? programStartDate;
  final bool isLoading;
  final String? errorMessage;

  TrainingState({
    required this.program,
    required this.currentDay,
    required this.completedDays,
    this.programStartDate,
    this.isLoading = false,
    this.errorMessage,
  });

  TrainingState copyWith({
    TrainingProgram? program,
    int? currentDay,
    List<int>? completedDays,
    DateTime? programStartDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrainingState(
      program: program ?? this.program,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      programStartDate: programStartDate ?? this.programStartDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Safe getter for today's workout with null safety
  TrainingDay? get todayOrNull => program.getDay(currentDay);
  
  /// Get today's workout with guaranteed non-null (defaults to day 1)
  TrainingDay get today {
    final day = program.getDay(currentDay);
    if (day != null) return day;
    return program.getDay(1) ?? program.weeks.first.days.first;
  }

  /// Safe getter for current week
  TrainingWeek get currentWeek {
    final weekIndex = (currentDay - 1) ~/ 7;
    if (weekIndex >= 0 && weekIndex < program.weeks.length) {
      return program.weeks[weekIndex];
    }
    return program.weeks.first;
  }

  /// Calculate completion percentage
  double get completionPercentage => completedDays.length / program.totalDays;

  /// Calculate total distance covered
  double get totalDistanceKm {
    double total = 0;
    for (final dayNum in completedDays) {
      final day = program.getDay(dayNum);
      if (day != null) {
        total += day.workout.estimatedDistanceKm ?? 0;
      }
    }
    return total;
  }

  /// Check if a specific day is completed
  bool isDayCompleted(int dayNumber) => completedDays.contains(dayNumber);

  /// Get current streak count
  int get currentStreak {
    if (completedDays.isEmpty) return 0;
    
    final sorted = List<int>.from(completedDays)..sort();
    int streak = 1;
    
    for (int i = sorted.length - 1; i > 0; i--) {
      if (sorted[i] - sorted[i - 1] == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

/// Provider for training state with persistence using Notifier (Riverpod 2.x)
class TrainingNotifier extends Notifier<TrainingState> {
  PersistenceService? _persistenceService;

  @override
  TrainingState build() {
    _initPersistence();
    return TrainingState(
      program: getFullTrainingProgram(),
      currentDay: 1,
      completedDays: [],
      programStartDate: DateTime.now(),
      isLoading: true,
    );
  }

  void _initPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _persistenceService = PersistenceService(prefs);
      _loadSavedProgress();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _loadSavedProgress() {
    if (_persistenceService == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final progress = _persistenceService!.loadProgress();
      if (progress != null) {
        state = state.copyWith(
          currentDay: progress.currentDay.clamp(1, 28),
          completedDays: progress.completedDays,
          programStartDate: progress.programStartDate ?? DateTime.now(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load progress.',
      );
    }
  }

  /// Complete a workout day
  Future<void> completeDay(int dayNumber) async {
    if (dayNumber < 1 || dayNumber > 28) {
      state = state.copyWith(errorMessage: 'Invalid day number');
      return;
    }

    if (state.completedDays.contains(dayNumber)) {
      return;
    }

    final newCompleted = [...state.completedDays, dayNumber];
    final nextDay = dayNumber < 28 ? dayNumber + 1 : 28;

    state = state.copyWith(
      completedDays: newCompleted,
      currentDay: nextDay,
      errorMessage: null,
    );

    await _saveProgress();
  }

  /// Manually set the current day
  Future<void> setDay(int dayNumber) async {
    final clampedDay = dayNumber.clamp(1, 28);
    state = state.copyWith(currentDay: clampedDay, errorMessage: null);
    await _saveProgress();
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    state = TrainingState(
      program: state.program,
      currentDay: 1,
      completedDays: [],
      programStartDate: DateTime.now(),
      isLoading: false,
    );
    
    await _persistenceService?.clearProgress();
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> _saveProgress() async {
    if (_persistenceService == null) return;

    try {
      await _persistenceService!.saveProgress(
        currentDay: state.currentDay,
        completedDays: state.completedDays,
        programStartDate: state.programStartDate,
        programId: state.program.id,
      );
    } catch (e) {
      // Non-blocking - don't show error for save failures
    }
  }
}

/// Main training state provider
final trainingProvider = NotifierProvider<TrainingNotifier, TrainingState>(
  TrainingNotifier.new,
);

/// Provider for injury awareness
final injuryServiceProvider = Provider<InjuryAwarenessService>((ref) {
  return getInjuryAwarenessService();
});

/// Provider to get workout by ID with validation
final workoutByIdProvider = Provider.family<Workout?, String>((ref, workoutId) {
  final program = ref.watch(trainingProvider).program;
  
  for (final week in program.weeks) {
    for (final day in week.days) {
      if (day.workout.id == workoutId) {
        return day.workout;
      }
    }
  }
  return null;
});

/// Provider to get training day by workout ID with validation
final trainingDayByWorkoutIdProvider = Provider.family<TrainingDay?, String>((ref, workoutId) {
  final program = ref.watch(trainingProvider).program;
  
  for (final week in program.weeks) {
    for (final day in week.days) {
      if (day.workout.id == workoutId) {
        return day;
      }
    }
  }
  return null;
});
