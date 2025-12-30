/// Scientific injury prediction and red flag data.
/// 
/// This file contains data derived from physiotherapist and marathon runner
/// perspectives to predict and manage common running injuries.

import '../domain/models/injury.dart';

/// Common predictable discomforts for new runners
const predictableDiscomforts = [
  PredictableDiscomfort(
    category: SymptomCategory.quad,
    symptom: 'Quad Soreness',
    dayRangeStart: 2,
    dayRangeEnd: 6,
    reassuranceMessage: 'Muscle soreness means growth. Your muscles are adapting to the new load.',
    actionAdvice: 'Active recovery (walking), light stretching, and stay hydrated.',
  ),
  PredictableDiscomfort(
    category: SymptomCategory.shin,
    symptom: 'Mild Shin Tightness',
    dayRangeStart: 4,
    dayRangeEnd: 12,
    reassuranceMessage: 'Your shins are adapting to the impact. This is common for new runners.',
    actionAdvice: 'Ensure you are landing softly. Ice after runs if needed. Don\'t skip mobility days.',
  ),
  PredictableDiscomfort(
    category: SymptomCategory.general,
    symptom: 'Heavy Legs / Fatigue',
    dayRangeStart: 8,
    dayRangeEnd: 14,
    reassuranceMessage: 'This is the peak adaptation phase. Your body is working hard behind the scenes.',
    actionAdvice: 'Prioritize sleep and protein intake. Trust the rest days.',
  ),
  PredictableDiscomfort(
    category: SymptomCategory.calf,
    symptom: 'Tight Calves',
    dayRangeStart: 10,
    dayRangeEnd: 20,
    reassuranceMessage: 'Stronger push-off leads to tighter calves. This means your form is improving.',
    actionAdvice: 'Use a foam roller or tennis ball to massage your calves. Do extra calf stretches.',
  ),
  PredictableDiscomfort(
    category: SymptomCategory.knee,
    symptom: 'Mild Knee Warmth',
    dayRangeStart: 6,
    dayRangeEnd: 18,
    reassuranceMessage: 'Increased blood flow to the joints is normal. Sharp pain is not.',
    actionAdvice: 'Cross-train on recovery days. Ensure your glutes are activated before running.',
  ),
];

/// Red flag symptoms that require immediate stop/rest
const redFlagSymptoms = [
  RedFlagSymptom(
    category: SymptomCategory.knee,
    symptom: 'Sharp Lateral Knee Pain',
    warningMessage: 'This could be IT Band Syndrome. Running through it will make it worse.',
    guidance: GuidanceType.stop,
    restDaysRequired: 3,
  ),
  RedFlagSymptom(
    category: SymptomCategory.shin,
    symptom: 'Pain while walking / Tender to touch',
    warningMessage: 'Potential stress reaction. High risk of stress fracture if you continue.',
    guidance: GuidanceType.stop,
    restDaysRequired: 5,
  ),
  RedFlagSymptom(
    category: SymptomCategory.ankle,
    symptom: 'Swelling or bruising',
    warningMessage: 'Possible sprain or tendonitis. Requires immediate rest and ice.',
    guidance: GuidanceType.seekHelp,
    restDaysRequired: 7,
  ),
  RedFlagSymptom(
    category: SymptomCategory.foot,
    symptom: 'Sharp heel pain in the morning',
    warningMessage: 'Classic Plantar Fasciitis. Needs specific stretching and potentially different shoes.',
    guidance: GuidanceType.caution,
    restDaysRequired: 2,
  ),
];

/// Get a default injury awareness service
InjuryAwarenessService getInjuryAwarenessService() {
  return const InjuryAwarenessService(
    predictableDiscomforts: predictableDiscomforts,
    redFlags: redFlagSymptoms,
  );
}
