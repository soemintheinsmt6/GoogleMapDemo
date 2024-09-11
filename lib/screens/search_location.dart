import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_google_map/constants.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> _predictions = [];

  Timer? _debounce;
  final Duration debounceDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(google_api_key);
  }

  void searchLocation(String query) async {
    try {
      var result = await googlePlace.autocomplete.get(query);
      if (result != null &&
          result.predictions != null &&
          result.predictions!.isNotEmpty) {
        setState(() {
          _predictions = result.predictions!;
        });
      } else {
        if (kDebugMode) {
          print(
              "No predictions found or error in the response: ${result?.status ?? "Unknown error"}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred while fetching predictions: $e");
      }
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(debounceDuration, () {
      if (query.isNotEmpty) {
        searchLocation(query);
      }
    });
  }

  Future<void> getPlaceDetails(String placeId) async {
    var details = await googlePlace.details.get(placeId);
    if (details != null && details.result != null) {
      double? lat = details.result!.geometry!.location!.lat;
      double? lng = details.result!.geometry!.location!.lng;
      LatLng destination =
          (lat == null || lng == null) ? const LatLng(0, 0) : LatLng(lat, lng);
      if (mounted) {
        Navigator.pop(context, destination);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kDefaultThemeColor,
        title: TextField(
          onChanged: onSearchChanged,
          autofocus: true,
          decoration:
              kTextFieldUnderlineDecoration.copyWith(hintText: 'Search Place'),
        ),
      ),
      body: ListView.builder(
        itemCount: _predictions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_predictions[index].description ?? ""),
            onTap: () async {
              await getPlaceDetails(_predictions[index].placeId!);
            },
          );
        },
      ),
    );
  }
}
