# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

**This is a Flutter DEMO project** - not a production app. The goal was to build a maps demo in 4-6 hours to evaluate Flutter's developer experience before committing to it for a larger project.

### Status: ✅ COMPLETE

The demo has been successfully completed! All features are working, UI is polished, and the project achieved its goal of evaluating Flutter's developer experience.

### Background

- Building demos in both Flutter and React Native to compare frameworks
- Complete beginner to Flutter/Dart (but have programming experience)
- Will use this hands-on experience to decide which framework to use for GESTcarts app
- Focusing on developer experience, tooling quality, and learning curve

### Demo Scope: "Cart Tracker with Real Routing"

A single-screen app that shows:

- User's current location on Google Maps with continuous tracking
- 3 mock cart markers with custom car icons (purple Material Icons)
- Service area polygon (downtown Cincinnati) with validation
- Stadium destination marker (pastel red baseball icon)
- Request nearest cart → real road routing → animated cart movement
- Camera following during ride
- Info card showing cart details, ETA, and distance
- Custom purple theme throughout
- Light/dark map style toggle
- Professional, polished UI

**NOT building:**

- Real backend/API integration
- Authentication
- Complex state management beyond Riverpod
- Production-ready architecture
- Comprehensive testing

## Evaluation Criteria

**Final Ratings (4.6/5 overall)**:

- ⏱️ **Hot Reload Speed**: ⭐⭐⭐⭐⭐ Instant, preserves state perfectly
- 🐛 **Error Messages**: ⭐⭐⭐⭐ Generally helpful, some cryptic async errors
- 📝 **Code Readability**: ⭐⭐⭐⭐⭐ Dart is clean, intuitive, and concise
- 📚 **Learning Curve**: ⭐⭐⭐⭐ Steep at first, excellent documentation
- 🔧 **IDE Support**: ⭐⭐⭐⭐⭐ Outstanding autocomplete and navigation
- 📱 **iPhone Testing**: ⭐⭐⭐⭐ Smooth workflow after Xcode setup
- 🎨 **State Management**: ⭐⭐⭐⭐⭐ Riverpod is powerful and intuitive
- 🎬 **Animation**: ⭐⭐⭐⭐⭐ Stream-based animation is elegant

## Completed Features

### Core Functionality
- ✅ Real-time GPS location tracking with continuous stream updates
- ✅ Service area validation (point-in-polygon ray casting algorithm)
- ✅ Nearest cart assignment using Haversine distance
- ✅ Real road routing via Google Directions API (no straight-line fallbacks)
- ✅ Smooth cart animation at 6x speed (100ms update intervals)
- ✅ Camera following during active rides (zoom level 17)
- ✅ Request status transitions (assigned → inProgress → completed)
- ✅ Dynamic info card with ETA and distance calculations
- ✅ Full ride lifecycle management (request → pickup → dropoff → exit)

### UI & Theming
- ✅ Custom purple theme throughout (deep purple primary color)
- ✅ Purple snackbar announcements (different shades for info/success)
- ✅ Light/dark map style toggle in AppBar
- ✅ Custom map styles (clean minimal light + dark mode)
- ✅ Very subtle service area fill (6% opacity purple)
- ✅ Custom car icons (Material Icons, 30px purple)
- ✅ Custom stadium icon (baseball, 40px pastel red)
- ✅ Professional polish and consistent theming

## Common Commands

### Development

- `flutter run` - Run the app on connected device/emulator
- `flutter run -d <device-id>` - Run on specific device
- `r` in terminal - Hot reload (fast, preserves state)
- `R` in terminal - Hot restart (full restart)
- `q` - Quit the running app

### Building

- `flutter build ios` - Build iOS app (requires Xcode on macOS)
- First build takes 5-10 minutes; subsequent builds are faster

### Testing and Quality

- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis for code issues
- `flutter doctor` - Check Flutter installation and dependencies
- `flutter clean` - Clean build artifacts (use if things break)

### Dependencies

- `flutter pub get` - Install dependencies from pubspec.yaml
- `flutter pub upgrade` - Upgrade packages to latest compatible versions
- `flutter pub outdated` - Check for newer package versions

### Troubleshooting

- `flutter clean && flutter pub get` - Reset when dependencies act weird
- `flutter doctor -v` - Detailed diagnostic info
- Delete app from iPhone and reinstall if permissions are stuck

## Architecture

### Project Structure

```
lib/
├── main.dart                           # App entry point with purple theme
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # Service area, colors, config
│   │   ├── map_styles.dart             # Light/dark map style loading
│   │   ├── secrets.dart                # API key (gitignored)
│   │   └── secrets.dart.template       # Template for team
│   └── utils/
│       └── geo_utils.dart              # Point-in-polygon, distance calc
└── features/
    └── map/
        ├── models/
        │   ├── cart.dart               # Cart data model
        │   ├── ride_request.dart       # Request with status enum
        │   └── route.dart              # Route with polyline/distance/ETA
        ├── providers/
        │   └── ride_providers.dart     # All Riverpod state providers
        ├── screens/
        │   └── map_screen.dart         # Main map screen (600+ lines)
        ├── services/
        │   ├── assignment_service.dart # Nearest cart logic
        │   ├── cart_animation_service.dart # Stream-based animation
        │   ├── directions_service.dart # Google Directions API
        │   └── location_service.dart   # GPS permissions & tracking
        └── widgets/
            └── cart_info_card.dart     # Info card UI component

assets/
└── map_styles/
    ├── clean_minimal.json              # Light map theme
    └── dark.json                       # Dark map theme

ios/
├── Runner/
│   ├── AppDelegate.swift               # Google Maps API key (gitignored)
│   ├── AppDelegate.swift.template      # Template for team
│   └── Info.plist                      # Location permissions
```

### Key Dependencies

- **google_maps_flutter** (^2.5.0) - Google Maps widget integration
- **geolocator** (^10.1.0) - Location services and GPS functionality
- **permission_handler** (^11.0.1) - Runtime permissions management
- **flutter_riverpod** (^2.4.9) - State management
- **uuid** (^4.0.0) - Unique ID generation for requests
- **flutter_polyline_points** (^2.0.0) - Decode Google Directions polylines

### Development Notes

- **Feature-based architecture** - Clean separation of concerns
- **Riverpod state management** - Provider pattern for reactive state
- **Real API integration** - Google Directions API for routing
- **Stream-based animation** - `Stream.periodic()` for cart movement
- **iOS-first** - Android not configured yet
- **Purple theme** - Deep purple primary color throughout

## iOS-Specific Setup

### Google Maps API Key

1. Required in `ios/Runner/AppDelegate.swift` (for Maps SDK)
2. Required in `lib/core/constants/secrets.dart` (for Directions API)
3. Get from Google Cloud Console
4. Enable both "Maps SDK for iOS" and "Directions API"

**Why two locations?** Swift can't import Dart constants, so API key needed in both places:
- AppDelegate.swift → Maps SDK rendering
- secrets.dart → Directions API REST calls

### Location Permissions

Required keys in `ios/Runner/Info.plist`:

- `NSLocationWhenInUseUsageDescription` - Location permission message
- `io.flutter.embedded_views_preview` - Required for Google Maps plugin

### First Run on iPhone

- Requires Apple ID signing in Xcode
- Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
- Select your Apple ID as Team in Signing & Capabilities
- Trust developer certificate on iPhone: Settings > General > VPN & Device Management

## Code Style

**Clean, production-quality code:**

- ✅ Feature-based architecture with clear separation
- ✅ Comprehensive comments explaining concepts
- ✅ Clear variable names and consistent naming conventions
- ✅ Proper error handling (no silent failures)
- ✅ Stream cleanup in dispose() methods
- ✅ Async/await patterns for API calls
- ✅ Type-safe models with immutable fields

**This is learning code, but production-quality.**

## Key Technical Decisions

### Routing
- **MUST use real roads** - Google Directions API required
- **NO fallback to straight lines** - Honest error messages if API fails
- **Route includes 3 waypoints** - Cart → User (pickup) → Stadium (dropoff)

### Animation
- **Stream-based** - `Stream.periodic()` with 100ms intervals
- **6x speed multiplier** - Makes demo engaging (15mph → 90mph animation)
- **Linear interpolation (lerp)** - Smooth movement between polyline points
- **Automatic status transitions** - Changes from assigned → inProgress → completed

### Camera Following
- **Simplified approach** - Just follow cart during inProgress status
- **Zoom level 17** - Close enough to see detail, not too zoomed in
- **No interaction detection** - Removed complexity that didn't work reliably

### Map Styling
- **Custom JSON styles** - Light and dark themes in assets
- **Theme toggle** - IconButton in AppBar for quick switching
- **Cached loading** - Load once, reuse for performance
- **Very subtle service area** - 6% opacity so it doesn't overpower

### Custom Icons
- **Material Icons rendered as markers** - `Icons.directions_car` and `Icons.sports_baseball`
- **Canvas-based rendering** - Convert IconData to BitmapDescriptor
- **White circle backgrounds** - Ensures visibility on all map styles
- **Size differentiation** - Cars 30px, stadium 40px

## Quick Reference

### Dart Basics for Demo

```dart
// Variables
var name = 'Cart';           // Type inference
String id = 'CART-001';      // Explicit type
double lat = 38.9072;        // Decimals

// Classes with immutable fields
class Cart {
  final String id;           // final = immutable
  final double latitude;
  final double longitude;

  const Cart({
    required this.id,
    required this.latitude,
    required this.longitude,
  });
}

// Lists
List<Cart> carts = [
  Cart(id: 'CART-001', latitude: 38.9072, longitude: -77.0369),
];

// Async/Await
Future<Position> getUserLocation() async {
  return await Geolocator.getCurrentPosition();
}

// Streams
Stream<CartAnimationState> animateCart() {
  return Stream.periodic(Duration(milliseconds: 100), (count) {
    // Return animation state
  });
}
```

### Common Flutter Patterns

```dart
// ConsumerStatefulWidget with Riverpod
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  void dispose() {
    // Clean up streams, controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for reactive updates
    final userPos = ref.watch(userPositionProvider);
    final activeRequest = ref.watch(activeRequestProvider);

    return Scaffold(
      body: GoogleMap(/* ... */),
    );
  }
}
```

### Riverpod Provider Patterns

```dart
// State provider (simple state)
final userPositionProvider = StateProvider<Position?>((ref) => null);

// Provider (computed value)
final locationServiceProvider = Provider((ref) => LocationService());

// Reading vs Watching
ref.read(provider);   // One-time read (in callbacks, initState)
ref.watch(provider);  // Subscribe to changes (in build method)
```

## Resources

- [Official Flutter Docs](https://docs.flutter.dev)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev)
- [google_maps_flutter Package](https://pub.dev/packages/google_maps_flutter)
- [geolocator Package](https://pub.dev/packages/geolocator)
- [Google Directions API](https://developers.google.com/maps/documentation/directions)

## Bugs Fixed During Development

1. **Location stream not updating button state** → Switched to continuous `getPositionStream()`
2. **Route line not visible** → Darker purple, width 5, solid line
3. **Info card blocking FAB** → Moved to top of screen
4. **Import conflict with Route class** → Added alias: `as route_model`
5. **Camera not following cart** → Simplified to basic following during ride
6. **Icons too large** → Reduced from 80px to 30px
7. **Service area too prominent** → Reduced opacity from 25% to 6%

## Final Evaluation

### What Went Well ✅
- Hot reload made iteration incredibly fast
- Riverpod state management was intuitive
- Google Maps Flutter package is mature and well-documented
- Feature-based architecture scaled nicely
- Stream-based animation was elegant
- Custom map styling was straightforward
- Purple theme customization was easy
- Material Icons as map markers worked perfectly

### What Was Challenging ⚠️
- iOS native configuration required Xcode knowledge
- Async error handling needed careful consideration
- Google Directions API has usage limits to monitor
- Some deprecation warnings in packages
- Camera following had edge cases (resolved by simplifying)

### Would I Choose Flutter? ✅

**YES** - For this type of mapping/location app, Flutter excelled. The developer experience was smooth, hot reload was game-changing, and the final result looks professional. The ecosystem is mature and the documentation is excellent.

**Recommendation**: Strong candidate for GESTcarts MVP.

## Project Goal Reminder

**The point was to evaluate Flutter's developer experience.** The project successfully achieved this goal:

1. ✅ Got hands-on experience with Flutter
2. ✅ Felt the developer workflow (hot reload, tooling, IDE support)
3. ✅ Evaluated if working in Flutter would be enjoyable
4. ✅ Can now make an informed framework decision

**Result**: Flutter rated 4.6/5 for this use case. Excellent candidate for the full GESTcarts app.

---

**Next Step**: Build React Native comparison demo, then make final framework decision.
