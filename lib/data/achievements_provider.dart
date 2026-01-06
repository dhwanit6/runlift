import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievements_data.dart';

/// State for achievements
class AchievementsState {
  final List<String> unlockedIds;
  final List<Achievement> recentlyUnlocked;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;

  const AchievementsState({
    this.unlockedIds = const [],
    this.recentlyUnlocked = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
  });

  AchievementsState copyWith({
    List<String>? unlockedIds,
    List<Achievement>? recentlyUnlocked,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
  }) {
    return AchievementsState(
      unlockedIds: unlockedIds ?? this.unlockedIds,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }

  /// Get all achievements with unlock status applied
  List<Achievement> get allWithStatus {
    return allAchievements.map((a) {
      if (unlockedIds.contains(a.id)) {
        return a.unlock();
      }
      return a;
    }).toList();
  }

  /// Count unlocked achievements
  int get unlockedCount => unlockedIds.length;
  int get totalCount => allAchievements.length;
}

/// Achievements notifier
class AchievementsNotifier extends Notifier<AchievementsState> {
  static const String _keyUnlockedIds = 'achievements_unlocked';
  static const String _keyCurrentStreak = 'achievements_streak';
  static const String _keyLongestStreak = 'achievements_longest_streak';
  static const String _keyLastWorkout = 'achievements_last_workout';

  @override
  AchievementsState build() {
    _loadFromStorage();
    return const AchievementsState();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList(_keyUnlockedIds) ?? [];
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastWorkoutMs = prefs.getInt(_keyLastWorkout);
    
    DateTime? lastWorkout;
    if (lastWorkoutMs != null) {
      lastWorkout = DateTime.fromMillisecondsSinceEpoch(lastWorkoutMs);
    }
    
    state = state.copyWith(
      unlockedIds: unlockedIds,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastWorkoutDate: lastWorkout,
    );
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyUnlockedIds, state.unlockedIds);
    await prefs.setInt(_keyCurrentStreak, state.currentStreak);
    await prefs.setInt(_keyLongestStreak, state.longestStreak);
    if (state.lastWorkoutDate != null) {
      await prefs.setInt(_keyLastWorkout, state.lastWorkoutDate!.millisecondsSinceEpoch);
    }
  }

  /// Called when a workout is completed
  Future<List<Achievement>> onWorkoutCompleted({
    required int totalDaysCompleted,
    DateTime? workoutTime,
  }) async {
    final now = workoutTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate streak
    int newStreak = 1;
    if (state.lastWorkoutDate != null) {
      final lastDay = DateTime(
        state.lastWorkoutDate!.year,
        state.lastWorkoutDate!.month,
        state.lastWorkoutDate!.day,
      );
      final daysSinceLastWorkout = today.difference(lastDay).inDays;
      
      if (daysSinceLastWorkout == 1) {
        // Consecutive day - increase streak
        newStreak = state.currentStreak + 1;
      } else if (daysSinceLastWorkout == 0) {
        // Same day - keep streak
        newStreak = state.currentStreak;
      }
      // If > 1 day gap, streak resets to 1
    }
    
    final newLongestStreak = newStreak > state.longestStreak ? newStreak : state.longestStreak;
    
    // Check for "Comeback Kid" special achievement (resumed after 2+ day gap)
    bool isComeback = false;
    if (state.lastWorkoutDate != null) {
      final lastDay = DateTime(state.lastWorkoutDate!.year, state.lastWorkoutDate!.month, state.lastWorkoutDate!.day);
      final daysSinceLastWorkout = today.difference(lastDay).inDays;
      if (daysSinceLastWorkout >= 2) {
        isComeback = true;
      }
    }
    
    // Check for newly unlocked achievements
    var newlyUnlocked = checkAchievements(
      currentStreak: newStreak,
      totalDaysCompleted: totalDaysCompleted,
      unlockedIds: state.unlockedIds,
      workoutTime: now,
    );
    
    // Add comeback_kid if applicable and not already unlocked
    if (isComeback && !state.unlockedIds.contains('comeback_kid')) {
      final comebackAchievement = allAchievements.firstWhere((a) => a.id == 'comeback_kid').unlock();
      newlyUnlocked = [...newlyUnlocked, comebackAchievement];
    }
    
    // Update state
    final newUnlockedIds = [...state.unlockedIds, ...newlyUnlocked.map((a) => a.id)];
    
    state = state.copyWith(
      unlockedIds: newUnlockedIds,
      recentlyUnlocked: newlyUnlocked,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastWorkoutDate: now,
    );
    
    await _saveToStorage();
    
    return newlyUnlocked;
  }

  /// Clear recently unlocked (after showing popup)
  void clearRecentlyUnlocked() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  /// Check if specific achievement is unlocked
  bool isUnlocked(String achievementId) {
    return state.unlockedIds.contains(achievementId);
  }
}

// Provider
final achievementsProvider = NotifierProvider<AchievementsNotifier, AchievementsState>(
  AchievementsNotifier.new,
);
