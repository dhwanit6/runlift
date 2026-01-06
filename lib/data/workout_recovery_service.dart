import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutRecoveryService {
  static const String _keyWorkoutState = 'active_workout_state';
  
  // Save workout state
  Future<void> saveWorkoutState({
    required String workoutId,
    required int secondsRemaining,
    required int currentIntervalIndex,
    required int currentRepeat,
    required List<bool> completedExercises,
    required int elapsedSeconds,
    required int dayNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final state = {
      'workoutId': workoutId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'secondsRemaining': secondsRemaining,
      'currentIntervalIndex': currentIntervalIndex,
      'currentRepeat': currentRepeat,
      'completedExercises': completedExercises,
      'elapsedSeconds': elapsedSeconds,
      'dayNumber': dayNumber,
    };
    
    await prefs.setString(_keyWorkoutState, jsonEncode(state));
  }
  
  // Retrieve saved state
  Future<Map<String, dynamic>?> getSavedWorkoutState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_keyWorkoutState);
    
    if (jsonStr == null) return null;
    
    try {
      final Map<String, dynamic> state = jsonDecode(jsonStr);
      
      // Check if the saved state is too old (e.g., > 2 hours)
      final timestamp = state['timestamp'] as int;
      final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final difference = DateTime.now().difference(savedTime);
      
      if (difference.inHours > 2) {
        await clearSavedState();
        return null; // State expired
      }
      
      return state;
    } catch (e) {
      await clearSavedState();
      return null;
    }
  }
  
  // Clear saved state
  Future<void> clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyWorkoutState);
  }
  
  // Check if there is a recoverable workout
  Future<bool> hasRecoverableWorkout() async {
    final state = await getSavedWorkoutState();
    return state != null;
  }
}
