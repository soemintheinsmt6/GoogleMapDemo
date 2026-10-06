import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Decodes a Google encoded polyline string into a list of coordinates.
///
/// See https://developers.google.com/maps/documentation/utilities/polylinealgorithm
List<LatLng> decodePolyline(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;

  int nextValue() {
    var shift = 0;
    var result = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  }

  while (index < encoded.length) {
    lat += nextValue();
    lng += nextValue();
    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}
