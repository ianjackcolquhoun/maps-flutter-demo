import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/geo_utils.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../providers/ride_providers.dart';

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

  // Location stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

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

    // Create cart markers
    final cartMarkers = carts.map((cart) {
      return Marker(
        markerId: MarkerId(cart.id),
        position: LatLng(cart.latitude, cart.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(AppConstants.cartMarkerHue),
        infoWindow: InfoWindow(
          title: cart.name,
          snippet: 'Tap for details',
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
      // Clear the active request and selected cart
      ref.read(activeRequestProvider.notifier).state = null;
      ref.read(selectedCartProvider.notifier).state = null;

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

    // 7. Calculate ETA
    final eta = assignmentService.calculateETA(nearestCart, userLatLng);

    // 8. Create ride request
    final request = assignmentService.createRequest(
      pickupLocation: userLatLng,
      partySize: 1,
      assignedCartId: nearestCart.id,
    );

    // 9. Update providers
    ref.read(activeRequestProvider.notifier).state = request.copyWith(
      status: RequestStatus.assigned,
    );
    ref.read(selectedCartProvider.notifier).state = nearestCart;

    // 10. Show success message
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
      // Active request - show cancel button
      buttonText = 'Cancel Request';
      buttonColor = Colors.red;
      buttonIcon = Icons.cancel;
      buttonAction = _onCancelRequest;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cart Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: AppConstants.initialCameraPosition,
        markers: _markers, // Display cart and stadium markers
        polygons: _polygons, // Display service area boundary
        myLocationButtonEnabled: true, // Shows recenter button (top right)
        myLocationEnabled: true, // Shows blue dot for user location
        mapType: MapType.normal,
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
