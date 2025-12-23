import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geolocation utility functions
class GeoUtils {
  // Prevent instantiation
  GeoUtils._();

  /// Check if a point is inside a polygon using ray casting algorithm
  ///
  /// Returns true if the point is inside the polygon, false otherwise.
  ///
  /// Algorithm: Cast a ray from the point to infinity and count how many
  /// times it crosses the polygon boundary. If odd, point is inside.
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      // Check if point's latitude is between the edge's latitudes
      if ((polygon[i].latitude > point.latitude) !=
          (polygon[j].latitude > point.latitude)) {
        // Calculate the x-coordinate of the intersection point
        double intersectionLng = (polygon[j].longitude - polygon[i].longitude) *
                (point.latitude - polygon[i].latitude) /
                (polygon[j].latitude - polygon[i].latitude) +
            polygon[i].longitude;

        // If point's longitude is less than intersection, flip inside flag
        if (point.longitude < intersectionLng) {
          inside = !inside;
        }
      }
      j = i;
    }

    return inside;
  }

  /// Calculate the center point of a polygon
  ///
  /// Returns the geographic center (centroid) of the polygon
  static LatLng getPolygonCenter(List<LatLng> polygon) {
    if (polygon.isEmpty) {
      return const LatLng(0, 0);
    }

    double latitude = 0;
    double longitude = 0;

    for (final point in polygon) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(
      latitude / polygon.length,
      longitude / polygon.length,
    );
  }
}
