import 'package:flutter_test/flutter_test.dart';
import 'package:runlift/domain/models/injury.dart';
import 'package:runlift/data/injury_data.dart';

void main() {
  group('InjuryAwarenessService Tests', () {
    final service = getInjuryAwarenessService();

    test('Should predict quad soreness in early days', () {
      final prediction = service.getPrediction(3);
      expect(prediction.expectedDiscomforts.any((d) => d.category == SymptomCategory.quad), true);
    });

    test('Should predict shin tightness during adaptation phase', () {
      final prediction = service.getPrediction(10);
      expect(prediction.expectedDiscomforts.any((d) => d.category == SymptomCategory.shin), true);
    });

    test('Risk level should be higher in middle weeks', () {
      final riskWeek1 = service.getPrediction(3).riskLevel;
      final riskWeek2 = service.getPrediction(10).riskLevel;
      expect(riskWeek2 > riskWeek1, true);
    });

    test('Red flag check should identify critical symptoms', () {
      final redFlag = service.checkForRedFlag(
        SymptomCategory.knee, 
        DiscomfortLevel.severe, 
        null
      );
      expect(redFlag, isNotNull);
      expect(redFlag!.guidance, GuidanceType.stop);
    });
  });
}
