import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecoveryService {
  final SharedPreferences _prefs;

  RecoveryService(this._prefs);

  static const String _keyRecoveryState = 'recovery_checklist_state';
  static const String _keyLastDate = 'recovery_last_date';

  // Get current checklist state
  Map<String, bool> getChecklistState() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs.getString(_keyLastDate);

    // Reset if it's a new day
    if (lastDate != today) {
      _prefs.setString(_keyLastDate, today);
      _prefs.remove(_keyRecoveryState);
      return {
        'Mobility Flow': false,
        'Hydration': false,
        'Protein': false,
        'Sleep': false,
      };
    }

    final jsonStr = _prefs.getString(_keyRecoveryState);
    if (jsonStr == null) {
      return {
        'Mobility Flow': false,
        'Hydration': false,
        'Protein': false,
        'Sleep': false,
      };
    }

    return Map<String, bool>.from(jsonDecode(jsonStr));
  }

  // Toggle a specific item
  Future<void> toggleItem(String item) async {
    final currentState = getChecklistState();
    currentState[item] = !(currentState[item] ?? false);
    await _prefs.setString(_keyRecoveryState, jsonEncode(currentState));
  }
}

// --- Providers ---

final recoveryServiceProvider = Provider<RecoveryService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData!.value;
  return RecoveryService(prefs);
});

final recoveryChecklistProvider = StateNotifierProvider<RecoveryChecklistNotifier, Map<String, bool>>((ref) {
  return RecoveryChecklistNotifier(ref);
});

class RecoveryChecklistNotifier extends StateNotifier<Map<String, bool>> {
  final Ref _ref;

  RecoveryChecklistNotifier(this._ref) : super({}) {
    _loadState();
  }

  void _loadState() {
    final service = _ref.read(recoveryServiceProvider);
    state = service.getChecklistState();
  }

  Future<void> toggle(String item) async {
    final service = _ref.read(recoveryServiceProvider);
    await service.toggleItem(item);
    state = service.getChecklistState(); // Reload to update UI
  }
}

// Re-export shared preferences provider from stats service for simplicity, 
// or define a core one. For now, assuming stats_service defines it globally.
// If not, we'll need to duplicate or move it. 
// I'll re-declare strictly what I need here to be safe and independent.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
