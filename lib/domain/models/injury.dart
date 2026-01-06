/// Injury prediction and body awareness models.
library;
/// 
/// This file contains models for tracking user symptoms, predicting
/// potential injuries, and providing appropriate guidance.

/// Category of symptom/discomfort
enum SymptomCategory {
  shin,     // Shin splints, tibial stress
  knee,     // Knee pain, runner's knee
  calf,     // Calf tightness, strain
  ankle,    // Ankle pain, sprain risk
  hip,      // Hip flexor, IT band
  foot,     // Plantar fasciitis, foot pain
  quad,     // Quadriceps soreness
  hamstring,// Hamstring tightness
  back,     // Lower back pain
  general,  // General fatigue, muscle soreness
}

/// Severity level of discomfort
enum DiscomfortLevel {
  none,     // No discomfort
  mild,     // Slight awareness, doesn't affect running
  moderate, // Noticeable, may affect form
  severe,   // Significant, should modify or stop
  critical, // Must stop immediately
}

/// Type of guidance to provide
enum GuidanceType {
  reassurance,  // Normal, keep going with tips
  modification, // Modify workout (reduce intensity/duration)
  caution,      // Proceed with caution, watch closely
  stop,         // Stop workout, rest required
  seekHelp,     // Consult a professional
}

/// A predictable discomfort that users commonly experience
class PredictableDiscomfort {
  final SymptomCategory category;
  final String symptom;
  final int dayRangeStart;
  final int dayRangeEnd;
  final String reassuranceMessage;
  final String actionAdvice;
  final bool isNormal;

  const PredictableDiscomfort({
    required this.category,
    required this.symptom,
    required this.dayRangeStart,
    required this.dayRangeEnd,
    required this.reassuranceMessage,
    required this.actionAdvice,
    this.isNormal = true,
  });

  /// Check if this discomfort is expected on a given day
  bool isExpectedOnDay(int dayNumber) {
    return dayNumber >= dayRangeStart && dayNumber <= dayRangeEnd;
  }
}

/// A red flag symptom that requires immediate attention
class RedFlagSymptom {
  final SymptomCategory category;
  final String symptom;
  final String warningMessage;
  final GuidanceType guidance;
  final int restDaysRequired;

  const RedFlagSymptom({
    required this.category,
    required this.symptom,
    required this.warningMessage,
    required this.guidance,
    this.restDaysRequired = 1,
  });
}

/// User's body check before a workout
class BodyCheck {
  final DateTime timestamp;
  final int dayNumber;
  final Map<SymptomCategory, DiscomfortLevel> symptoms;
  final String? notes;

  const BodyCheck({
    required this.timestamp,
    required this.dayNumber,
    required this.symptoms,
    this.notes,
  });

  /// Get the highest severity symptom
  DiscomfortLevel get maxSeverity {
    if (symptoms.isEmpty) return DiscomfortLevel.none;
    return symptoms.values.reduce((a, b) => 
        a.index > b.index ? a : b);
  }

  /// Check if any symptom is at concerning level
  bool get hasConcerningSymptoms {
    return symptoms.values.any((level) => 
        level == DiscomfortLevel.severe || 
        level == DiscomfortLevel.critical);
  }

  /// Get the recommended guidance based on symptoms
  GuidanceType getRecommendedGuidance() {
    if (symptoms.values.any((l) => l == DiscomfortLevel.critical)) {
      return GuidanceType.seekHelp;
    }
    if (symptoms.values.any((l) => l == DiscomfortLevel.severe)) {
      return GuidanceType.stop;
    }
    if (symptoms.values.any((l) => l == DiscomfortLevel.moderate)) {
      return GuidanceType.modification;
    }
    if (symptoms.values.any((l) => l == DiscomfortLevel.mild)) {
      return GuidanceType.reassurance;
    }
    return GuidanceType.reassurance;
  }
}

/// Injury prediction result for a specific day
class InjuryPrediction {
  final int dayNumber;
  final List<PredictableDiscomfort> expectedDiscomforts;
  final double riskLevel; // 0.0 - 1.0
  final String riskDescription;
  final List<String> preventionTips;

  const InjuryPrediction({
    required this.dayNumber,
    required this.expectedDiscomforts,
    required this.riskLevel,
    required this.riskDescription,
    required this.preventionTips,
  });

  /// Risk level as a string
  String get riskLevelText {
    if (riskLevel < 0.3) return 'Low';
    if (riskLevel < 0.6) return 'Moderate';
    if (riskLevel < 0.8) return 'Elevated';
    return 'High';
  }
}

/// Service for managing injury predictions and body checks
class InjuryAwarenessService {
  final List<PredictableDiscomfort> _predictableDiscomforts;
  final List<RedFlagSymptom> _redFlags;

  const InjuryAwarenessService({
    required List<PredictableDiscomfort> predictableDiscomforts,
    required List<RedFlagSymptom> redFlags,
  })  : _predictableDiscomforts = predictableDiscomforts,
        _redFlags = redFlags;

  /// Get expected discomforts for a specific day
  List<PredictableDiscomfort> getExpectedDiscomforts(int dayNumber) {
    return _predictableDiscomforts
        .where((d) => d.isExpectedOnDay(dayNumber))
        .toList();
  }

  /// Get injury prediction for a specific day
  InjuryPrediction getPrediction(int dayNumber) {
    final expected = getExpectedDiscomforts(dayNumber);
    
    // Risk is higher during days 8-14 (adaptation phase)
    double baseRisk = 0.15;
    if (dayNumber >= 8 && dayNumber <= 14) {
      baseRisk = 0.45;
    } else if (dayNumber >= 15 && dayNumber <= 21) {
      baseRisk = 0.35;
    }
    
    final riskLevel = baseRisk + (expected.length * 0.05);
    
    String riskDescription;
    if (riskLevel < 0.3) {
      riskDescription = 'Your body is adapting well. Keep up the good work!';
    } else if (riskLevel < 0.5) {
      riskDescription = 'This is a key adaptation period. Listen to your body.';
    } else {
      riskDescription = 'Higher injury risk window. Prioritize form and recovery.';
    }
    
    final tips = <String>[];
    for (final discomfort in expected) {
      tips.add(discomfort.actionAdvice);
    }
    if (tips.isEmpty) {
      tips.add('Stay hydrated and warm up properly');
    }
    
    return InjuryPrediction(
      dayNumber: dayNumber,
      expectedDiscomforts: expected,
      riskLevel: riskLevel.clamp(0.0, 1.0),
      riskDescription: riskDescription,
      preventionTips: tips,
    );
  }

  /// Check if a symptom matches a red flag
  RedFlagSymptom? checkForRedFlag(
    SymptomCategory category, 
    DiscomfortLevel level,
    String? description,
  ) {
    if (level.index < DiscomfortLevel.severe.index) return null;
    
    return _redFlags.firstWhere(
      (rf) => rf.category == category,
      orElse: () => RedFlagSymptom(
        category: category,
        symptom: 'Severe pain',
        warningMessage: 'Please rest and consult a professional if pain persists.',
        guidance: GuidanceType.stop,
      ),
    );
  }
}
