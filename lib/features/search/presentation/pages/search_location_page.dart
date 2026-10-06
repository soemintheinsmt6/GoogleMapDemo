import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/config/app_constants.dart';
import 'package:flutter_google_map/features/search/data/places_service.dart';
import 'package:google_place/google_place.dart';

/// Lets the user search for a place and pops with its `LatLng` when selected.
class SearchLocationPage extends StatefulWidget {
  const SearchLocationPage({super.key});

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  static const _debounceDuration = Duration(milliseconds: 500);

  final _placesService = PlacesService();
  final _queryController = TextEditingController();

  List<AutocompletePrediction> _predictions = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _error = null;
        _isLoading = false;
      });
      return;
    }
    _debounce = Timer(_debounceDuration, () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    List<AutocompletePrediction> predictions = [];
    String? error;
    try {
      predictions = await _placesService.autocomplete(query);
    } catch (e) {
      error = 'Search failed: $e';
    }
    // Ignore results for a query the user has since changed.
    if (!mounted || query != _queryController.text.trim()) return;
    setState(() {
      _predictions = predictions;
      _error = error;
      _isLoading = false;
    });
  }

  Future<void> _selectPrediction(AutocompletePrediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    try {
      final location = await _placesService.getLocation(placeId);
      if (!mounted) return;
      if (location == null) {
        _showSnackBar('No location available for this place.');
        return;
      }
      Navigator.pop(context, location);
    } catch (e) {
      if (mounted) _showSnackBar('Could not load place details: $e');
    }
  }

  void _clearQuery() {
    _queryController.clear();
    _onQueryChanged('');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kDefaultThemeColor,
        title: TextField(
          controller: _queryController,
          onChanged: _onQueryChanged,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: kTextFieldUnderlineDecoration.copyWith(
            hintText: 'Search place',
            suffixIcon: ListenableBuilder(
              listenable: _queryController,
              builder: (context, _) => _queryController.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                      onPressed: _clearQuery,
                    ),
            ),
          ),
        ),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    if (_predictions.isEmpty) {
      final hasQuery = _queryController.text.trim().isNotEmpty;
      return Center(
        child: Text(
          hasQuery && !_isLoading ? 'No places found' : '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      itemCount: _predictions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(prediction.structuredFormatting?.mainText ??
              prediction.description ??
              ''),
          subtitle: prediction.structuredFormatting?.secondaryText == null
              ? null
              : Text(prediction.structuredFormatting!.secondaryText!),
          onTap: () => _selectPrediction(prediction),
        );
      },
    );
  }
}
