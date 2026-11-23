/// @title Place search
/// @notice Location suggestions for the listing form.
/// @dev Nominatim is used because the app has no Google Places key. Tests
/// substitute [EmptyPlaceSearch] so the suite never calls the network.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

/// @title PlaceHit
/// @notice One suggested place the seller can pick.
class PlaceHit {
  /// @notice Creates a suggestion.
  /// @param label Short name written into the location field.
  /// @param latitude WGS84 latitude.
  /// @param longitude WGS84 longitude.
  /// @return A new {PlaceHit} instance.
  const PlaceHit({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  /// @dev Short name written into the location field.
  final String label;

  /// @dev WGS84 latitude.
  final double latitude;

  /// @dev WGS84 longitude.
  final double longitude;
}

/// @title PlaceSearch
/// @notice Looks up places that match what the seller typed.
abstract class PlaceSearch {
  /// @notice Creates a search source.
  const PlaceSearch();

  /// @notice Places matching [query], nearer to the optional pin first.
  /// @param query Text in the location field.
  /// @param nearLatitude Viewer latitude, when known.
  /// @param nearLongitude Viewer longitude, when known.
  /// @return Up to five hits. Empty when the query is too short or the
  /// lookup failed.
  Future<List<PlaceHit>> search(
    String query, {
    double? nearLatitude,
    double? nearLongitude,
  });
}

/// @title EmptyPlaceSearch
/// @notice Search that never returns a place. Widget tests use this.
class EmptyPlaceSearch extends PlaceSearch {
  /// @notice Creates the empty source.
  const EmptyPlaceSearch();

  /// @notice Returns no suggestions.
  /// @param query Ignored.
  /// @param nearLatitude Ignored.
  /// @param nearLongitude Ignored.
  /// @return An empty list.
  @override
  Future<List<PlaceHit>> search(
    String query, {
    double? nearLatitude,
    double? nearLongitude,
  }) async {
    return const <PlaceHit>[];
  }
}

/// @notice Reads Nominatim JSON into short place hits.
/// @param decoded Decoded JSON body.
/// @return Hits with a name and a pin. Rows without either are skipped.
List<PlaceHit> placeHitsFromNominatim(Object? decoded) {
  if (decoded is! List) {
    return const <PlaceHit>[];
  }
  final List<PlaceHit> hits = <PlaceHit>[];
  for (final Object? row in decoded) {
    if (row is! Map) {
      continue;
    }
    final Map<String, dynamic> item = Map<String, dynamic>.from(row);
    final double? latitude = double.tryParse('${item['lat']}');
    final double? longitude = double.tryParse('${item['lon']}');
    if (latitude == null || longitude == null) {
      continue;
    }
    final String label = _shortLabel(item);
    if (label.isEmpty) {
      continue;
    }
    hits.add(PlaceHit(label: label, latitude: latitude, longitude: longitude));
  }
  return hits;
}

String _shortLabel(Map<String, dynamic> item) {
  String name = '${item['name'] ?? ''}'.trim();
  if (name.isEmpty) {
    final String display = '${item['display_name'] ?? ''}'.trim();
    name = display.split(',').first.trim();
  }
  final Object? address = item['address'];
  String city = '';
  if (address is Map) {
    city =
        '${address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? ''}'
            .trim();
  }
  final String label = city.isEmpty || name == city ? name : '$name, $city';
  if (label.length <= 200) {
    return label;
  }
  return label.substring(0, 200);
}

/// @title NominatimPlaceSearch
/// @notice OpenStreetMap search biased toward Indonesia and the viewer.
class NominatimPlaceSearch extends PlaceSearch {
  /// @notice Creates the Nominatim source.
  const NominatimPlaceSearch();

  /// @notice Asks Nominatim for places matching [query].
  /// @param query Text in the location field.
  /// @param nearLatitude Viewer latitude, when known.
  /// @param nearLongitude Viewer longitude, when known.
  /// @return Up to five hits, or an empty list when the request fails.
  @override
  Future<List<PlaceHit>> search(
    String query, {
    double? nearLatitude,
    double? nearLongitude,
  }) async {
    final String text = query.trim();
    if (text.length < 2) {
      return const <PlaceHit>[];
    }
    final Map<String, String> params = <String, String>{
      'q': text,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '5',
      'countrycodes': 'id',
      'accept-language': 'id',
      if (nearLatitude != null && nearLongitude != null) ...<String, String>{
        'lat': '$nearLatitude',
        'lon': '$nearLongitude',
      },
    };
    try {
      final http.Response response = await http
          .get(
            Uri.https('nominatim.openstreetmap.org', '/search', params),
            headers: const <String, String>{
              'User-Agent': 'KosplyMobile/1.0 (com.example.kosply_mobile)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return const <PlaceHit>[];
      }
      return placeHitsFromNominatim(jsonDecode(response.body));
    } catch (_) {
      return const <PlaceHit>[];
    }
  }
}
