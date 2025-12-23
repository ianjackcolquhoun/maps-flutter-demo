import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/directions_service.dart';

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

  /// Create a route using Google Directions API (real roads)
  ///
  /// Returns null if unable to fetch route from API
  static Future<Route?> createRoute({
    required String id,
    required List<LatLng> waypoints,
    required String apiKey,
    double averageSpeedMph = 15.0,
  }) async {
    if (waypoints.length < 2) {
      return null; // Need at least origin and destination
    }

    final directionsService = DirectionsService();

    // Fetch real road route from Google Directions API
    final polylinePoints = await directionsService.getRoutePolyline(
      origin: waypoints.first,
      destination: waypoints.last,
      waypoints:
          waypoints.length > 2 ? waypoints.sublist(1, waypoints.length - 1) : null,
      apiKey: apiKey,
    );

    // Return null if API failed
    if (polylinePoints == null || polylinePoints.isEmpty) {
      return null;
    }

    // Calculate total distance using polyline points
    double totalDistance = 0;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      totalDistance += calculateDistance(polylinePoints[i], polylinePoints[i + 1]);
    }

    // Calculate estimated duration based on distance and speed
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
