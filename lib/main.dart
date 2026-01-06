import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/notification_service.dart';

void main() {
  runApp(const ProviderScope(child: AppBootloader()));
}

class AppBootloader extends ConsumerStatefulWidget {
  const AppBootloader({super.key});

  @override
  ConsumerState<AppBootloader> createState() => _AppBootloaderState();
}

class _AppBootloaderState extends ConsumerState<AppBootloader> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Core Firebase (CRITICAL - must succeed)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Non-critical services - catch and continue
    // Notifications are nice-to-have, not required for app to work
    try {
      await ref.read(notificationSettingsProvider.future);
    } catch (e) {
      // Notification init failed - log but don't crash
      debugPrint('Notification init failed (non-fatal): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplayScreen(error: snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const RunLiftApp();
          }
          return const LoadingScreen();
        },
      ),
    );
  }
}

class RunLiftApp extends ConsumerWidget {
  const RunLiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'RunLift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Image.asset('assets/icon/app_icon.png', width: 120, height: 120),
                const SizedBox(height: 24),
                const Text('RUNLIFT', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
                const SizedBox(height: 48),
                const CircularProgressIndicator(color: AppTheme.primary),
            ],
        ),
      ),
    );
  }
}

class ErrorDisplayScreen extends StatelessWidget {
  final String error;
  const ErrorDisplayScreen({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INITIALIZATION ERROR',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please restart the app. If this persists, try:\n• Check your internet connection\n• Reinstall the app',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
