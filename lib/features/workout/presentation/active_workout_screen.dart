import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../domain/models/training_program.dart';
import '../../../data/training_provider.dart';
import '../../../data/location_service.dart';
import '../../../data/stats_service.dart';
import '../../../data/haptic_service.dart';
import '../../../data/active_workout_provider.dart';
import 'workout_summary_screen.dart';
import '../../../core/constants/app_strings.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({required this.workoutId, super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> with WidgetsBindingObserver {
  late final HapticService _haptics;
  final MapController _mapController = MapController();
  
  bool _isCountingDown = false;
  int _countdownValue = 3;
  
  // Track previous interval to detect transitions
  int _lastIntervalIndex = 0;
  int _lastIntervalSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _haptics = ref.read(hapticServiceProvider);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceCoachServiceProvider).init();
      ref.read(activeWorkoutProvider.notifier).restoreIfAny();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermissionsAndStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showPermissionDialog(
        title: 'Location Services Disabled',
        content: 'Please enable location services to track your run.',
        onConfirm: () => Geolocator.openLocationSettings(),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showPermissionDialog(
          title: 'Permission Denied',
          content: 'RunLift needs location permission to calculate your distance and pace.',
          onConfirm: () => _checkPermissionsAndStart(),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showPermissionDialog(
        title: 'Permission Required',
        content: 'Location permission is permanently denied. Please enable it in app settings.',
        onConfirm: () => Geolocator.openAppSettings(),
      );
      return;
    }

    _startCountdown();
  }

  void _showPermissionDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i >= 1; i--) {
      setState(() => _countdownValue = i);
      _haptics.heavy();
      await ref.read(voiceCoachServiceProvider).speak('$i');
      await Future.delayed(const Duration(milliseconds: 700));
    }

    _haptics.success();
    await ref.read(voiceCoachServiceProvider).speak('Go!');
    
    setState(() => _isCountingDown = false);
    
    final trainingDay = ref.read(trainingDayByWorkoutIdProvider(widget.workoutId));
    final today = trainingDay ?? ref.read(trainingProvider).today;
    final workout = today.workout;
    
    await ref.read(activeWorkoutProvider.notifier).startWorkout(workout);
    
    if (workout.type == WorkoutType.run) {
      await ref.read(locationProvider.notifier).startTracking();
      
      // Announce first interval
      if (workout.intervals != null && workout.intervals!.isNotEmpty) {
        final interval = workout.intervals![0];
        final action = interval.type == IntervalType.run ? 'running' : 'walking';
        final mins = interval.duration.inMinutes;
        final secs = interval.duration.inSeconds % 60;
        if (mins > 0 && secs > 0) {
          await ref.read(voiceCoachServiceProvider).speak('Start $action for $mins minutes and $secs seconds.');
        } else if (mins > 0) {
          await ref.read(voiceCoachServiceProvider).speak('Start $action for $mins ${mins == 1 ? 'minute' : 'minutes'}.');
        } else {
          await ref.read(voiceCoachServiceProvider).speak('Start $action for $secs seconds.');
        }
      }
    }
  }

  void _handleIntervalTransitions(ActiveWorkoutState workoutState) {
    if (workoutState.workout == null) return;
    final intervals = workoutState.workout!.intervals;
    if (intervals == null || intervals.isEmpty) return;

    final currentIndex = workoutState.currentIntervalIndex;
    final secondsRemaining = workoutState.intervalSecondsRemaining;

    // 10 second warning
    if (secondsRemaining == 10 && _lastIntervalSeconds != 10) {
      _haptics.medium();
      ref.read(voiceCoachServiceProvider).speak('10 seconds.');
    }

    // 5-4-3-2-1 countdown with haptic each second
    if (secondsRemaining <= 5 && secondsRemaining > 0 && _lastIntervalSeconds != secondsRemaining) {
      _haptics.tap();
      if (secondsRemaining <= 3) {
        ref.read(voiceCoachServiceProvider).speak('$secondsRemaining');
      }
    }

    // Interval transition
    if (currentIndex != _lastIntervalIndex && currentIndex < intervals.length) {
      _haptics.heavy();
      final newInterval = intervals[currentIndex];
      final action = newInterval.type == IntervalType.run ? 'running' : 'walking';
      final mins = newInterval.duration.inMinutes;
      final secs = newInterval.duration.inSeconds % 60;
      
      String announcement = 'Set ${currentIndex + 1} of ${intervals.length}. Now $action';
      if (mins > 0 && secs > 0) {
        announcement += ' for $mins minutes and $secs seconds.';
      } else if (mins > 0) {
        announcement += ' for $mins ${mins == 1 ? 'minute' : 'minutes'}.';
      } else {
        announcement += ' for $secs seconds.';
      }
      ref.read(voiceCoachServiceProvider).speak(announcement);
    }

    _lastIntervalIndex = currentIndex;
    _lastIntervalSeconds = secondsRemaining;
  }

  Future<void> _finishWorkout() async {
    final workoutState = ref.read(activeWorkoutProvider);
    final locationState = ref.read(locationProvider);
    
    _haptics.success();
    await ref.read(voiceCoachServiceProvider).speak(AppStrings.workoutComplete);
    
    // Show RPE Check-in
    if (mounted) {
      final rpe = await _showRpePicker();
      if (rpe == null) return; // User cancelled
    }
    
    ref.read(locationProvider.notifier).stopTracking();
    ref.read(activeWorkoutProvider.notifier).stopWorkout();

    // Only update stats if we actually moved
    if (locationState.totalDistanceMeters > 50) {
      await ref.read(lifetimeStatsProvider.notifier).updateStats(
        distanceMeters: locationState.totalDistanceMeters,
      );
    }

    // Mark day as completed in training program
    final trainingDay = ref.read(trainingDayByWorkoutIdProvider(widget.workoutId));
    if (trainingDay != null) {
      await ref.read(trainingProvider.notifier).completeDay(trainingDay.dayNumber);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(
            workout: workoutState.workout!,
            durationSeconds: workoutState.elapsedSeconds,
            distanceMeters: locationState.totalDistanceMeters,
            routeHistory: locationState.routeHistory,
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace(double distanceMeters, int seconds) {
    // Don't show pace if we haven't moved at least 50 meters
    if (distanceMeters < 50 || seconds < 1) return '--:--';
    final km = distanceMeters / 1000;
    final minutes = seconds / 60;
    final pace = minutes / km;
    if (pace > 30) return '--:--'; // Cap unrealistic pace
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round();
    return '$paceMin:${paceSec.toString().padLeft(2, '0')}';
  }

  // Sanitize distance - GPS can drift, so filter out noise
  String _formatDistance(double distanceMeters) {
    if (distanceMeters < 10) return '0.00'; // Filter out GPS noise
    return (distanceMeters / 1000).toStringAsFixed(2);
  }

  // Sanitize speed - don't show unrealistic values
  String _formatSpeed(double speedKmph) {
    if (speedKmph < 0.5) return '0.0'; // Filter out noise when stationary
    if (speedKmph > 50) return '0.0'; // Cap unrealistic GPS spikes
    return speedKmph.toStringAsFixed(1);
  }



  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);
    final locationState = ref.watch(locationProvider);
    
    // Handle interval transitions with voice/haptics
    if (workoutState.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleIntervalTransitions(workoutState);
      });
    }
    
    if (workoutState.workout == null && !_isCountingDown) {
      return _buildPreparationUI();
    }

    if (_isCountingDown) {
      return _buildCountdownUI();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // MAP SECTION (Top 45%)
          Expanded(
            flex: 45,
            child: Stack(
              children: [
                _buildMap(locationState),
                _buildGradientOverlay(),
                _buildTopHUD(workoutState),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // STATS SECTION (Bottom 55%)
          Expanded(
            flex: 55,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Timer
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatTime(workoutState.elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 88,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Stats Row - with sanitized values
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        _formatDistance(locationState.totalDistanceMeters),
                        'KM',
                      ),
                      _buildStatItem(
                        _formatPace(locationState.totalDistanceMeters, workoutState.elapsedSeconds),
                        'PACE',
                      ),
                      _buildStatItem(
                        _formatSpeed(locationState.currentSpeedKmph),
                        'KM/H',
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildControls(workoutState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationUI() {
    final trainingDay = ref.read(trainingDayByWorkoutIdProvider(widget.workoutId));
    final today = trainingDay ?? ref.read(trainingProvider).today;
    final workout = today.workout;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.type.name.toUpperCase(),
              style: const TextStyle(color: AppTheme.primary, letterSpacing: 4, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              workout.name,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              workout.description,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            
            // Show interval breakdown if available
            if (workout.intervals != null && workout.intervals!.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  const Text(
                    'INTERVALS',
                    style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2),
                  ),
                  const Spacer(),
                  if (workout.intervalRepeats != null && workout.intervalRepeats! > 1)
                    Text(
                      '${workout.intervalRepeats} ROUNDS',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...workout.intervals!.take(5).map((interval) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      interval.type == IntervalType.run ? Icons.directions_run : Icons.directions_walk,
                      color: interval.type == IntervalType.run ? AppTheme.primary : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${interval.type == IntervalType.run ? 'Run' : 'Walk'} ${interval.duration.inMinutes > 0 ? '${interval.duration.inMinutes} min' : '${interval.duration.inSeconds} sec'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )),
              if (workout.intervals!.length > 5)
                Text(
                  '+${workout.intervals!.length - 5} more intervals',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
            ],
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _checkPermissionsAndStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('START WORKOUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownUI() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_countdownValue',
              style: const TextStyle(color: AppTheme.primary, fontSize: 160, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'READY?',
              style: TextStyle(color: Colors.white30, fontSize: 24, letterSpacing: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LocationState locationState) {
    if (locationState.currentLocation != null) {
      try {
        _mapController.move(locationState.currentLocation!, 16.0);
      } catch (_) {}
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: locationState.currentLocation ?? const LatLng(0, 0),
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: locationState.routeHistory,
              color: AppTheme.primary,
              strokeWidth: 4.0,
            ),
          ],
        ),
        if (locationState.currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: locationState.currentLocation!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withAlphaValue(0.5), blurRadius: 10, spreadRadius: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlphaValue(0.6),
            Colors.transparent,
            Colors.transparent,
            AppTheme.background,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildTopHUD(ActiveWorkoutState workoutState) {
    if (workoutState.workout == null) return const SizedBox.shrink();
    
    final intervals = workoutState.expandedIntervals ?? workoutState.workout!.intervals ?? [];
    if (intervals.isEmpty) return const SizedBox.shrink();
    
    if (workoutState.isCompleted || workoutState.currentIntervalIndex >= intervals.length) {
      // All intervals complete
      return Positioned(
        top: 48,
        left: 24,
        right: 24,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withAlphaValue(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'ALL INTERVALS COMPLETE!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      );
    }

    if (workoutState.currentIntervalIndex < 0 || workoutState.currentIntervalIndex >= intervals.length) {
      return const SizedBox.shrink();
    }

    final currentInterval = intervals[workoutState.currentIntervalIndex];
    final isRun = currentInterval.type == IntervalType.run;
    
    return Positioned(
      top: 48,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRun ? AppTheme.primary.withAlphaValue(0.9) : Colors.blue.withAlphaValue(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isRun ? Icons.directions_run : Icons.directions_walk,
              color: isRun ? Colors.black : Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRun ? 'RUNNING' : 'WALKING',
                    style: TextStyle(
                      color: isRun ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Round ${workoutState.currentRound} of ${workoutState.totalRounds}',
                    style: TextStyle(
                      color: isRun ? Colors.black54 : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(workoutState.intervalSecondsRemaining),
              style: TextStyle(
                color: isRun ? Colors.black : Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildControls(ActiveWorkoutState workoutState) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 64,
            child: OutlinedButton(
              onPressed: () {
                _haptics.medium();
                if (workoutState.isRunning) {
                  ref.read(activeWorkoutProvider.notifier).pauseWorkout();
                  ref.read(locationProvider.notifier).pauseTracking();
                  ref.read(voiceCoachServiceProvider).speak('Paused');
                } else {
                  ref.read(activeWorkoutProvider.notifier).resumeWorkout();
                  ref.read(locationProvider.notifier).resumeTracking();
                  ref.read(voiceCoachServiceProvider).speak('Resuming');
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Icon(
                workoutState.isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                _haptics.heavy();
                _showFinishConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('FINISH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Future<int?> _showRpePicker() async {
    int selectedRpe = 5;
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Rate Your Effort', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How intense was this workout?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Text(
                '$selectedRpe',
                style: const TextStyle(color: AppTheme.primary, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                selectedRpe <= 3 ? 'EASY' : selectedRpe <= 6 ? 'MODERATE' : selectedRpe <= 8 ? 'HARD' : 'MAX EFFORT',
                style: TextStyle(
                  color: selectedRpe <= 3 ? Colors.green : selectedRpe <= 6 ? Colors.yellow : Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Slider(
                value: selectedRpe.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppTheme.primary,
                onChanged: (val) => setState(() => selectedRpe = val.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selectedRpe),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('FINISH', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Finish Workout?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to end this workout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('FINISH', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
