import 'dart:convert';

import 'package:flutter_google_map/core/config/env.dart';
import 'package:flutter_google_map/core/utils/polyline_decoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns the driving route from [origin] to [destination] as a list of
  /// points, or throws if the Directions API returns no route.
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': Env.googleApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Directions request failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No route found (${json['status'] ?? 'unknown status'})');
    }

    final points = routes.first['overview_polyline']['points'] as String;
    return decodePolyline(points);
  }
}
