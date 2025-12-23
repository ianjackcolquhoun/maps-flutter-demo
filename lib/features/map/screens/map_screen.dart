import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/geo_utils.dart';
import '../models/cart.dart';
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

  // Get user's current location
  Future<void> _getUserLocation() async {
    try {
      // Get location service from provider
      final locationService = ref.read(locationServiceProvider);
      Position? position = await locationService.getCurrentLocation();

      if (position != null) {
        // Update position in provider (no setState needed)
        ref.read(userPositionProvider.notifier).state = position;

        // Check if user is inside service area
        final userLatLng = LatLng(position.latitude, position.longitude);
        final isInServiceArea = GeoUtils.isPointInPolygon(
          userLatLng,
          AppConstants.serviceAreaBoundary,
        );

        // Center map on user's location with animation
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0, // Slightly closer zoom when centered on user
          ),
        );

        // Show message if outside service area
        if (!isInServiceArea && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are outside the service area. We only serve downtown Cincinnati.'),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
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

  // Called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
