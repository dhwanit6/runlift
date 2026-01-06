/// Training program domain models for the 5K in 28 days program.
library;
/// 
/// This file contains all the core models that represent the training
/// structure: programs, weeks, days, and individual workouts.

/// The type of workout for a given day
enum WorkoutType {
  run,      // Running workout with intervals
  strength, // Strength training session
  recovery, // Active recovery (yoga, stretching, mobility)
  walk,     // Easy walk with stretching
  rest,     // Complete rest day
}

/// The type of interval within a run workout
enum IntervalType {
  run,     // Running interval
  walk,    // Walking interval
  warmup,  // Warmup phase
  cooldown, // Cooldown phase
}

/// A single interval within a run workout
class RunInterval {
  final IntervalType type;
  final Duration duration;
  final String? instruction;

  const RunInterval({
    required this.type,
    required this.duration,
    this.instruction,
  });

  /// Creates a run interval from minutes
  factory RunInterval.run(int minutes, [String? instruction]) {
    return RunInterval(
      type: IntervalType.run,
      duration: Duration(minutes: minutes),
      instruction: instruction,
    );
  }

  /// Creates a walk interval from minutes
  factory RunInterval.walk(int minutes, [String? instruction]) {
    return RunInterval(
      type: IntervalType.walk,
      duration: Duration(minutes: minutes),
      instruction: instruction,
    );
  }

  /// Creates a run interval from seconds
  factory RunInterval.runSeconds(int seconds, [String? instruction]) {
    return RunInterval(
      type: IntervalType.run,
      duration: Duration(seconds: seconds),
      instruction: instruction,
    );
  }

  /// Creates a walk interval from seconds
  factory RunInterval.walkSeconds(int seconds, [String? instruction]) {
    return RunInterval(
      type: IntervalType.walk,
      duration: Duration(seconds: seconds),
      instruction: instruction,
    );
  }
}

/// A single exercise in a strength/recovery workout
class Exercise {
  final String name;
  final String? description;
  final int? reps;
  final int? sets;
  final Duration? duration;
  final Duration? holdTime;
  final String? perSide; // e.g., "each side", "each leg"
  final String? videoUrl;
  final String? animationPath; // Path to Lottie animation file

  const Exercise({
    required this.name,
    this.description,
    this.reps,
    this.sets,
    this.duration,
    this.holdTime,
    this.perSide,
    this.videoUrl,
    this.animationPath,
  });

  /// Display text for the exercise (e.g., "15 reps" or "30s hold")
  String get displayReps {
    if (reps != null && perSide != null) {
      return '$reps $perSide';
    } else if (reps != null) {
      return '$reps reps';
    } else if (duration != null) {
      return '${duration!.inSeconds}s';
    } else if (holdTime != null) {
      return '${holdTime!.inSeconds}s hold';
    }
    return '';
  }
}

/// A complete workout (run, strength, or recovery)
class Workout {
  final String id;
  final String name;
  final String description;
  final WorkoutType type;
  final Duration estimatedDuration;
  final double? estimatedDistanceKm;
  final int? targetRpe; // Rate of Perceived Exertion (1-10)
  
  // For run workouts
  final List<RunInterval>? intervals;
  final int? intervalRepeats; // How many times to repeat the interval pattern
  
  // For strength/recovery workouts
  final List<Exercise>? exercises;
  final int? circuitRounds;
  final Duration? restBetweenRounds;

  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.estimatedDuration,
    this.estimatedDistanceKm,
    this.targetRpe,
    this.intervals,
    this.intervalRepeats,
    this.exercises,
    this.circuitRounds,
    this.restBetweenRounds,
  });

  /// Total running time for run workouts
  Duration get totalRunTime {
    if (intervals == null) return Duration.zero;
    
    final singlePattern = intervals!
        .where((i) => i.type == IntervalType.run)
        .fold<Duration>(Duration.zero, (sum, i) => sum + i.duration);
    
    return singlePattern * (intervalRepeats ?? 1);
  }

  /// Total walking time for run workouts
  Duration get totalWalkTime {
    if (intervals == null) return Duration.zero;
    
    final singlePattern = intervals!
        .where((i) => i.type == IntervalType.walk)
        .fold<Duration>(Duration.zero, (sum, i) => sum + i.duration);
    
    return singlePattern * (intervalRepeats ?? 1);
  }
}

/// Pre-run and post-run routines
class WarmupCooldown {
  final String name;
  final List<Exercise> exercises;
  final Duration estimatedDuration;
  final bool isWarmup; // true = warmup, false = cooldown

  const WarmupCooldown({
    required this.name,
    required this.exercises,
    required this.estimatedDuration,
    required this.isWarmup,
  });
}

/// A single day in the training program
class TrainingDay {
  final int dayNumber; // 1-28
  final int weekNumber; // 1-4
  final int dayOfWeek; // 1-7 (Mon-Sun)
  final Workout workout;
  final WarmupCooldown? warmup;
  final WarmupCooldown? cooldown;
  final String motivationBefore;
  final String motivationAfter;
  final String? injuryNote; // Special injury awareness for this day

  const TrainingDay({
    required this.dayNumber,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.workout,
    this.warmup,
    this.cooldown,
    required this.motivationBefore,
    required this.motivationAfter,
    this.injuryNote,
  });

  bool get isRunDay => workout.type == WorkoutType.run;
  bool get isRestDay => workout.type == WorkoutType.rest;
}

/// A week in the training program
class TrainingWeek {
  final int weekNumber;
  final String name;
  final String focus;
  final List<TrainingDay> days;
  final double totalDistanceKm;
  final String mentalInsight;

  const TrainingWeek({
    required this.weekNumber,
    required this.name,
    required this.focus,
    required this.days,
    required this.totalDistanceKm,
    required this.mentalInsight,
  });

  int get runDaysCount => days.where((d) => d.isRunDay).length;
  int get strengthDaysCount => 
      days.where((d) => d.workout.type == WorkoutType.strength).length;
}

/// The complete 28-day training program
class TrainingProgram {
  final String id;
  final String name;
  final String description;
  final int totalDays;
  final List<TrainingWeek> weeks;
  final DateTime? startDate;

  const TrainingProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.totalDays,
    required this.weeks,
    this.startDate,
  });

  /// Get a specific day by day number (1-28)
  TrainingDay? getDay(int dayNumber) {
    for (final week in weeks) {
      for (final day in week.days) {
        if (day.dayNumber == dayNumber) return day;
      }
    }
    return null;
  }

  /// Get the current week based on start date
  TrainingWeek? getCurrentWeek(DateTime now) {
    if (startDate == null) return weeks.first;
    final daysSinceStart = now.difference(startDate!).inDays;
    final weekIndex = daysSinceStart ~/ 7;
    if (weekIndex >= 0 && weekIndex < weeks.length) {
      return weeks[weekIndex];
    }
    return null;
  }

  /// Get the current day based on start date
  TrainingDay? getCurrentDay(DateTime now) {
    if (startDate == null) return getDay(1);
    final daysSinceStart = now.difference(startDate!).inDays + 1;
    return getDay(daysSinceStart);
  }
}
