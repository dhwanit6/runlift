import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  /// A light tap, for UI selections.
  void tap() {
    HapticFeedback.lightImpact();
  }

  /// A medium impact, for general actions.
  void medium() {
    HapticFeedback.mediumImpact();
  }

  /// A heavy impact, for major events like starting/stopping.
  void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// A success pattern, for workout completion.
  void success() {
    // Native haptics don't have a "success" pattern, so we simulate with a heavy impact.
    HapticFeedback.heavyImpact();
  }
}

// --- Provider ---

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
