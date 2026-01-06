import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  final SharedPreferences _prefs;

  StatsService(this._prefs);

  // ... (rest of the service class is unchanged) ...
  static const String _totalRunsKey = 'lifetime_total_runs';
  static const String _totalKmKey = 'lifetime_total_km';
  static const String _streakKey = 'current_streak';
  static const String _lastWorkoutDateKey = 'last_workout_date';
  static const String _weightKey = 'user_weight';
  static const String _heightKey = 'user_height';

  int getTotalRuns() => _prefs.getInt(_totalRunsKey) ?? 0;
  double getTotalKm() => _prefs.getDouble(_totalKmKey) ?? 0.0;
  int getCurrentStreak() => _prefs.getInt(_streakKey) ?? 0;
  String getLastWorkoutDate() => _prefs.getString(_lastWorkoutDateKey) ?? '';
  double getWeight() => _prefs.getDouble(_weightKey) ?? 0.0;
  double getHeight() => _prefs.getDouble(_heightKey) ?? 0.0;

  Future<void> setWeight(double value) => _prefs.setDouble(_weightKey, value);
  Future<void> setHeight(double value) => _prefs.setDouble(_heightKey, value);

  Future<void> recordWorkout(double distanceMeters) async {
    final currentRuns = getTotalRuns();
    await _prefs.setInt(_totalRunsKey, currentRuns + 1);
    
    final currentKm = getTotalKm();
    await _prefs.setDouble(_totalKmKey, currentKm + (distanceMeters / 1000.0));

    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastWorkout = getLastWorkoutDate();
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    int currentStreak = getCurrentStreak();
    if (lastWorkout == yesterday) {
      currentStreak++;
    } else if (lastWorkout != today) {
      currentStreak = 1;
    }
    
    await _prefs.setInt(_streakKey, currentStreak);
    await _prefs.setString(_lastWorkoutDateKey, today);
  }
}

// --- Provider Definitions ---

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// NEW: Use AsyncNotifier for safe, asynchronous state management
final lifetimeStatsProvider = AsyncNotifierProvider<LifetimeStatsNotifier, Map<String, dynamic>>(LifetimeStatsNotifier.new);

class LifetimeStatsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  
  // The build method replaces the constructor for async setup
  @override
  Future<Map<String, dynamic>> build() async {
    // This correctly awaits the SharedPreferences instance
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final statsService = StatsService(prefs);
    
    // Return the initial state
    return {
      'runs': statsService.getTotalRuns(),
      'km': statsService.getTotalKm(),
      'streak': statsService.getCurrentStreak(),
      'weight': statsService.getWeight(),
      'height': statsService.getHeight(),
    };
  }

  // Method to update and then reload the state
  Future<void> updateStats({double distanceMeters = 0}) async {
    // Set state to loading to show spinners in the UI
    state = const AsyncValue.loading();
    
    // Perform the async work
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final statsService = StatsService(prefs);
    await statsService.recordWorkout(distanceMeters);

    // Re-fetch the data and update the state, which will rebuild the UI
    state = AsyncValue.data({
      'runs': statsService.getTotalRuns(),
      'km': statsService.getTotalKm(),
      'streak': statsService.getCurrentStreak(),
      'weight': statsService.getWeight(),
      'height': statsService.getHeight(),
    });
  }

  Future<void> updateBiometrics({double? weight, double? height}) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final statsService = StatsService(prefs);
    
    if (weight != null) await statsService.setWeight(weight);
    if (height != null) await statsService.setHeight(height);

    state = AsyncValue.data({
      'runs': statsService.getTotalRuns(),
      'km': statsService.getTotalKm(),
      'streak': statsService.getCurrentStreak(),
      'weight': statsService.getWeight(),
      'height': statsService.getHeight(),
    });
  }
}
