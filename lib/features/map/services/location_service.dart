import 'package:geolocator/geolocator.dart';

/// Service for handling user location and permissions
class LocationService {
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission from the user
  /// Returns true if permission is granted
  Future<bool> requestPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, user needs to enable them
      return false;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // If denied, request permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied by user
        return false;
      }
    }

    // Check if permission is permanently denied
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, user must enable in settings
      return false;
    }

    // Permission granted (either whileInUse or always)
    return true;
  }

  /// Get the user's current location
  /// Returns null if permission is not granted or location unavailable
  Future<Position?> getCurrentLocation() async {
    try {
      // Request permission first
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      // Handle any errors (e.g., timeout, location unavailable)
      // Return null to indicate location unavailable
      return null;
    }
  }

  /// Calculate distance between two points in meters
  /// Useful for showing "X miles away" later
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Convert meters to miles
  double metersToMiles(double meters) {
    return meters * 0.000621371;
  }
}
