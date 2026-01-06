import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting training state to local storage.
/// 
/// This service handles saving and loading user progress to ensure
/// users don't lose their training data between app sessions.
class PersistenceService {
  static const String _keyCurrentDay = 'training_current_day';
  static const String _keyCompletedDays = 'training_completed_days';
  static const String _keyProgramStartDate = 'training_start_date';
  static const String _keyProgramId = 'training_program_id';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  /// Save the current training progress
  Future<void> saveProgress({
    required int currentDay,
    required List<int> completedDays,
    required DateTime? programStartDate,
    required String programId,
  }) async {
    try {
      await _prefs.setInt(_keyCurrentDay, currentDay);
      await _prefs.setStringList(
        _keyCompletedDays,
        completedDays.map((d) => d.toString()).toList(),
      );
      if (programStartDate != null) {
        await _prefs.setString(_keyProgramStartDate, programStartDate.toIso8601String());
      }
      await _prefs.setString(_keyProgramId, programId);
    } catch (e) {
      // Silently fail - persistence is non-blocking
      // In production, log to analytics
    }
  }

  /// Load saved training progress
  /// Returns null if no saved data exists
  TrainingProgress? loadProgress() {
    try {
      final currentDay = _prefs.getInt(_keyCurrentDay);
      final completedDaysStrings = _prefs.getStringList(_keyCompletedDays);
      final startDateString = _prefs.getString(_keyProgramStartDate);
      final programId = _prefs.getString(_keyProgramId);

      if (currentDay == null || completedDaysStrings == null) {
        return null;
      }

      final completedDays = completedDaysStrings
          .map((s) => int.tryParse(s))
          .where((d) => d != null)
          .cast<int>()
          .toList();

      DateTime? startDate;
      if (startDateString != null) {
        startDate = DateTime.tryParse(startDateString);
      }

      return TrainingProgress(
        currentDay: currentDay,
        completedDays: completedDays,
        programStartDate: startDate,
        programId: programId ?? 'couch-to-5k-28',
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear all saved progress (for reset functionality)
  Future<void> clearProgress() async {
    await _prefs.remove(_keyCurrentDay);
    await _prefs.remove(_keyCompletedDays);
    await _prefs.remove(_keyProgramStartDate);
    await _prefs.remove(_keyProgramId);
  }

  /// Check if user has existing progress
  bool hasProgress() {
    return _prefs.containsKey(_keyCurrentDay);
  }
}

/// Data class for loaded training progress
class TrainingProgress {
  final int currentDay;
  final List<int> completedDays;
  final DateTime? programStartDate;
  final String programId;

  const TrainingProgress({
    required this.currentDay,
    required this.completedDays,
    this.programStartDate,
    required this.programId,
  });
}
