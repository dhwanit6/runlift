import 'package:flutter_test/flutter_test.dart';
import 'package:runlift/domain/models/training_program.dart';
import 'package:runlift/data/training_data.dart';

void main() {
  group('TrainingProgram Logic Tests', () {
    final program = getFullTrainingProgram();

    test('Program should have 4 weeks', () {
      expect(program.weeks.length, 4);
    });

    test('Program should have 28 days total', () {
      int totalDays = 0;
      for (var week in program.weeks) {
        totalDays += week.days.length;
      }
      expect(totalDays, 28);
    });

    test('First day should be correct', () {
      final day1 = program.getDay(1);
      expect(day1, isNotNull);
      expect(day1!.dayNumber, 1);
      expect(day1.weekNumber, 1);
      expect(day1.workout.type, WorkoutType.run);
    });

    test('Middle day calculation should be correct', () {
      final day15 = program.getDay(15);
      expect(day15, isNotNull);
      expect(day15!.weekNumber, 3);
      expect(day15.workout.type, WorkoutType.run);
    });

    test('5K Day should be Day 26', () {
      final day26 = program.getDay(26);
      expect(day26, isNotNull);
      expect(day26!.workout.id, 'run-5k-test');
      expect(day26.workout.estimatedDistanceKm, 5.0);
    });
  });
}
