import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for fetching real road routes from Google Directions API
class DirectionsService {
  final PolylinePoints _polylinePoints = PolylinePoints();

  /// Get route polyline following real roads
  ///
  /// Returns null if unable to fetch route
  Future<List<LatLng>?> getRoutePolyline({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    required String apiKey,
  }) async {
    try {
      // Build waypoints list if provided
      List<PolylineWayPoint>? waypointList;
      if (waypoints != null && waypoints.isNotEmpty) {
        waypointList = waypoints
            .map((point) => PolylineWayPoint(
                  location: "${point.latitude},${point.longitude}",
                ))
            .toList();
      }

      // Call Google Directions API
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: apiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: waypointList ?? [],
        ),
      );

      // Check if we got valid points
      if (result.points.isNotEmpty) {
        // Convert PointLatLng to LatLng
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }

      // No points returned - API failed
      print('Directions API returned no points');
      return null;
    } catch (e) {
      // API call failed
      print('Directions API error: $e');
      return null;
    }
  }
}
