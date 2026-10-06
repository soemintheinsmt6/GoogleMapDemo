import 'package:flutter_google_map/core/config/env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class PlacesService {
  PlacesService({GooglePlace? googlePlace})
      : _googlePlace = googlePlace ?? GooglePlace(Env.googleApiKey);

  final GooglePlace _googlePlace;

  Future<List<AutocompletePrediction>> autocomplete(String query) async {
    final response = await _googlePlace.autocomplete.get(query);
    return response?.predictions ?? const [];
  }

  /// Returns the coordinates of [placeId], or null if they are unavailable.
  Future<LatLng?> getLocation(String placeId) async {
    final response = await _googlePlace.details.get(placeId);
    final location = response?.result?.geometry?.location;
    final lat = location?.lat;
    final lng = location?.lng;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}
