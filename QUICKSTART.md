# Quick Start Guide

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (^3.9.0)
- Dart SDK (^3.9.0)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS)

## Installation Steps

### 1. Clone or Download the Project

```bash
cd /path/to/project
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all required packages including:
- Riverpod for state management
- Dio for networking
- Hive for local storage
- And more...

### 3. Run the Application

#### On Android Emulator/Device:
```bash
flutter run
```

#### On iOS Simulator/Device:
```bash
flutter run -d ios
```

#### On Chrome (Web):
```bash
flutter run -d chrome
```

### 4. Build for Production

#### Android APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

#### iOS:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # App-wide constants
│   └── theme/
│       └── app_theme.dart            # Theme configuration
├── data/
│   ├── models/
│   │   ├── card_model.dart           # Card data models
│   │   └── remote_config_model.dart  # Config model
│   ├── services/
│   │   ├── api_service.dart          # API calls
│   │   └── cache_service.dart        # Local storage
│   └── repositories/
│       └── feed_repository.dart      # Business logic
└── presentation/
    ├── providers/
    │   └── providers.dart            # Riverpod providers
    ├── state/
    │   ├── feed_state.dart           # State classes
    │   └── feed_notifier.dart        # State management
    ├── screens/
    │   └── feed_screen.dart          # Main screen
    └── widgets/
        ├── cards/                    # Card widgets
        └── loading/                  # Loading widgets
```

## Features Overview

### 1. Dynamic Card Rendering
The app supports multiple card types:
- **ContentCard**: News/article cards with images, titles, descriptions
- **PromoCard**: Promotional cards with gradients and CTAs
- **Fallback**: Graceful handling of unknown card types

### 2. Infinite Scroll
- Automatic pagination when scrolling to 80% of feed
- Smooth loading indicators
- Configurable page size from remote config

### 3. Offline-First
- All content cached locally using Hive
- Works completely offline
- Automatic sync when online
- Offline indicator in UI

### 4. Pull-to-Refresh
- Swipe down to refresh content
- Smooth refresh animation
- Updates both config and feed

### 5. Smart Promo Injection
- Promo cards injected at configurable intervals
- Maintains correct positioning across pages
- Cycles through available promos

### 6. Priority Sorting
- Content sorted by category priorities
- Priorities fetched from remote config
- Ensures important content appears first

## Configuration

### Remote Config
The app fetches configuration from a remote endpoint. You can modify the mock data in:
`lib/data/services/api_service.dart`

Example config structure:
```json
{
  "cardOrder": ["content", "promo"],
  "categoryPriorities": {
    "technology": 1,
    "business": 2,
    "sports": 3
  },
  "pagination": {
    "pageSize": 10,
    "preloadThreshold": 3
  },
  "promoCardInterval": 5
}
```

### API Endpoints
Update API endpoints in:
`lib/core/constants/app_constants.dart`

### Theme Customization
Modify colors and styles in:
`lib/core/theme/app_theme.dart`

## Troubleshooting

### Issue: Dependencies not installing
**Solution**:
```bash
flutter clean
flutter pub get
```

### Issue: Build errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Hive errors
**Solution**: The Hive adapters are already generated. If you modify models, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: App not running
**Solution**:
1. Check Flutter doctor: `flutter doctor`
2. Ensure device/emulator is connected: `flutter devices`
3. Try running with verbose: `flutter run -v`

## Testing

### Run all tests:
```bash
flutter test
```

### Run with coverage:
```bash
flutter test --coverage
```

### Analyze code:
```bash
flutter analyze
```

## Performance Tips

1. **Images**: All images are cached automatically
2. **Scrolling**: Uses ListView.builder for efficient rendering
3. **State**: Riverpod ensures minimal rebuilds
4. **Offline**: Hive provides fast local storage

## Development Workflow

1. Make changes to code
2. Hot reload: Press `r` in terminal or save file
3. Hot restart: Press `R` in terminal
4. Full restart: Press `q` then `flutter run`

## Useful Commands

```bash
# Check Flutter installation
flutter doctor -v

# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build APK
flutter build apk

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Generate code
flutter pub run build_runner build

# Format code
flutter format lib/

# Analyze code
flutter analyze
```

## Next Steps

1. **Customize**: Modify theme, colors, and branding
2. **API**: Connect to real API endpoints
3. **Features**: Add search, filters, bookmarks
4. **Testing**: Write unit and widget tests
5. **Deploy**: Build and publish to stores

## Support

For issues or questions:
1. Check ARCHITECTURE.md for detailed explanations
2. Review README.md for comprehensive guide
3. Check code comments for inline documentation

## License

This project is for educational and demonstration purposes.

---

**Happy Coding! 🚀**
