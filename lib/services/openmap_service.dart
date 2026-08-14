import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// This service is used to fetch nearby emergency places
/// using the OpenStreetMap Overpass API.
/// It returns locations like hospitals, police stations,
/// fire stations, or shelters near the user's location.
class OpenMapService {

  /// Overpass API endpoint
  static const _overpass = 'https://overpass-api.de/api/interpreter';

  /// Fetch nearby places around the given coordinates.
  /// Example types: hospital, police, fire_station, shelter.
  static Future<List<Map<String, dynamic>>> fetchNearbyPlaces({
    required LatLng center,
    required String type,
    int radius = 3000,
  }) async {

    /// Overpass query used to search nearby locations
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="$type"](around:$radius,${center.latitude},${center.longitude});
  way["amenity"="$type"](around:$radius,${center.latitude},${center.longitude});
  relation["amenity"="$type"](around:$radius,${center.latitude},${center.longitude});
);
out center;
''';

    try {

      /// Send request to Overpass API
      final res = await http
          .post(
            Uri.parse(_overpass),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
              'User-Agent': 'DisasterAid/1.0 (Flutter)',
            },
            body: 'data=${Uri.encodeComponent(query)}',
          )
          .timeout(const Duration(seconds: 12));

      /// Sometimes Overpass returns HTML or XML if rate limited
      final raw = res.body.trim();

      if (res.statusCode != 200 || !raw.startsWith('{')) {
        final preview = raw.length > 160 ? raw.substring(0, 160) : raw;

        print('⚠️ Overpass non-JSON/status=${res.statusCode}: $preview');
        return [];
      }

      /// Decode JSON response
      final data = jsonDecode(raw);
      final elements = (data['elements'] as List?) ?? const [];

      final List<Map<String, dynamic>> results = [];

      /// Extract location details from each element
      for (final e in elements) {
        if (e is! Map) continue;

        double? lat;
        double? lon;

        // Some elements contain coordinates directly
        if (e['lat'] != null && e['lon'] != null) {
          lat = (e['lat'] as num).toDouble();
          lon = (e['lon'] as num).toDouble();
        }

        // Others store coordinates inside "center"
        else if (e['center'] != null) {
          final c = e['center'];

          if (c is Map) {
            lat = (c['lat'] as num?)?.toDouble();
            lon = (c['lon'] as num?)?.toDouble();
          }
        }

        if (lat != null && lon != null) {

          final tags = (e['tags'] is Map)
              ? Map<String, dynamic>.from(e['tags'])
              : <String, dynamic>{};

          results.add({
            'lat': lat,
            'lon': lon,
            'name': (tags['name'] ?? '').toString(),
            'tags': tags,
          });
        }
      }

      return results;
    } catch (e) {

      /// If API request fails, return empty list
      print('❌ Overpass Exception: $e');
      return [];
    }
  }

  /// Helper function used to format places into
  /// a readable text list for the chatbot UI.
  static String formatPlaces(List<Map<String, dynamic>> places, {int limit = 5}) {

    if (places.isEmpty) {
      return "Nearby places nahi milay. Thori dair baad try karo.";
    }

    final take = places.take(limit).toList();
    final lines = <String>[];

    for (int i = 0; i < take.length; i++) {
      final p = take[i];

      final name = (p['name']?.toString().trim().isNotEmpty ?? false)
          ? p['name'].toString().trim()
          : (p['tags']?['amenity']?.toString() ?? 'Place');

      final lat = p['lat'];
      final lon = p['lon'];

      lines.add("${i + 1}) $name\n   https://maps.google.com/?q=$lat,$lon");
    }

    return lines.join("\n\n");
  }
}