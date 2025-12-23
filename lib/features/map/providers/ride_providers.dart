import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../models/route.dart';
import '../services/location_service.dart';
import '../services/assignment_service.dart';
import '../services/cart_animation_service.dart';

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

/// Provider for the current active route
/// null when no active route
final activeRouteProvider = StateProvider<Route?>((ref) {
  return null; // No active route initially
});

/// Provider for CartAnimationService - handles cart movement animation
final cartAnimationServiceProvider = Provider<CartAnimationService>((ref) {
  final service = CartAnimationService();
  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Provider for the animated cart position
/// Updated in real-time as cart moves along route
/// null when no animation is running
final animatedCartPositionProvider = StateProvider<LatLng?>((ref) {
  return null; // No animated position initially
});

/// Provider for camera following state
/// When true, camera automatically follows the animated cart
/// When false, user has manually panned/zoomed and camera stays put
final isFollowingCartProvider = StateProvider<bool>((ref) {
  return true; // Start following when animation begins
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
