/// App-wide constants for consistent styling and behavior
library;

import 'package:flutter/material.dart';

// =============================================================================
// DIMENSIONS
// =============================================================================

class AppDimensions {
  AppDimensions._();
  
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusPill = 100.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 80.0;
  static const double bottomNavMargin = 24.0;
  
  // Cards
  static const double cardMinHeight = 80.0;
  static const double cardBorderWidth = 1.0;
}

// =============================================================================
// DURATIONS
// =============================================================================

class AppDurations {
  AppDurations._();
  
  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  
  // Transitions
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration shimmerLoop = Duration(milliseconds: 1500);
  
  // Workout Timers
  static const Duration voiceCoachDelay = Duration(milliseconds: 300);
  static const Duration intervalPause = Duration(milliseconds: 500);
  static const Duration saveDebounce = Duration(seconds: 5);
  
  // Notifications
  static const int defaultBriefingHour = 7;
  static const int defaultBriefingMinute = 0;
}

// =============================================================================
// WORKOUT CONSTANTS
// =============================================================================

class WorkoutConstants {
  WorkoutConstants._();
  
  // GPS
  static const int distanceFilterMeters = 5;
  static const int minDistanceChangeMeters = 2;
  
  // Calories (rough estimates)
  static const double caloriesPerKmRunning = 75.0; // 75kg person
  static const double caloriesPerMinStrength = 5.0;
  
  // Timer
  static const int countdownStart = 3;
  static const Duration timerInterval = Duration(seconds: 1);
}

// =============================================================================
// TEXT CONSTANTS
// =============================================================================

class AppStrings {
  AppStrings._();
  
  // App Info
  static const String appName = 'RunLift';
  static const String appVersion = '1.0.0';
  static const String appTagline = '28 DAYS TO 5K';
  static const String appCopyright = '© 2024 RunLift. All rights reserved.';
  
  // Workout
  static const String missionComplete = 'MISSION COMPLETE';
  static const String missionBriefing = 'MISSION BRIEFING';
  
  // Voice Coach
  static const String workoutComplete = 'Workout complete. Syncing data. Incredible effort today.';
  static const String allExercisesDone = 'All exercises complete! Great work!';
  static const String nice = 'Nice!';
  
  // Snackbars
  static const String proComingSoon = 'Voice customization coming in RunLift PRO (v1.1)';
  static const String settingsUnavailable = 'Settings module unavailable in prototype';
  static const String gpsUnavailableWeb = 'GPS tracking unavailable in browser. Use the mobile app for full features.';
}

// =============================================================================
// GRADIENT PRESETS
// =============================================================================

class AppGradients {
  AppGradients._();
  
  static const LinearGradient achievementPopup = LinearGradient(
    colors: [Color(0x28FFC107), Color(0x1E00E676)], // amber.withAlpha(40), primary.withAlpha(30)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient proUpgrade = LinearGradient(
    colors: [Color(0x28FFC107), Color(0x14FF9800)], // amber, orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient atmospheric = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0D1A),
      Color(0xFF1A1A2E),
      Color(0xFF0D0D1A),
    ],
  );
}
