import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../domain/models/training_program.dart';

enum TtsState { playing, stopped, paused, continued }

/// Premium voice coach service with natural-sounding voice
class VoiceCoachService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;


  VoiceCoachService() {
    _flutterTts = FlutterTts();
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Get available voices and pick a premium one
      List<dynamic> voices = await _flutterTts.getVoices ?? [];
      
      // Try to find a premium/natural voice
      // Priority: Google voices > Microsoft voices > System voices
      String? bestVoice;
      
      for (var voice in voices) {
        final name = voice['name']?.toString().toLowerCase() ?? '';
        final locale = voice['locale']?.toString() ?? '';
        
        // Skip non-English voices
        if (!locale.startsWith('en')) continue;
        
        // Prioritize natural/neural voices
        if (name.contains('neural') || name.contains('natural') || name.contains('wavenet')) {
          bestVoice = voice['name'];
          break;
        }
        // Fallback to Google voices
        if (bestVoice == null && (name.contains('google') || name.contains('samantha'))) {
          bestVoice = voice['name'];
        }
        // Fallback to any English voice
        bestVoice ??= voice['name'];
      }
      
      if (bestVoice != null) {
        await _flutterTts.setVoice({'name': bestVoice, 'locale': 'en-US'});

      }
      
      // Set language
      await _flutterTts.setLanguage("en-US");
      
      // Natural speech settings
      await _flutterTts.setSpeechRate(0.5); // Slightly faster for natural flow
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0); // Natural pitch
      
      // Platform-specific settings
      if (!kIsWeb) {
        if (Platform.isIOS) {
          await _flutterTts.setSharedInstance(true);
          // iOS: Use Siri voice if available, and allow background playback
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowAirPlay,
            ],
            IosTextToSpeechAudioMode.voicePrompt,
          );
        }
        if (Platform.isAndroid) {
          // Android: Request Google TTS engine
          await _flutterTts.setEngine('com.google.android.tts');
          // Add silence to keep audio session active if needed
        }
      }

      _isInitialized = true;
    } catch (e) {
      // Fallback to basic init if premium fails
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  /// Speaks a given text string with natural coaching style
  Future<void> speak(String text, {bool awaitSpeak = true}) async {
    if (!_isInitialized) await init();

    await _flutterTts.awaitSpeakCompletion(awaitSpeak);
    await _flutterTts.speak(text);
  }

  /// Stops any currently speaking audio
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Speaks the countdown (3, 2, 1) with energy
  Future<void> countdown() async {
    await speak("3", awaitSpeak: true);
    await Future.delayed(const Duration(milliseconds: 800));
    await speak("2", awaitSpeak: true);
    await Future.delayed(const Duration(milliseconds: 800));
    await speak("1", awaitSpeak: true);
    await Future.delayed(const Duration(milliseconds: 500));
    await speak("Go!", awaitSpeak: false);
  }
  
  /// Motivates the runner with a random phrase
  Future<void> motivate() async {
    final phrases = [
      "You're doing great!",
      "Keep pushing!",
      "Stay strong!",
      "Almost there!",
      "You've got this!",
      "Focus on your breath.",
      "Every step counts.",
    ];
    final phrase = phrases[DateTime.now().millisecond % phrases.length];
    await speak(phrase, awaitSpeak: false);
  }

  /// Announces the start of a new interval
  Future<void> announceInterval(RunInterval interval) async {
    String message = "";
    if (interval.type == IntervalType.warmup) {
      message = "Let's get started with a warmup... Get your heart rate up slowly.";
    } else if (interval.type == IntervalType.run) {
      message = "Time to run... Focus on your form and keep a steady pace.";
    } else if (interval.type == IntervalType.walk) {
      message = "Walk break... Catch your breath and prepare for the next round.";
    } else if (interval.type == IntervalType.cooldown) {
      message = "Starting cooldown... Excellent work today, you're all done.";
    }

    if (interval.duration.inSeconds > 0) {
      final mins = interval.duration.inMinutes;
      final secs = interval.duration.inSeconds % 60;
      if (mins > 0 && secs > 0) {
        message += " for $mins minutes and $secs seconds.";
      } else if (mins > 0) {
        message += " for $mins minute${mins > 1 ? 's' : ''}.";
      } else {
        message += " for $secs seconds.";
      }
    }

    await speak(message, awaitSpeak: false);
  }

  /// Halfway mark announcement
  Future<void> announceHalfway() async {
    await speak("You're halfway through this interval... Keep pushing, you've got this.", awaitSpeak: false);
  }

  /// Countdown for final seconds of an interval
  Future<void> announceFinalSeconds(int seconds) async {
    if (seconds <= 0) return;
    await speak("$seconds", awaitSpeak: true);
  }

  /// Properly disposes of the TTS engine
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
