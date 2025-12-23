import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../models/route.dart';

/// Service for assigning carts to ride requests
class AssignmentService {
  final _uuid = const Uuid();

  /// Find the nearest available cart to a pickup location
  ///
  /// Returns null if no carts are available
  Cart? findNearestCart(
    LatLng pickupLocation,
    List<Cart> availableCarts,
  ) {
    if (availableCarts.isEmpty) {
      return null;
    }

    Cart? nearestCart;
    double minDistance = double.infinity;

    for (final cart in availableCarts) {
      final cartLocation = LatLng(cart.latitude, cart.longitude);
      final distance = _calculateDistance(pickupLocation, cartLocation);

      if (distance < minDistance) {
        minDistance = distance;
        nearestCart = cart;
      }
    }

    return nearestCart;
  }

  /// Create a new ride request
  RideRequest createRequest({
    required LatLng pickupLocation,
    required int partySize,
    String? assignedCartId,
  }) {
    return RideRequest(
      id: _uuid.v4(),
      pickupLocation: pickupLocation,
      dropoffLocation: AppConstants.stadiumLocation,
      partySize: partySize,
      requestTime: DateTime.now(),
      status: assignedCartId != null ? RequestStatus.assigned : RequestStatus.pending,
      assignedCartId: assignedCartId,
    );
  }

  /// Create a route for a cart to follow using real roads
  ///
  /// Waypoints: [cart location] -> [pickup location] -> [stadium]
  /// Returns null if unable to fetch route from Directions API
  Future<Route?> createRoute({
    required String cartId,
    required LatLng cartLocation,
    required LatLng pickupLocation,
    required String apiKey,
  }) async {
    final waypoints = [
      cartLocation, // Start at cart's current location
      pickupLocation, // Pick up user
      AppConstants.stadiumLocation, // Drop off at stadium
    ];

    return await Route.createRoute(
      id: '${cartId}_route_${DateTime.now().millisecondsSinceEpoch}',
      waypoints: waypoints,
      apiKey: apiKey,
      averageSpeedMph: 15.0, // Golf cart average speed
    );
  }

  /// Calculate estimated time of arrival (ETA) in minutes
  ///
  /// Based on distance and average cart speed
  int calculateETA(Cart cart, LatLng pickupLocation) {
    final cartLocation = LatLng(cart.latitude, cart.longitude);
    final distanceMeters = _calculateDistance(cartLocation, pickupLocation);

    // Average cart speed: 15 mph = 6.7056 m/s
    const speedMetersPerSecond = 6.7056;
    final etaSeconds = distanceMeters / speedMetersPerSecond;

    // Round up to nearest minute
    return (etaSeconds / 60).ceil();
  }

  /// Calculate distance between two points in meters
  /// Using Haversine formula
  double _calculateDistance(LatLng start, LatLng end) {
    // Reuse the calculation from Route model
    return Route.calculateDistance(start, end);
  }
}
