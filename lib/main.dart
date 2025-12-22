import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/map/screens/map_screen.dart';

void main() {
  runApp(
    // ProviderScope enables Riverpod throughout the app
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root application widget - configures theme and routing
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
