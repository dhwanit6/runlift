/// Psychological motivation and engagement logic.
/// 
/// Provides contextual motivation based on the user's progress and state.

class MotivationService {
  /// Daily motivation based on day number
  static String getDailyQuote(int dayNumber) {
    if (dayNumber == 1) return "The hardest step is the one out the front door.";
    if (dayNumber == 7) return "First week complete. You've built the foundation.";
    if (dayNumber == 14) return "Halfway there. You're stronger than you were 14 days ago.";
    if (dayNumber == 21) return "The hardest week is behind you. Now, let's sharpen for the finish.";
    if (dayNumber == 26) return "28 days of work. 5 kilometers of proof. Today is your day.";
    
    final quotes = [
      "Consistency is better than perfection.",
      "Your only competition is the person you were yesterday.",
      "Running is 10% physical and 90% mental.",
      "Don't stop when you're tired, stop when you're done.",
      "Short runs are better than no runs.",
      "The miracle isn't that I finished. The miracle is that I had the courage to start.",
      "Pain is temporary. Pride is forever.",
      "A 12-minute mile is just as far as a 6-minute mile.",
    ];
    
    return quotes[dayNumber % quotes.length];
  }

  /// Motivation based on injury state
  static String getInjuryEncouragement(bool isNormalDiscomfort) {
    if (isNormalDiscomfort) {
      return "Listen to your body, but don't let it lie to you. This discomfort is part of growing stronger.";
    } else {
      return "Resting is part of training. A champion knows when to step back to come back stronger.";
    }
  }

  /// Weekly summary motivation
  static String getWeeklyInsight(int weekNumber) {
    switch (weekNumber) {
      case 1:
        return "You're acclimatizing. Focus on the habit of showing up.";
      case 2:
        return "Endurance is building. Your heart and lungs are getting efficient.";
      case 3:
        return "The mental hurdle. This is where most quit, but not you.";
      case 4:
        return "Peak and taper. You are ready for your 5K.";
      default:
        return "Keep moving forward.";
    }
  }
}
