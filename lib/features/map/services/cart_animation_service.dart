import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route.dart';

/// Service for animating cart movement along routes
class CartAnimationService {
  Timer? _animationTimer;
  StreamController<CartAnimationState>? _stateController;
  bool _isPaused = false;

  /// Debug speed multiplier (4x = four times as fast)
  /// Set to 1.0 for realistic speed, 2.0 for demo, 4.0 for faster demo (default)
  static const double speedMultiplier = 8.0;

  /// How long to pause at pickup location (seconds)
  static const int pickupPauseDuration = 5;

  /// Update frequency in milliseconds (100ms = 10 updates per second for smooth animation)
  static const int updateIntervalMs = 100;

  /// Animate cart along route at realistic speed
  ///
  /// [routePoints] - Polyline points from Directions API
  /// [speedMph] - Base speed (will be multiplied by speedMultiplier)
  /// [pickupWaypoint] - Location where cart picks up user (triggers pause)
  ///
  /// Returns stream of animation states (position + metadata)
  Stream<CartAnimationState> animateCartAlongRoute({
    required List<LatLng> routePoints,
    required double speedMph,
    required LatLng pickupWaypoint,
  }) {
    // Clean up any existing animation
    stopAnimation();

    // Create stream controller
    _stateController = StreamController<CartAnimationState>();

    // Calculate total route distance
    double totalDistance = 0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance +=
          Route.calculateDistance(routePoints[i], routePoints[i + 1]);
    }

    // Apply speed multiplier (4x realistic speed for demo)
    final adjustedSpeedMph = speedMph * speedMultiplier;

    // Convert speed to meters per second
    final speedMps = adjustedSpeedMph * 0.44704; // mph to m/s

    // How far cart moves per update (based on update interval)
    final updateIntervalSeconds = updateIntervalMs / 1000.0;
    final distancePerUpdate = speedMps * updateIntervalSeconds; // meters

    // Track progress
    double currentDistance = 0;
    LatLng currentPosition = routePoints[0];
    bool hasReachedPickup = false;
    DateTime? pickupPauseStartTime;

    // Update at configured interval (100ms = smooth animation)
    _animationTimer = Timer.periodic(Duration(milliseconds: updateIntervalMs), (timer) {
      // Handle pickup pause
      if (_isPaused && pickupPauseStartTime != null) {
        final pauseDuration = DateTime.now().difference(pickupPauseStartTime!);
        if (pauseDuration.inSeconds >= pickupPauseDuration) {
          // Resume after pause
          _isPaused = false;
          pickupPauseStartTime = null;

          // Emit state showing pickup complete
          if (!_stateController!.isClosed) {
            _stateController!.add(CartAnimationState(
              position: currentPosition,
              distanceTraveled: currentDistance,
              totalDistance: totalDistance,
              hasReachedPickup: true,
              isComplete: false,
            ));
          }
        }
        return; // Don't move during pause
      }

      // Move cart forward
      currentDistance += distancePerUpdate;

      // Find current position along route
      double accumulatedDistance = 0;

      for (int i = 0; i < routePoints.length - 1; i++) {
        final segmentDistance = Route.calculateDistance(
          routePoints[i],
          routePoints[i + 1],
        );

        if (accumulatedDistance + segmentDistance >= currentDistance) {
          // We're in this segment
          final remainingInSegment = currentDistance - accumulatedDistance;
          final progress = remainingInSegment / segmentDistance;

          // Interpolate position (smooth movement between points)
          currentPosition = _lerp(
            routePoints[i],
            routePoints[i + 1],
            progress,
          );

          break;
        }

        accumulatedDistance += segmentDistance;
      }

      // Check if reached pickup location (within 20 meters)
      if (!hasReachedPickup &&
          _isNearLocation(currentPosition, pickupWaypoint, 20.0)) {
        hasReachedPickup = true;
        _isPaused = true;
        pickupPauseStartTime = DateTime.now();

        // Emit state showing reached pickup
        if (!_stateController!.isClosed) {
          _stateController!.add(CartAnimationState(
            position: currentPosition,
            distanceTraveled: currentDistance,
            totalDistance: totalDistance,
            hasReachedPickup: true,
            isComplete: false,
          ));
        }
        return;
      }

      // Emit new position
      if (!_stateController!.isClosed) {
        _stateController!.add(CartAnimationState(
          position: currentPosition,
          distanceTraveled: currentDistance,
          totalDistance: totalDistance,
          hasReachedPickup: hasReachedPickup,
          isComplete: false,
        ));
      }

      // Check if completed (reached destination)
      if (currentDistance >= totalDistance) {
        // Emit final state at exact destination
        if (!_stateController!.isClosed) {
          _stateController!.add(CartAnimationState(
            position: routePoints.last,
            distanceTraveled: totalDistance,
            totalDistance: totalDistance,
            hasReachedPickup: true,
            isComplete: true,
          ));
        }
        stopAnimation();
      }
    });

    return _stateController!.stream;
  }

  /// Linear interpolation between two LatLng points
  LatLng _lerp(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  /// Check if position is near target location
  bool _isNearLocation(LatLng position, LatLng target, double thresholdMeters) {
    final distance = Route.calculateDistance(position, target);
    return distance < thresholdMeters;
  }

  /// Stop animation and clean up
  void stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _isPaused = false;

    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.close();
    }
    _stateController = null;
  }

  /// Clean up on service disposal
  void dispose() {
    stopAnimation();
  }
}

/// State of cart animation
class CartAnimationState {
  final LatLng position;
  final double distanceTraveled; // meters
  final double totalDistance; // meters
  final bool hasReachedPickup;
  final bool isComplete;

  const CartAnimationState({
    required this.position,
    required this.distanceTraveled,
    required this.totalDistance,
    required this.hasReachedPickup,
    required this.isComplete,
  });

  /// Progress as percentage (0.0 to 1.0)
  double get progress => totalDistance > 0 ? distanceTraveled / totalDistance : 0.0;

  /// Remaining distance in meters
  double get remainingDistance => totalDistance - distanceTraveled;
}
