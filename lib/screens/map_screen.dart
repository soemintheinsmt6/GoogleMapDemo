import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_map/constants.dart';
import 'package:flutter_google_map/screens/search_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:signed_spacing_flex/signed_spacing_flex.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;

  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};

  _getCurrentLocation() async {
    LocationService locationService = LocationService();
    Position position = await locationService.getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void addMarker(LatLng destination) {
    _markers.clear();
    _markers.add(
        Marker(markerId: const MarkerId('destination'), position: destination));
    setState(() {});
  }

  void getDirections(LatLng origin, LatLng destination) async {
    var url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$google_api_key';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (json["routes"] != null && json["routes"].isNotEmpty) {
      var points = json["routes"][0]["overview_polyline"]["points"];
      var polylineCoordinates = _decodePolyline(points);

      setState(() {
        _polyLines.clear();
        _polyLines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: kDefaultThemeColor,
          width: 6,
        ));
      });
    }
  }

  // Decode polyline points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('Google Map Demo'),
      ),
      body: SafeArea(
        child: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : SignedSpacingColumn(
                spacing: -130, // button height + bottom padding
                stackingOrder: StackingOrder.lastOnTop,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _controller = controller;
                      },
                      initialCameraPosition:
                          CameraPosition(target: _currentPosition!, zoom: 14),
                      polylines: _polyLines,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 6, 75),
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        LatLng? destination = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchLocation(),
                          ),
                        );
                        if (destination != null) {
                          addMarker(destination);
                          getDirections(_currentPosition!, destination);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.white,
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.black.withOpacity(0.65),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
