import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  // Initial camera position - centered on Cincinnati
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.1031, -84.5120), // Cincinnati coordinates
    zoom: 14.0, // Good zoom level to see streets
  );

  @override
  void initState() {
    super.initState();
    _loadCarts();
    _getUserLocation();
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

    final markers = carts.map((cart) {
      return Marker(
        markerId: MarkerId(cart.id),
        position: LatLng(cart.latitude, cart.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: cart.name,
          snippet: 'Tap for details',
        ),
        onTap: () => _onCartTapped(cart),
      );
    }).toSet();

    setState(() {
      _markers = markers;
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

        // Center map on user's location with animation
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0, // Slightly closer zoom when centered on user
          ),
        );
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
        initialCameraPosition: _initialPosition,
        markers: _markers, // Display cart markers
        myLocationButtonEnabled: true, // Shows recenter button (top right)
        myLocationEnabled: true, // Shows blue dot for user location
        mapType: MapType.normal,
      ),
    );
  }
}
