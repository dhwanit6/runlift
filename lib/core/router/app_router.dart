import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/goal_selection_screen.dart';
import '../../features/onboarding/presentation/fitness_check_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/today_screen.dart';
import '../../features/workout/presentation/active_workout_screen.dart';
import '../../features/program/presentation/program_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

/// Auth state stream for router refreshing
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
}

final _authNotifier = AuthNotifier();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: _authNotifier,
    
    // Redirect logic based on auth state
    redirect: (context, state) {
      final isAuthenticated = _authNotifier.isAuthenticated;
      final currentPath = state.matchedLocation;
      
      // Public routes that don't require authentication
      final isPublicRoute = currentPath == '/welcome' ||
                            currentPath == '/login' ||
                            currentPath == '/signup' ||
                            currentPath.startsWith('/onboarding');
      
      // If user is authenticated and on login/signup/welcome, redirect to app
      if (isAuthenticated && 
          (currentPath == '/welcome' || currentPath == '/login' || currentPath == '/signup')) {
        return '/today';
      }
      
      // If user is not authenticated and trying to access protected routes
      if (!isAuthenticated && !isPublicRoute) {
        return '/welcome';
      }
      
      return null; // No redirect needed
    },
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route not found: ${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('GO HOME'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // ==================== ONBOARDING FLOW ====================
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/fitness',
        builder: (context, state) => const FitnessCheckScreen(),
      ),

      // ==================== AUTHENTICATION ====================
      GoRoute(
        path: '/auth',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ==================== MAIN APP SHELL ====================
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/program',
            builder: (context, state) => const ProgramScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ==================== ACTIVE WORKOUT (FULLSCREEN) ====================
      GoRoute(
        path: '/workout/:workoutId',
        builder: (context, state) {
          final workoutId = state.pathParameters['workoutId'] ?? 'unknown';
          return ActiveWorkoutScreen(workoutId: workoutId);
        },
      ),
    ],
  );
});
