// lib/services/openmap_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// This service is used to fetch nearby emergency places
/// using the OpenStreetMap Overpass API.
///
/// It returns locations like:
/// - hospitals
/// - police stations
/// - fire stations
/// - shelters
class OpenMapService {
  OpenMapService._();

  // ===============================================================
  // OVERPASS ENDPOINTS
  // ===============================================================

  /// Public Overpass servers can occasionally become overloaded.
  /// We keep the existing server as the primary endpoint and use
  /// another public global endpoint only when the first one fails.
  static const List<String> _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  /// Useful for UI/debugging if every endpoint fails.
  static String? lastError;

  // ===============================================================
  // FETCH NEARBY PLACES
  // ===============================================================

  static Future<List<Map<String, dynamic>>> fetchNearbyPlaces({
    required LatLng center,
    required String type,
    int radius = 4000,
  }) async {
    lastError = null;

    final query = _buildQuery(
      center: center,
      type: type,
      radius: radius,
    );

    Object? latestError;

    // =============================================================
    // TRY AVAILABLE OVERPASS SERVERS
    // =============================================================

    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: const {
                'Content-Type':
                    'application/x-www-form-urlencoded',
                'Accept': 'application/json',
                'User-Agent': 'RescueAid/1.0 (Flutter)',
              },
              body: 'data=${Uri.encodeComponent(query)}',
            )
            .timeout(
              const Duration(seconds: 18),
            );

        final raw = response.body.trim();

        // ---------------------------------------------------------
        // INVALID / BUSY SERVER
        // ---------------------------------------------------------

        if (response.statusCode != 200) {
          latestError =
              'Overpass returned HTTP ${response.statusCode}';

          continue;
        }

        if (raw.isEmpty || !raw.startsWith('{')) {
          latestError =
              'Overpass returned a non-JSON response';

          continue;
        }

        // ---------------------------------------------------------
        // PARSE
        // ---------------------------------------------------------

        final decoded = jsonDecode(raw);

        if (decoded is! Map<String, dynamic>) {
          latestError =
              'Unexpected Overpass response format';

          continue;
        }

        final elements =
            (decoded['elements'] as List?) ?? const [];

        final results = _parseElements(
          elements,
          fallbackType: type,
        );

        lastError = null;

        return results;
      } catch (e) {
        latestError = e;

        // Try next endpoint automatically.
        continue;
      }
    }

    lastError =
        latestError?.toString() ??
        'Unable to connect to map service';

    return [];
  }

  // ===============================================================
  // QUERY
  // ===============================================================

  static String _buildQuery({
    required LatLng center,
    required String type,
    required int radius,
  }) {
    final lat = center.latitude;
    final lon = center.longitude;

    // -------------------------------------------------------------
    // SHELTERS
    // -------------------------------------------------------------
    //
    // OSM uses multiple valid tags for refuge / emergency places.
    // Using these together gives more useful results.
    // -------------------------------------------------------------

    if (type == 'shelter') {
      return '''
[out:json][timeout:25];
(
  node["amenity"="shelter"](around:$radius,$lat,$lon);
  way["amenity"="shelter"](around:$radius,$lat,$lon);
  relation["amenity"="shelter"](around:$radius,$lat,$lon);

  node["amenity"="social_facility"]["social_facility"="shelter"](around:$radius,$lat,$lon);
  way["amenity"="social_facility"]["social_facility"="shelter"](around:$radius,$lat,$lon);
  relation["amenity"="social_facility"]["social_facility"="shelter"](around:$radius,$lat,$lon);

  node["emergency"="assembly_point"](around:$radius,$lat,$lon);
  way["emergency"="assembly_point"](around:$radius,$lat,$lon);
  relation["emergency"="assembly_point"](around:$radius,$lat,$lon);
);
out center;
''';
    }

    // -------------------------------------------------------------
    // HOSPITAL / POLICE / FIRE
    // -------------------------------------------------------------

    return '''
[out:json][timeout:25];
(
  node["amenity"="$type"](around:$radius,$lat,$lon);
  way["amenity"="$type"](around:$radius,$lat,$lon);
  relation["amenity"="$type"](around:$radius,$lat,$lon);
);
out center;
''';
  }

  // ===============================================================
  // PARSE RESULTS
  // ===============================================================

  static List<Map<String, dynamic>> _parseElements(
    List elements, {
    required String fallbackType,
  }) {
    final results = <Map<String, dynamic>>[];

    final seen = <String>{};

    for (final element in elements) {
      if (element is! Map) {
        continue;
      }

      double? lat;
      double? lon;

      // -----------------------------------------------------------
      // NODE
      // -----------------------------------------------------------

      if (element['lat'] is num &&
          element['lon'] is num) {
        lat = (element['lat'] as num).toDouble();
        lon = (element['lon'] as num).toDouble();
      }

      // -----------------------------------------------------------
      // WAY / RELATION
      // -----------------------------------------------------------

      else if (element['center'] is Map) {
        final center = element['center'] as Map;

        final centerLat = center['lat'];
        final centerLon = center['lon'];

        if (centerLat is num &&
            centerLon is num) {
          lat = centerLat.toDouble();
          lon = centerLon.toDouble();
        }
      }

      if (lat == null || lon == null) {
        continue;
      }

      final tags = element['tags'] is Map
          ? Map<String, dynamic>.from(
              element['tags'] as Map,
            )
          : <String, dynamic>{};

      final key =
          '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';

      if (!seen.add(key)) {
        continue;
      }

      final rawName =
          (tags['name'] ?? '').toString().trim();

      final name = rawName.isNotEmpty
          ? rawName
          : _fallbackName(
              type: fallbackType,
              tags: tags,
            );

      results.add({
        'lat': lat,
        'lon': lon,
        'name': name,
        'tags': tags,
      });
    }

    return results;
  }

  // ===============================================================
  // FALLBACK NAME
  // ===============================================================

  static String _fallbackName({
    required String type,
    required Map<String, dynamic> tags,
  }) {
    if (type == 'shelter') {
      if (tags['emergency'] == 'assembly_point') {
        return 'Emergency Assembly Point';
      }

      if (tags['social_facility'] == 'shelter') {
        return 'Emergency Shelter';
      }

      return 'Shelter';
    }

    switch (type) {
      case 'hospital':
        return 'Hospital';

      case 'police':
        return 'Police Station';

      case 'fire_station':
        return 'Fire Station';

      default:
        return 'Nearby Place';
    }
  }

  // ===============================================================
  // CHAT / TEXT FORMATTER
  // ===============================================================

  static String formatPlaces(
    List<Map<String, dynamic>> places, {
    int limit = 5,
  }) {
    if (places.isEmpty) {
      return "Nearby places nahi milay. Thori dair baad try karo.";
    }

    final take = places.take(limit).toList();

    final lines = <String>[];

    for (int i = 0; i < take.length; i++) {
      final place = take[i];

      final rawName =
          place['name']?.toString().trim() ?? '';

      final name = rawName.isNotEmpty
          ? rawName
          : 'Place';

      final lat = place['lat'];
      final lon = place['lon'];

      lines.add(
        "${i + 1}) $name\n"
        "   https://maps.google.com/?q=$lat,$lon",
      );
    }

    return lines.join("\n\n");
  }
}