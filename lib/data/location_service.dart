import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// -----------------------------------------------------------------------------
// MODEL: Location State
// -----------------------------------------------------------------------------
class LocationState {
  final LatLng? currentLocation;
  final List<LatLng> routeHistory;
  final double totalDistanceMeters;
  final double currentSpeedKmph;
  final bool isTracking;
  final String? error;

  const LocationState({
    this.currentLocation,
    this.routeHistory = const [],
    this.totalDistanceMeters = 0.0,
    this.currentSpeedKmph = 0.0,
    this.isTracking = false,
    this.error,
  });

  LocationState copyWith({
    LatLng? currentLocation,
    List<LatLng>? routeHistory,
    double? totalDistanceMeters,
    double? currentSpeedKmph,
    bool? isTracking,
    String? error,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      routeHistory: routeHistory ?? this.routeHistory,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      currentSpeedKmph: currentSpeedKmph ?? this.currentSpeedKmph,
      isTracking: isTracking ?? this.isTracking,
      error: error,
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE: Location Tracker (using Notifier instead of StateNotifier)
// -----------------------------------------------------------------------------
class LocationNotifier extends Notifier<LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  LocationState build() {
    ref.onDispose(() {
      _positionStreamSubscription?.cancel();
    });
    return const LocationState();
  }

  /// Request permissions and start tracking
  Future<void> startTracking() async {
    state = state.copyWith(error: null);

    if (kIsWeb) {
      state = state.copyWith(error: 'GPS tracking unavailable in browser. Use the mobile app for full features.');
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(error: 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(error: 'LOCATION_DENIED');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(error: 'LOCATION_PERMANENTLY_DENIED');
        return;
      }

      state = state.copyWith(isTracking: true, error: null);

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        // For Android: check foreground service
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        _updatePosition(position);
      }, onError: (e) {
        state = state.copyWith(error: 'GPS tracking lost: $e');
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to start tracking: $e');
    }
  }

  void _updatePosition(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);
    final currentSpeed = (position.speed * 3.6);

    List<LatLng> newHistory = List.from(state.routeHistory);
    double newDistance = state.totalDistanceMeters;

    if (newHistory.isNotEmpty) {
      final lastPoint = newHistory.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
      
      if (distance > 2) { 
        newDistance += distance;
        newHistory.add(newPoint);
      }
    } else {
      newHistory.add(newPoint);
    }

    state = state.copyWith(
      currentLocation: newPoint,
      routeHistory: newHistory,
      totalDistanceMeters: newDistance,
      currentSpeedKmph: currentSpeed < 0 ? 0 : currentSpeed,
    );
  }

  void pauseTracking() {
    _positionStreamSubscription?.pause();
    state = state.copyWith(isTracking: false);
  }

  void resumeTracking() {
    _positionStreamSubscription?.resume();
    state = state.copyWith(isTracking: true);
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    state = const LocationState();
  }
}

// -----------------------------------------------------------------------------
// PROVIDER
// -----------------------------------------------------------------------------
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);
