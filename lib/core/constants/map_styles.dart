import 'package:flutter/services.dart';

/// Map styling constants and utilities
class MapStyles {
  // Prevent instantiation
  MapStyles._();

  /// Path to the clean minimal style JSON asset
  static const String cleanMinimalStylePath = 'assets/map_styles/clean_minimal.json';

  /// Path to the dark mode style JSON asset
  static const String darkStylePath = 'assets/map_styles/dark.json';

  /// Cached map style strings (loaded once, reused)
  static String? _cleanMinimalStyle;
  static String? _darkStyle;

  /// Load clean minimal map style from asset bundle
  /// Returns the JSON string for GoogleMap.style parameter
  static Future<String> loadCleanMinimalStyle() async {
    if (_cleanMinimalStyle != null) {
      return _cleanMinimalStyle!;
    }

    _cleanMinimalStyle = await rootBundle.loadString(cleanMinimalStylePath);
    return _cleanMinimalStyle!;
  }

  /// Load dark mode map style from asset bundle
  /// Returns the JSON string for GoogleMap.style parameter
  static Future<String> loadDarkStyle() async {
    if (_darkStyle != null) {
      return _darkStyle!;
    }

    _darkStyle = await rootBundle.loadString(darkStylePath);
    return _darkStyle!;
  }
}
