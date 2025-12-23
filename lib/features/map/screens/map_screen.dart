import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/geo_utils.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../models/route.dart' as route_model;
import '../providers/ride_providers.dart';
import '../services/cart_animation_service.dart';
import '../widgets/cart_info_card.dart';

/// Main map screen showing carts and user location
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Google Maps controller - lets us control the map programmatically
  GoogleMapController? _mapController;

  // Markers to display on the map (Google Maps uses Set for performance)
  // Built from cart data in providers
  Set<Marker> _markers = {};

  // Polygons to display on the map (service area boundary)
  Set<Polygon> _polygons = {};

  // Polylines to display on the map (route visualization)
  Set<Polyline> _polylines = {};

  // Location stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  // Cart animation stream subscription
  StreamSubscription? _animationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _createServiceArea();
    _loadCarts();
    _getUserLocation();
  }

  // Create service area polygon
  void _createServiceArea() {
    final serviceAreaPolygon = Polygon(
      polygonId: const PolygonId('service_area'),
      points: AppConstants.serviceAreaBoundary,
      fillColor: AppConstants.serviceAreaFillColor,
      strokeColor: AppConstants.serviceAreaBorderColor,
      strokeWidth: AppConstants.serviceAreaBorderWidth.toInt(),
    );

    setState(() {
      _polygons = {serviceAreaPolygon};
    });
  }

  // Load mock cart data and create markers
  void _loadCarts() {
    // Carts are already initialized in cartsProvider
    _createMarkers();
  }

  // Convert Cart objects to Map Markers
  void _createMarkers() {
    // Read carts from provider
    final carts = ref.read(cartsProvider);
    final selectedCart = ref.read(selectedCartProvider);
    final animatedPosition = ref.read(animatedCartPositionProvider);

    // Create cart markers
    final cartMarkers = carts.map((cart) {
      // Use animated position for selected cart if animation is running
      final position = (cart.id == selectedCart?.id && animatedPosition != null)
          ? animatedPosition
          : LatLng(cart.latitude, cart.longitude);

      // Highlight selected cart with different color
      final markerHue = (cart.id == selectedCart?.id)
          ? BitmapDescriptor.hueOrange // Active cart in orange
          : AppConstants.cartMarkerHue; // Available carts in green

      final snippet = (cart.id == selectedCart?.id) ? 'En route' : 'Available';

      return Marker(
        markerId: MarkerId(cart.id),
        position: position, // Dynamic position for active cart
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        infoWindow: InfoWindow(
          title: cart.name,
          snippet: snippet,
        ),
        onTap: () => _onCartTapped(cart),
      );
    }).toSet();

    // Create stadium marker
    final stadiumMarker = Marker(
      markerId: const MarkerId('stadium'),
      position: AppConstants.stadiumLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(AppConstants.stadiumMarkerHue),
      infoWindow: const InfoWindow(
        title: 'Great American Ball Park',
        snippet: 'Destination',
      ),
    );

    setState(() {
      _markers = {...cartMarkers, stadiumMarker};
    });
  }

  // Handle cart marker tap
  void _onCartTapped(Cart cart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cart.name} tapped!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Get user's current location and start listening for updates
  Future<void> _getUserLocation() async {
    try {
      // Get location service from provider
      final locationService = ref.read(locationServiceProvider);

      // First, get current position
      Position? position = await locationService.getCurrentLocation();

      if (position != null) {
        // Update position in provider
        ref.read(userPositionProvider.notifier).state = position;

        // Center map on user's location with animation
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0, // Slightly closer zoom when centered on user
          ),
        );

        // Check if outside service area
        final userLatLng = LatLng(position.latitude, position.longitude);
        final isInServiceArea = GeoUtils.isPointInPolygon(
          userLatLng,
          AppConstants.serviceAreaBoundary,
        );

        if (!isInServiceArea && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are outside the service area. We only serve downtown Cincinnati.'),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Start listening for position updates
        _startLocationStream();
      } else {
        // Permission denied or location unavailable
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please enable in settings.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Start listening to location updates
  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      // Update position in provider whenever location changes
      ref.read(userPositionProvider.notifier).state = position;
    });
  }

  @override
  void dispose() {
    // Cancel location stream when widget is disposed
    _positionStreamSubscription?.cancel();
    // Cancel animation stream when widget is disposed
    _animationStreamSubscription?.cancel();
    super.dispose();
  }

  // Called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Handle cancel request
  void _onCancelRequest() {
    final activeRequest = ref.read(activeRequestProvider);

    if (activeRequest != null) {
      // Stop animation
      _stopCartAnimation();

      // Clear the active request, selected cart, and route
      ref.read(activeRequestProvider.notifier).state = null;
      ref.read(selectedCartProvider.notifier).state = null;
      ref.read(activeRouteProvider.notifier).state = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Handle exit button (after ride completes)
  void _onExit() {
    // Stop any running animation
    _stopCartAnimation();

    // Clear all ride state
    ref.read(activeRequestProvider.notifier).state = null;
    ref.read(selectedCartProvider.notifier).state = null;
    ref.read(activeRouteProvider.notifier).state = null;
    ref.read(animatedCartPositionProvider.notifier).state = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ready for next ride!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Start cart animation along route
  void _startCartAnimation(Cart cart, route_model.Route route) {
    // Get animation service
    final animationService = ref.read(cartAnimationServiceProvider);

    // Start animation stream
    final animationStream = animationService.animateCartAlongRoute(
      routePoints: route.polylinePoints,
      speedMph: 15.0, // Base speed (will be 6x in service)
      pickupWaypoint: route.waypoints[1], // User pickup location
    );

    // Listen to animation state updates
    _animationStreamSubscription = animationStream.listen(
      (CartAnimationState state) {
        // Update animated position
        ref.read(animatedCartPositionProvider.notifier).state = state.position;

        // Check if cart reached pickup (transition to inProgress)
        if (state.hasReachedPickup) {
          final request = ref.read(activeRequestProvider);
          if (request != null && request.status == RequestStatus.assigned) {
            ref.read(activeRequestProvider.notifier).state = request.copyWith(
              status: RequestStatus.inProgress,
            );

            // Center camera on cart once picked up - keep following for rest of ride
            _followCart(state.position);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Picked up! Heading to stadium...'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        }

        // Keep following cart if ride is in progress
        final request = ref.read(activeRequestProvider);
        if (request != null && request.status == RequestStatus.inProgress) {
          _followCart(state.position);
        }

        // Check if animation completed (reached stadium)
        if (state.isComplete) {
          final request = ref.read(activeRequestProvider);
          if (request != null) {
            ref.read(activeRequestProvider.notifier).state = request.copyWith(
              status: RequestStatus.completed,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ride completed! Enjoy the game! 🎉'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
      },
      onError: (error) {
        // Animation error - silently handled
      },
      onDone: () {
        // Animation stream closed
      },
    );
  }

  // Stop cart animation
  void _stopCartAnimation() {
    // Cancel stream subscription
    _animationStreamSubscription?.cancel();
    _animationStreamSubscription = null;

    // Stop animation service
    ref.read(cartAnimationServiceProvider).stopAnimation();

    // Clear animated position
    ref.read(animatedCartPositionProvider.notifier).state = null;
  }

  // Follow cart with camera (simple, no interaction handling)
  void _followCart(LatLng cartPosition) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(cartPosition, 17.0), // Zoom closer to cart
    );
  }

  // Handle request pickup button tap
  Future<void> _onRequestPickup() async {
    // 1. Get user position from provider
    final userPos = ref.read(userPositionProvider);

    if (userPos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waiting for your location...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 2. Check if user is inside service area
    final userLatLng = LatLng(userPos.latitude, userPos.longitude);
    final isInServiceArea = GeoUtils.isPointInPolygon(
      userLatLng,
      AppConstants.serviceAreaBoundary,
    );

    if (!isInServiceArea) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sorry, you are outside the service area. We only serve downtown Cincinnati.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 3. Check if already has active request
    final activeRequest = ref.read(activeRequestProvider);
    if (activeRequest != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have an active request!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 4. Get available carts
    final carts = ref.read(cartsProvider);

    // 5. Find nearest cart using AssignmentService
    final assignmentService = ref.read(assignmentServiceProvider);
    final nearestCart = assignmentService.findNearestCart(userLatLng, carts);

    // 6. If no carts available, show error
    if (nearestCart == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No carts available right now. Please try again later.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 7. Create route from cart -> user -> stadium (using real roads)
    final cartLocation = LatLng(nearestCart.latitude, nearestCart.longitude);
    final route = await assignmentService.createRoute(
      cartId: nearestCart.id,
      cartLocation: cartLocation,
      pickupLocation: userLatLng,
      apiKey: AppConstants.googleMapsApiKey,
    );

    // 8. Check if route was successfully created
    if (route == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to calculate route. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return; // Don't create request if route failed
    }

    // 9. Calculate ETA
    final eta = route.estimatedDurationMinutes;

    // 10. Create ride request
    final request = assignmentService.createRequest(
      pickupLocation: userLatLng,
      partySize: 1,
      assignedCartId: nearestCart.id,
    );

    // 11. Update providers
    ref.read(activeRequestProvider.notifier).state = request.copyWith(
      status: RequestStatus.assigned,
    );
    ref.read(selectedCartProvider.notifier).state = nearestCart;
    ref.read(activeRouteProvider.notifier).state = route;

    // 12. Start cart animation
    _startCartAnimation(nearestCart, route);

    // 13. Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${nearestCart.name} assigned! Arriving in $eta min'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for button state
    final userPos = ref.watch(userPositionProvider);
    final activeRequest = ref.watch(activeRequestProvider);
    final activeRoute = ref.watch(activeRouteProvider);

    // Watch animated position to trigger marker rebuild
    ref.watch(animatedCartPositionProvider);

    // Rebuild markers when animated position changes
    _createMarkers();

    // Update polylines when route changes
    if (activeRoute != null) {
      final routePolyline = Polyline(
        polylineId: const PolylineId('active_route'),
        points: activeRoute.polylinePoints,
        color: Colors.blue.shade700, // Darker, more visible blue
        width: 5, // Thicker line
        // Solid line (no patterns) for better visibility
      );
      _polylines = {routePolyline};
    } else {
      _polylines = {};
    }

    // Determine button state and action
    VoidCallback? buttonAction;
    String buttonText = 'Request Pickup to Stadium';
    Color buttonColor = Colors.grey;
    IconData buttonIcon = Icons.sports_baseball;

    if (userPos == null) {
      buttonText = 'Getting your location...';
      buttonColor = Colors.grey;
      buttonAction = null;
    } else if (activeRequest != null) {
      // Check if ride is completed
      if (activeRequest.status == RequestStatus.completed) {
        buttonText = 'Exit';
        buttonColor = Colors.blue;
        buttonIcon = Icons.exit_to_app;
        buttonAction = _onExit;
      } else {
        // Active request - show cancel button
        buttonText = 'Cancel Request';
        buttonColor = Colors.red;
        buttonIcon = Icons.cancel;
        buttonAction = _onCancelRequest;
      }
    } else {
      final userLatLng = LatLng(userPos.latitude, userPos.longitude);
      final isInServiceArea = GeoUtils.isPointInPolygon(
        userLatLng,
        AppConstants.serviceAreaBoundary,
      );

      if (!isInServiceArea) {
        buttonText = 'Outside Service Area';
        buttonColor = Colors.red;
        buttonAction = null;
      } else {
        buttonText = 'Request Pickup to Stadium';
        buttonColor = Colors.green;
        buttonAction = _onRequestPickup;
      }
    }

    // Get selected cart and route for info card
    final selectedCart = ref.watch(selectedCartProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cart Tracker'),
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: AppConstants.initialCameraPosition,
            markers: _markers, // Display cart and stadium markers
            polygons: _polygons, // Display service area boundary
            polylines: _polylines, // Display route line
            myLocationButtonEnabled: true, // Shows recenter button (top right)
            myLocationEnabled: true, // Shows blue dot for user location
            mapType: MapType.normal,
          ),
          // Info card (shown when ride is active)
          if (activeRequest != null && activeRoute != null && selectedCart != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0, // At the top below app bar
              child: CartInfoCard(
                cart: selectedCart,
                request: activeRequest,
                route: activeRoute,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: buttonAction,
        icon: Icon(buttonIcon),
        label: Text(buttonText),
        backgroundColor: buttonColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
