import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await plugin?.requestNotificationsPermission() ?? false;
  }

  /// Check if exact alarms are permitted (Android 12+)
  Future<bool> _canScheduleExactAlarms() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (plugin == null) return false;
    try {
      return await plugin.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleDailyBriefing({required int hour, required int minute}) async {
    await init();
    
    // Check if exact alarms are permitted (Android 12+ requirement)
    final canUseExact = await _canScheduleExactAlarms();
    
    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        'MISSION BRIEFING',
        'Your training protocols are ready. Tap to execute.',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_briefing',
            'Daily Briefing',
            channelDescription: 'Daily training reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        // Use inexact scheduling if exact alarms not permitted
        androidScheduleMode: canUseExact 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Silently fail if scheduling fails - notifications are non-critical
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

// --- Providers ---

// Re-export for global access
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

// AsyncNotifier for safe, robust initialization and state management
final notificationSettingsProvider = AsyncNotifierProvider<NotificationSettingsNotifier, bool>(NotificationSettingsNotifier.new);

class NotificationSettingsNotifier extends AsyncNotifier<bool> {
  late SharedPreferences _prefs;
  late NotificationService _service;

  @override
  Future<bool> build() async {
    // Safely await dependencies
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    _service = NotificationService();
    
    try {
      await _service.init();
      // Request permissions on first load of this provider
      await _service.requestPermissions();
    } catch (_) {
      // Non-fatal: app works without notifications
    }

    final isEnabled = _prefs.getBool('notifications_enabled') ?? true;
    
    // Schedule notifications based on the loaded setting
    if (isEnabled) {
      try {
        await _service.scheduleDailyBriefing(hour: 7, minute: 0);
      } catch (_) {
        // Non-fatal: continue without scheduled notifications
      }
    } else {
      await _service.cancelAll();
    }

    return isEnabled;
  }

  Future<void> toggle(bool value) async {
    state = const AsyncValue.loading();
    await _prefs.setBool('notifications_enabled', value);
    if (value) {
      try {
        await _service.scheduleDailyBriefing(hour: 7, minute: 0);
      } catch (_) {}
    } else {
      await _service.cancelAll();
    }
    state = AsyncValue.data(value);
  }
}
