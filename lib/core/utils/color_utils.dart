import 'package:flutter/material.dart';

/// Utility extensions for modern Flutter 3.x color manipulation.
/// Replaces deprecated withOpacity, .red, .green, .blue with the new API.
extension ColorUtils on Color {
  /// Returns a new color with the specified alpha (0.0 to 1.0).
  /// Uses the modern Color API instead of deprecated .red, .green, .blue.
  Color withAlphaValue(double alpha) {
    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      alpha,
    );
  }
}
