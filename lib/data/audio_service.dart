import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

/// Service for audio cues and haptic feedback during workouts.
/// 
/// Provides interval transition sounds, countdown warnings,
/// and haptic feedback for a more immersive workout experience.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _isInitialized = false;

  /// Initialize the audio player
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _player = AudioPlayer();
      _isInitialized = true;
    } catch (e) {
      // Graceful degradation - audio will be disabled
      _isInitialized = false;
    }
  }

  /// Play a short beep for interval transitions
  Future<void> playIntervalBeep() async {
    await _triggerHaptic(HapticFeedbackType.medium);
    // Using system sounds instead of audio files for reliability
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play countdown warning (3, 2, 1)
  Future<void> playCountdownBeep() async {
    await _triggerHaptic(HapticFeedbackType.light);
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play completion sound
  Future<void> playCompletionSound() async {
    await _triggerHaptic(HapticFeedbackType.heavy);
    // Multiple clicks to indicate completion
    await SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 100));
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play start sound
  Future<void> playStartSound() async {
    await _triggerHaptic(HapticFeedbackType.medium);
    await SystemSound.play(SystemSoundType.click);
  }

  /// Trigger haptic feedback
  Future<void> _triggerHaptic(HapticFeedbackType type) async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) return;

      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (e) {
      // Graceful degradation - haptics will be disabled
    }
  }

  /// Vibrate for a specific duration (for interval transitions)
  Future<void> vibrate({int duration = 100}) async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      // Graceful degradation
    }
  }

  /// Dispose of audio player resources
  void dispose() {
    _player?.dispose();
    _player = null;
    _isInitialized = false;
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
}
