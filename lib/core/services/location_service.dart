import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  /// Ensures location services are on and permission is granted, then returns
  /// the device's current position. Throws a [LocationException] otherwise.
  Future<Position> getCurrentLocation() async {
    if (!await _location.serviceEnabled() &&
        !await _location.requestService()) {
      throw const LocationException('Location services are disabled.');
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    if (permission == PermissionStatus.deniedForever) {
      throw const LocationException(
          'Location permission is permanently denied. Enable it in Settings.');
    }
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.grantedLimited) {
      throw const LocationException('Location permission was denied.');
    }

    return Geolocator.getCurrentPosition();
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
