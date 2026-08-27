// lib/services/nearby_places_service.dart

import 'package:latlong2/latlong.dart';

import 'openmap_service.dart';

/// Types of places the app can search for nearby.
/// These are mainly emergency-related locations.
enum PlaceType {
  hospital,
  police,
  fireStation,
  shelter,
}

/// This service fetches nearby emergency places
/// using the OpenStreetMap Overpass API.
class NearbyPlacesService {
  // ===============================================================
  // AMENITY
  // ===============================================================

  String _amenity(
    PlaceType type,
  ) {
    switch (type) {
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

  // ===============================================================
  // FETCH NEARBY
  // ===============================================================

  Future<List<Map<String, dynamic>>> fetchNearby({
    required LatLng currentPos,
    required PlaceType type,
    int radiusMeters = 4000,
  }) async {
    final amenity = _amenity(type);

    final places =
        await OpenMapService.fetchNearbyPlaces(
      center: currentPos,
      type: amenity,
      radius: radiusMeters,
    );

    // Keep the response structure expected by existing callers.
    return places.map((place) {
      return <String, dynamic>{
        'name':
            (place['name'] ?? amenity).toString(),
        'lat': place['lat'],
        'lon': place['lon'],
        'tags': place['tags'],
      };
    }).toList();
  }
}