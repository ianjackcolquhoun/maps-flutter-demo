import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Tracker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Google Maps controller - lets us control the map programmatically
  GoogleMapController? _mapController;

  // Initial camera position - centered on Cincinnati
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.1031, -84.5120), // Cincinnati coordinates
    zoom: 14.0, // Good zoom level to see streets
  );

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
        myLocationButtonEnabled: true, // Shows location button
        myLocationEnabled: false, // Will enable this when we add location permissions
        mapType: MapType.normal,
      ),
    );
  }
}
