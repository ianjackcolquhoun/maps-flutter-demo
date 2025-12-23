import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a route for a cart to follow
/// Includes waypoints (stops) and detailed path for visualization
class Route {
  final String id;
  final List<LatLng> waypoints;
  final List<LatLng> polylinePoints;
  final double estimatedDistanceMeters;
  final int estimatedDurationSeconds;

  const Route({
    required this.id,
    required this.waypoints,
    required this.polylinePoints,
    required this.estimatedDistanceMeters,
    required this.estimatedDurationSeconds,
  });

  /// Get estimated duration in minutes
  int get estimatedDurationMinutes {
    return (estimatedDurationSeconds / 60).ceil();
  }

  /// Get estimated distance in miles
  double get estimatedDistanceMiles {
    return estimatedDistanceMeters * 0.000621371;
  }

  /// Create a simple route from waypoints
  /// For MVP, we'll create straight lines between points
  factory Route.fromWaypoints({
    required String id,
    required List<LatLng> waypoints,
    double averageSpeedMph = 15.0, // Average cart speed
  }) {
    // For MVP, polyline points are just the waypoints
    // In production, you'd use Google Directions API for actual roads
    final polylinePoints = waypoints;

    // Calculate total distance
    double totalDistance = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      totalDistance += calculateDistance(waypoints[i], waypoints[i + 1]);
    }

    // Calculate estimated duration based on distance and speed
    // Convert mph to meters per second: mph * 0.44704
    final speedMetersPerSecond = averageSpeedMph * 0.44704;
    final estimatedSeconds = (totalDistance / speedMetersPerSecond).round();

    return Route(
      id: id,
      waypoints: waypoints,
      polylinePoints: polylinePoints,
      estimatedDistanceMeters: totalDistance,
      estimatedDurationSeconds: estimatedSeconds,
    );
  }

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in meters
  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters

    final lat1 = start.latitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final lon1 = start.longitude * (math.pi / 180);
    final lon2 = end.longitude * (math.pi / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  @override
  String toString() {
    return 'Route(id: $id, waypoints: ${waypoints.length}, distance: ${estimatedDistanceMiles.toStringAsFixed(2)} mi, duration: $estimatedDurationMinutes min)';
  }
}
