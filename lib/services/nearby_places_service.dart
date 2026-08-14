// lib/services/nearby_places_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Types of places the app can search for nearby
/// These are mainly emergency-related locations.
enum PlaceType { hospital, police, fireStation, shelter }

/// This service fetches nearby emergency places
/// using the OpenStreetMap Overpass API.
class NearbyPlacesService {

  /// Converts the place type into the corresponding
  /// OpenStreetMap amenity value used in the query.
  String _amenity(PlaceType t) {
    switch (t) {
      case PlaceType.hospital:
        return 'hospital';
      case PlaceType.police:
        return 'police';
      case PlaceType.fireStation:
        return 'fire_station';
      case PlaceType.shelter:
        return 'shelter';
    }
  }

  /// Fetches nearby locations based on the user's current position.
  /// It searches for hospitals, police stations, fire stations, or shelters.
  Future<List<Map<String, dynamic>>> fetchNearby({
    required LatLng currentPos,
    required PlaceType type,
    int radiusMeters = 4000,
  }) async {

    // Convert place type to OpenStreetMap amenity
    final amenity = _amenity(type);

    /// Overpass API query used to search nearby nodes,
    /// ways, and relations for the selected amenity.
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="$amenity"](around:$radiusMeters,${currentPos.latitude},${currentPos.longitude});
  way["amenity"="$amenity"](around:$radiusMeters,${currentPos.latitude},${currentPos.longitude});
  relation["amenity"="$amenity"](around:$radiusMeters,${currentPos.latitude},${currentPos.longitude});
);
out center;
''';

    // Send request to Overpass API
    final res = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'data=${Uri.encodeComponent(query)}',
    );

    // If response is not valid JSON, return empty list
    if (!res.body.trim().startsWith('{')) return [];

    // Decode response data
    final data = jsonDecode(res.body);
    final elements = (data['elements'] as List?) ?? [];

    final results = <Map<String, dynamic>>[];

    // Extract useful information from each result
    for (final e in elements) {
      double? lat, lon;

      // Some results store coordinates directly
      if (e['lat'] != null && e['lon'] != null) {
        lat = (e['lat'] as num).toDouble();
        lon = (e['lon'] as num).toDouble();
      }

      // Others store coordinates inside a "center" object
      else if (e['center'] != null) {
        lat = (e['center']['lat'] as num?)?.toDouble();
        lon = (e['center']['lon'] as num?)?.toDouble();
      }

      // Skip if coordinates are missing
      if (lat == null || lon == null) continue;

      // Extract place name from tags
      final tags = e['tags'] as Map? ?? {};
      final name = (tags['name'] ?? amenity).toString();

      // Store result
      results.add({
        "name": name,
        "lat": lat,
        "lon": lon,
      });
    }

    return results;
  }
}