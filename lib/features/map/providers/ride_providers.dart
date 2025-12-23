import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../services/location_service.dart';
import '../services/assignment_service.dart';

/// Provider for LocationService - single instance shared across app
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for AssignmentService - handles cart assignment logic
final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  return AssignmentService();
});

/// Provider for user's current position
/// StateProvider allows us to read and update the value
final userPositionProvider = StateProvider<Position?>((ref) {
  return null; // Initially null until we get user location
});

/// Provider for list of available carts
/// We'll update this when carts move during simulation
final cartsProvider = StateProvider<List<Cart>>((ref) {
  return Cart.getMockCarts(); // Start with mock data
});

/// Provider for the selected/assigned cart (when user requests a ride)
final selectedCartProvider = StateProvider<Cart?>((ref) {
  return null; // No cart selected initially
});

/// Provider for the current active ride request
/// null when no active request
final activeRequestProvider = StateProvider<RideRequest?>((ref) {
  return null; // No active request initially
});

// Example of reading providers:
//
// In a ConsumerWidget:
//   final userPos = ref.watch(userPositionProvider);
//   final carts = ref.watch(cartsProvider);
//
// To update:
//   ref.read(userPositionProvider.notifier).state = newPosition;
//   ref.read(hasActiveRequestProvider.notifier).state = true;
