# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

**This is a Flutter DEMO project** - not a production app. The goal is to build a simple maps demo in 4-6 hours to evaluate Flutter's developer experience before committing to it for a larger project.

### Background

- Building demos in both Flutter and React Native to compare frameworks
- Complete beginner to Flutter/Dart (but have programming experience)
- Will use this hands-on experience to decide which framework to use for GESTcarts app
- Focusing on developer experience, tooling quality, and learning curve

### Demo Scope: "Simple Cart Tracker"

A single-screen app that shows:

- User's current location on Google Maps
- 3 mock cart markers (green pins)
- Tap a cart to see distance from user
- Info card showing cart details
- Simple, clean UI

**NOT building:**

- Real backend/API integration
- Authentication
- Complex state management
- Production-ready architecture
- Comprehensive testing

## Evaluation Criteria

While building, pay attention to:

- ⏱️ **Speed**: How fast is hot reload? Compile times?
- 🐛 **Debugging**: Are error messages helpful?
- 📝 **Readability**: Is the code intuitive?
- 📚 **Learning Curve**: Can concepts be figured out easily?
- 🔧 **Tooling**: Does autocomplete/IDE support help?
- 📱 **Workflow**: How smooth is iPhone testing?

## Demo Steps

### Step 1: iOS Configuration (15-20 min)

- Get Google Maps API key
- Configure AppDelegate.swift
- Add location permissions to Info.plist

### Step 2: Basic Map View (30 min)

- Replace main.dart with basic map
- Get map rendering on iPhone

### Step 3: Mock Cart Data (20 min)

- Create simple Cart class
- Add 3 mock cart objects

### Step 4: Display Markers (45 min)

- Show carts as green markers
- Make markers tappable
- Test hot reload

### Step 5: User Location (30 min)

- Request location permission
- Show user as blue marker
- Center map on user

### Step 6: Distance Calculation (45 min)

- Calculate distance between user and cart
- Show info card on cart tap
- Display "X miles away"

### Step 7: Polish (30-45 min)

- Add navigation button (camera animation)
- Add recenter floating button
- Style the info card

**Total Time Budget: 4-6 hours**

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
└── main.dart          # All demo code in one file (intentionally simple)

ios/
├── Runner/
│   ├── AppDelegate.swift    # Google Maps API key configuration
│   └── Info.plist           # Location permissions
```

### Key Dependencies

- **google_maps_flutter** (^2.5.0) - Google Maps widget integration
- **geolocator** (^10.1.0) - Location services and GPS functionality
- **permission_handler** (^11.0.1) - Runtime permissions management

### Development Notes

- **Single-file architecture** - Everything in main.dart for simplicity
- **No BLoC/state management** - Using StatefulWidget with setState
- **Mock data** - Hardcoded cart coordinates (no API)
- **iOS-first** - Android not configured yet
- Uses Material Design

## iOS-Specific Setup

### Google Maps API Key

1. Required in `ios/Runner/AppDelegate.swift`
2. Get from Google Cloud Console
3. Enable "Maps SDK for iOS"

### Location Permissions

Required keys in `ios/Runner/Info.plist`:

- `NSLocationWhenInUseUsageDescription`
- `io.flutter.embedded_views_preview`

### First Run on iPhone

- Requires Apple ID signing in Xcode
- Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
- Select your Apple ID as Team in Signing & Capabilities
- Trust developer certificate on iPhone: Settings > General > VPN & Device Management

## Code Style for Demo

**Keep it simple and readable:**

- ✅ Single file (main.dart)
- ✅ Comments explaining concepts
- ✅ Clear variable names
- ✅ Minimal nesting
- ❌ No complex abstractions
- ❌ No over-engineering

**This is learning code, not production code.**

## After Demo

Document your experience:

- What felt intuitive vs. confusing?
- How long did each step actually take?
- Would you enjoy working in Flutter daily?
- Compare with React Native demo

## Quick Reference

### Dart Basics for Demo

```dart
// Variables
var name = 'Cart';           // Type inference
String id = 'CART-001';      // Explicit type
double lat = 38.9072;        // Decimals

// Classes
class Cart {
  final String id;           // final = immutable
  final double lat;
  final double lng;

  Cart(this.id, this.lat, this.lng);  // Constructor
}

// Lists
List<Cart> carts = [
  Cart('CART-001', 38.9072, -77.0369),
];

// Async/Await
Future<Position> getUserLocation() async {
  return await Geolocator.getCurrentPosition();
}
```

### Common Flutter Patterns

```dart
// StatefulWidget (has state that changes)
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int counter = 0;

  void increment() {
    setState(() {      // Tells Flutter to rebuild
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $counter');
  }
}
```

## Resources

- [Official Flutter Docs](https://docs.flutter.dev)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [google_maps_flutter Package](https://pub.dev/packages/google_maps_flutter)
- [geolocator Package](https://pub.dev/packages/geolocator)

## Project Goal Reminder

**The point is NOT to build perfect code.** The point is to:

1. Get hands-on experience with Flutter
2. Feel the developer workflow
3. Evaluate if you'd enjoy working in Flutter
4. Make an informed framework decision

Code quality doesn't matter. Learning experience does. 🚀
