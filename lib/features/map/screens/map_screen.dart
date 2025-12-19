import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cart.dart';

/// Main map screen showing carts and user location
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Google Maps controller - lets us control the map programmatically
  GoogleMapController? _mapController;

  // Cart data
  List<Cart> _carts = [];

  // Markers to display on the map (Google Maps uses Set for performance)
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
  }

  // Load mock cart data and create markers
  void _loadCarts() {
    _carts = Cart.getMockCarts();
    _createMarkers();
  }

  // Convert Cart objects to Map Markers
  void _createMarkers() {
    final markers = _carts.map((cart) {
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
        myLocationButtonEnabled: true, // Shows location button
        myLocationEnabled: false, // Will enable this when we add location permissions
        mapType: MapType.normal,
      ),
    );
  }
}
