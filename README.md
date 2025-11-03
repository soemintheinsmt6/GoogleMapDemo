## 📱 GoogleMapDemo (Flutter)

A simple Flutter demo showcasing Google Maps, current location, place autocomplete search, and driving directions. The app was refactored to a modular structure for easier scaling and maintenance.

### ✨ Features
- Current location with permission handling
- Google Maps display with my-location button
- Place search via Google Places Autocomplete
- Marker placement for destination
- Route polyline using Google Directions API

### 🧱 Modular Architecture

```
lib/
  core/
    config/
      app_constants.dart         # API key, theme, shared UI constants
    services/
      location_service.dart      # Location permission + current position

  features/
    map/
      presentation/
        pages/
          map_page.dart         # Main map page (markers, polylines)
    search/
      presentation/
        pages/
          search_location_page.dart  # Autocomplete + place details

  main.dart                      # App entry, theme, route to MapPage
```

### 🛠️ Setup
1. Flutter SDK installed and configured
2. Add your Google API key (Maps, Places, Directions enabled)
   - Currently defined in `lib/core/config/app_constants.dart` as `google_api_key`
   - For production, prefer using runtime configuration (e.g., from env/secrets) rather than committing keys
3. Install dependencies:

```bash
flutter pub get
```

4. Run on a simulator or device:

```bash
flutter run
```

### 🔑 API & Permissions
- Ensure the Google Cloud project has Maps SDK for Android/iOS, Places API, and Directions API enabled
- Android/iOS platform-specific setup is already scaffolded under `android/` and `ios/`

### 🧭 Notes
- The route polyline is fetched via the Directions API and decoded client-side
- `LocationService` wraps permission checks using the `location` and `geolocator` packages

### 📂 Legacy Cleanup
Replaced previous `lib/screens/` and `lib/services/` with modular `core/` and `features/` directories.
