import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  /// Service area boundary polygon - Downtown Cincinnati
  /// This defines the area where ride requests are accepted
  static const List<LatLng> serviceAreaBoundary = [
    LatLng(39.087184207591065, -84.51869432563144),
    LatLng(39.088568525895084, -84.51295921817994),
    LatLng(39.09124204525713, -84.49855367546303),
    LatLng(39.094210859858805, -84.49281847460088),
    LatLng(39.097869873918825, -84.4882301889014),
    LatLng(39.101628084682545, -84.48644478053633),
    LatLng(39.10686961187102, -84.48236882778457),
    LatLng(39.107168350512694, -84.49001239631811),
    LatLng(39.103606243980266, -84.49791552341914),
    LatLng(39.1063732610742, -84.50300839651248),
    LatLng(39.11819090098837, -84.4993029719065),
    LatLng(39.118390759936375, -84.50159045247447),
    LatLng(39.11700136991567, -84.50450564358165),
    LatLng(39.11572197103618, -84.50641085204794),
    LatLng(39.11582153925349, -84.50958609613129),
    LatLng(39.11886026704204, -84.50843025065834),
    LatLng(39.11994706864513, -84.51427021106275),
    LatLng(39.122207829063655, -84.51629661820152),
    LatLng(39.12230754690731, -84.51794735512611),
    LatLng(39.11969481393308, -84.52055448953064),
    LatLng(39.12067901511497, -84.52373027064776),
    LatLng(39.11803234705846, -84.5223640104097),
    LatLng(39.1077574632933, -84.51969579536427),
    LatLng(39.10765913017838, -84.52148208568308),
    LatLng(39.10370493456995, -84.52096836431508),
    LatLng(39.107760150629616, -84.53755365014761),
    LatLng(39.10271615444725, -84.53666648301301),
    LatLng(39.10063934649253, -84.53117892427926),
    LatLng(39.09806732166379, -84.52914345499913),
    LatLng(39.094800562344176, -84.52341629338783),
    LatLng(39.087184207591065, -84.51869432563144), // Close the polygon
  ];

  /// Stadium location - Great American Ball Park
  /// This is the destination for all ride requests
  static const LatLng stadiumLocation = LatLng(39.0978, -84.5066);

  /// Initial map camera position - centered on service area
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(39.105, -84.51), // Center of service area
    zoom: 13.5, // Zoom level to see entire service area
  );

  // Service Area Styling
  /// Fill color for service area polygon (semi-transparent blue)
  static const Color serviceAreaFillColor = Color(0x4000BFFF);

  /// Border color for service area polygon
  static const Color serviceAreaBorderColor = Color(0xFF00BFFF);

  /// Border width for service area polygon
  static const double serviceAreaBorderWidth = 2.0;

  // Map Marker Colors
  /// Hue value for available cart markers (green)
  static const double cartMarkerHue = BitmapDescriptor.hueGreen;

  /// Hue value for stadium marker (blue)
  static const double stadiumMarkerHue = BitmapDescriptor.hueAzure;

  // Request Settings
  /// Maximum party size allowed per request
  static const int maxPartySize = 5;

  /// Cart capacity (seats)
  static const int cartCapacity = 5;
}
