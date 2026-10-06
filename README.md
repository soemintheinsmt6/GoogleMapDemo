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
      app_constants.dart         # Theme and shared UI constants
      env.dart                   # Reads GOOGLE_API_KEY from .env
    services/
      location_service.dart      # Location permission + current position
    utils/
      polyline_decoder.dart      # Decodes Google encoded polylines

  features/
    map/
      data/
        directions_service.dart  # Directions API → route points
      presentation/
        pages/
          map_page.dart          # Main map page (markers, polylines)
    search/
      data/
        places_service.dart      # Places autocomplete + place details
      presentation/
        pages/
          search_location_page.dart  # Search UI, pops with selected LatLng

  main.dart                      # App entry, theme, route to MapPage
```

### 🛠️ Setup
1. Flutter SDK installed and configured
2. Create an `.env` file in project root (same level as `pubspec.yaml`):

```bash
cp .env.example .env
```

Put your Google key there (enable Maps, Places, Directions):

```env
GOOGLE_API_KEY=your_google_api_key_here
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run on a simulator or device:

```bash
flutter run
```

### 🔑 API & Permissions
- Ensure Maps SDK for Android/iOS, Places API, and Directions API are enabled for your key
- The key is accessed via `Env.googleApiKey` (see `lib/core/config/env.dart`)
- Android/iOS platform-specific setup is already scaffolded under `android/` and `ios/`

### 🧭 Notes
- The route polyline is fetched via the Directions API and decoded client-side
- `LocationService` wraps permission checks using the `location` and `geolocator` packages

### 🧪 Tests

```bash
flutter test
```
