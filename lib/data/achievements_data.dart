import 'package:flutter/foundation.dart';

/// Represents a streak of consecutive workout days
class Streak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final bool isActive;

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
    this.isActive = false,
  });

  /// Check if streak is still active (worked out yesterday or today)
  static bool checkStreakActive(DateTime? lastWorkout) {
    if (lastWorkout == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(lastWorkout.year, lastWorkout.month, lastWorkout.day);
    final difference = today.difference(lastDay).inDays;
    return difference <= 1; // Today or yesterday
  }

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    bool? isActive,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      requirement: requirement,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
  }
}

enum AchievementType {
  streak,       // Consecutive days
  totalDays,    // Total workouts completed
  milestone,    // Program milestones (week 1, 2, 3, 4)
  special,      // Special achievements
}

/// All available achievements
final List<Achievement> allAchievements = [
  // Streak achievements
  const Achievement(
    id: 'streak_3',
    title: 'Getting Warmed Up',
    description: 'Complete 3 days in a row',
    icon: '🔥',
    type: AchievementType.streak,
    requirement: 3,
  ),
  const Achievement(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Complete 7 days in a row',
    icon: '⚡',
    type: AchievementType.streak,
    requirement: 7,
  ),
  const Achievement(
    id: 'streak_14',
    title: 'Unstoppable',
    description: 'Complete 14 days in a row',
    icon: '🌟',
    type: AchievementType.streak,
    requirement: 14,
  ),
  const Achievement(
    id: 'streak_28',
    title: 'Perfect Month',
    description: 'Complete all 28 days in a row',
    icon: '👑',
    type: AchievementType.streak,
    requirement: 28,
  ),

  // Total days achievements
  const Achievement(
    id: 'total_5',
    title: 'First Steps',
    description: 'Complete 5 workouts',
    icon: '🏃',
    type: AchievementType.totalDays,
    requirement: 5,
  ),
  const Achievement(
    id: 'total_10',
    title: 'Building Momentum',
    description: 'Complete 10 workouts',
    icon: '💪',
    type: AchievementType.totalDays,
    requirement: 10,
  ),
  const Achievement(
    id: 'total_20',
    title: 'Dedicated Runner',
    description: 'Complete 20 workouts',
    icon: '🏅',
    type: AchievementType.totalDays,
    requirement: 20,
  ),
  const Achievement(
    id: 'total_28',
    title: '5K Graduate',
    description: 'Complete all 28 workouts',
    icon: '🎓',
    type: AchievementType.totalDays,
    requirement: 28,
  ),

  // Milestone achievements
  const Achievement(
    id: 'week_1',
    title: 'Week 1 Complete',
    description: 'Finished the first week of training',
    icon: '🌱',
    type: AchievementType.milestone,
    requirement: 7,
  ),
  const Achievement(
    id: 'week_2',
    title: 'Week 2 Complete',
    description: 'Halfway through week 2!',
    icon: '🌿',
    type: AchievementType.milestone,
    requirement: 14,
  ),
  const Achievement(
    id: 'week_3',
    title: 'Week 3 Complete',
    description: 'Almost there! Week 3 done',
    icon: '🌳',
    type: AchievementType.milestone,
    requirement: 21,
  ),
  const Achievement(
    id: 'week_4',
    title: 'Program Complete',
    description: 'You completed the entire program!',
    icon: '🏆',
    type: AchievementType.milestone,
    requirement: 28,
  ),

  // Special achievements
  const Achievement(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Complete a workout before 7 AM',
    icon: '🌅',
    type: AchievementType.special,
    requirement: 1,
  ),
  const Achievement(
    id: 'night_owl',
    title: 'Night Owl',
    description: 'Complete a workout after 9 PM',
    icon: '🌙',
    type: AchievementType.special,
    requirement: 1,
  ),
  const Achievement(
    id: 'comeback_kid',
    title: 'Comeback Kid',
    description: 'Resume after missing 2+ days',
    icon: '💫',
    type: AchievementType.special,
    requirement: 1,
  ),
];

/// Check which achievements should be unlocked
List<Achievement> checkAchievements({
  required int currentStreak,
  required int totalDaysCompleted,
  required List<String> unlockedIds,
  DateTime? workoutTime,
}) {
  final newlyUnlocked = <Achievement>[];

  for (final achievement in allAchievements) {
    if (unlockedIds.contains(achievement.id)) continue;

    bool shouldUnlock = false;

    switch (achievement.type) {
      case AchievementType.streak:
        shouldUnlock = currentStreak >= achievement.requirement;
        break;
      case AchievementType.totalDays:
      case AchievementType.milestone:
        shouldUnlock = totalDaysCompleted >= achievement.requirement;
        break;
      case AchievementType.special:
        if (achievement.id == 'early_bird' && workoutTime != null) {
          shouldUnlock = workoutTime.hour < 7;
        } else if (achievement.id == 'night_owl' && workoutTime != null) {
          shouldUnlock = workoutTime.hour >= 21;
        }
        break;
    }

    if (shouldUnlock) {
      newlyUnlocked.add(achievement.unlock());
    }
  }

  return newlyUnlocked;
}
