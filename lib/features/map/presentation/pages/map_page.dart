import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/config/app_constants.dart';
import 'package:flutter_google_map/core/services/location_service.dart';
import 'package:flutter_google_map/features/map/data/directions_service.dart';
import 'package:flutter_google_map/features/search/presentation/pages/search_location_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _destinationId = MarkerId('destination');
  static const _routeId = PolylineId('route');

  final _locationService = LocationService();
  final _directionsService = DirectionsService();

  GoogleMapController? _controller;
  LatLng? _currentPosition;
  String? _locationError;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _locationError = null);
    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = latLng);
      _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e.toString());
    }
  }

  Future<void> _searchDestination() async {
    final destination = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const SearchLocationPage()),
    );
    if (destination == null || !mounted) return;

    setState(() {
      _markers = {Marker(markerId: _destinationId, position: destination)};
      _polylines = {};
    });
    await _showRoute(_currentPosition!, destination);
  }

  Future<void> _showRoute(LatLng origin, LatLng destination) async {
    try {
      final points = await _directionsService.getRoute(origin, destination);
      if (!mounted) return;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: _routeId,
            points: points,
            color: kDefaultThemeColor,
            width: 6,
          ),
        };
      });
      _controller?.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsOf([origin, destination]), 64),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not get directions: $e')));
    }
  }

  LatLngBounds _boundsOf(List<LatLng> points) {
    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    return LatLngBounds(
      southwest: LatLng(lats.reduce(_min), lngs.reduce(_min)),
      northeast: LatLng(lats.reduce(_max), lngs.reduce(_max)),
    );
  }

  static double _min(double a, double b) => a < b ? a : b;
  static double _max(double a, double b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    final position = _currentPosition;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('Google Map Demo'),
      ),
      body: SafeArea(
        child: position != null
            ? GoogleMap(
                onMapCreated: (controller) => _controller = controller,
                initialCameraPosition:
                    CameraPosition(target: position, zoom: kDefaultZoom),
                polylines: _polylines,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                // Keep the map's own controls clear of the search button.
                padding: const EdgeInsets.only(bottom: 80),
              )
            : _locationError != null
                ? _LocationError(
                    message: _locationError!,
                    onRetry: _loadCurrentLocation,
                  )
                : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: position == null
          ? null
          : FloatingActionButton(
              onPressed: _searchDestination,
              tooltip: 'Search destination',
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black54,
              child: const Icon(Icons.search),
            ),
    );
  }
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
