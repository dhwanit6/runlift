import 'package:share_plus/share_plus.dart';

/// Social sharing service for viral growth
class SocialShareService {
  /// Share workout completion
  static Future<void> shareWorkoutComplete({
    required int dayNumber,
    required int totalDays,
    required String workoutName,
    int? currentStreak,
  }) async {
    final progress = ((dayNumber / totalDays) * 100).round();
    
    String message = '''
🏃 Day $dayNumber of 28 Complete! 

Today's workout: $workoutName
Progress: $progress% to 5K

${currentStreak != null && currentStreak > 1 ? '🔥 $currentStreak day streak!\n' : ''}
I'm training with RunLift - the 28-day Couch to 5K app.

#RunLift #CouchTo5K #Running #Fitness
''';

    try {
      await Share.share(message);
    } catch (e) {
      // Sharing failed (no share app, cancelled, etc.) - ignore silently
    }
  }

  /// Share milestone achievement
  static Future<void> shareMilestone({
    required String milestoneName,
    required String emoji,
    required int daysCompleted,
  }) async {
    String message = '''
$emoji Achievement Unlocked: $milestoneName!

I've completed $daysCompleted days of the RunLift 28-day program.

From couch to 5K, one day at a time. 💪

#RunLift #Achievement #Running #FitnessJourney
''';

    try {
      await Share.share(message);
    } catch (e) {
      // Sharing failed - ignore silently
    }
  }

  /// Share streak achievement
  static Future<void> shareStreak({
    required int streakDays,
  }) async {
    String emoji = streakDays >= 14 ? '🌟' : (streakDays >= 7 ? '⚡' : '🔥');
    
    String message = '''
$emoji $streakDays Day Streak!

Haven't missed a workout in $streakDays days straight.
The RunLift 28-day program is keeping me accountable.

Who else is on a streak? 🙋‍♂️

#RunLift #Streak #Consistency #Running
''';

    try {
      await Share.share(message);
    } catch (e) {
      // Sharing failed - ignore silently
    }
  }

  /// Share program completion
  static Future<void> shareProgramComplete() async {
    String message = '''
🎓🏆 I DID IT! 🏆🎓

28 days ago, I couldn't run. Today, I completed the RunLift 28-day Couch to 5K program!

From complete beginner to running 5K without stopping.

If I can do it, you can too. Download RunLift and start your journey!

#RunLift #5KRunner #TransformationComplete #Running
''';

    try {
      await Share.share(message);
    } catch (e) {
      // Sharing failed - ignore silently
    }
  }

  /// Share invite to friend
  static Future<void> shareInvite() async {
    String message = '''
Hey! I've been using this app called RunLift to train for a 5K.

It's a 28-day program that takes you from zero to running 5K. 
The workouts are smart - mixing running, strength, and recovery.

Download it and let's train together! 🏃‍♂️🏃‍♀️

#RunLift #CouchTo5K
''';

    try {
      await Share.share(message);
    } catch (e) {
      // Sharing failed - ignore silently
    }
  }

  /// Generate shareable image text (for screenshot sharing)
  static String getShareableStats({
    required int daysCompleted,
    required int currentStreak,
    required int totalMinutes,
  }) {
    return '''
📊 My RunLift Stats
─────────────────
Days: $daysCompleted/28
Streak: $currentStreak days
Time: ${(totalMinutes / 60).toStringAsFixed(1)} hours

#RunLift
''';
  }
}
