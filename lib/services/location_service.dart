// lib/services/location_service.dart
import 'dart:async';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

/// This service manages location access in the app.
/// It handles requesting permission, getting the current location,
/// and providing a stream of location updates if needed.
class LocationService {
  LocationService._internal();

  /// Singleton instance so the same location service
  /// is used across the whole app.
  static final LocationService instance = LocationService._internal();

  final Location _location = Location();

  /// Subscription used to listen to live location updates
  StreamSubscription<LocationData>? _sub;

  /// Broadcast controller so multiple parts of the app
  /// can listen to location updates.
  final StreamController<LocationData> _controller =
      StreamController<LocationData>.broadcast();

  LocationData? _last;
  bool _started = false;

  /// Stream that provides live location updates
  Stream<LocationData> get stream => _controller.stream;

  /// Returns the last known location
  LocationData? get last => _last;

  /// Requests location service and permission from the user.
  /// This can be used when showing a "Allow location" button.
  Future<bool> requestPermissionOnly() async {
    bool enabled = await _location.serviceEnabled();

    if (!enabled) {
      enabled = await _location.requestService();
      if (!enabled) return false;
    }

    var perm = await _location.hasPermission();

    if (perm == PermissionStatus.denied) {
      perm = await _location.requestPermission();
    }

    return perm == PermissionStatus.granted ||
        perm == PermissionStatus.grantedLimited;
  }

  /// Ensures the location permission and service are ready
  Future<bool> ensureReady() async => requestPermissionOnly();

  /// Starts listening for location updates
  Future<bool> start() async {
    if (_started) return true;

    final ok = await ensureReady();
    if (!ok) return false;

    // Configure location settings
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 800,
      distanceFilter: 0,
    );

    // Listen for live location updates
    _sub = _location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;

      _last = loc;
      _controller.add(loc);
    });

    // Try to get a quick initial location
    try {
      final first = await _location.getLocation().timeout(
            const Duration(seconds: 2),
          );

      if (first.latitude != null && first.longitude != null) {
        _last = first;
        _controller.add(first);
      }
    } catch (_) {}

    _started = true;
    return true;
  }

  /// Attempts to get the best available location.
  /// First it tries a direct location request,
  /// then falls back to the location stream if needed.
  Future<LocationData?> getBestEffort({
    Duration oneShotTimeout = const Duration(seconds: 3),
    Duration streamTimeout = const Duration(seconds: 4),
  }) async {
    final ok = await start();
    if (!ok) return null;

    // Try getting location directly
    try {
      final one = await _location.getLocation().timeout(oneShotTimeout);

      if (one.latitude != null && one.longitude != null) {
        _last = one;
        return one;
      }
    } catch (_) {}

    // If direct fetch fails, wait for stream update
    try {
      final fromStream = await stream.first.timeout(streamTimeout);
      return fromStream;
    } catch (_) {
      return _last;
    }
  }

  /// Helper function used by map or chatbot features.
  /// Converts the location into a LatLng object.
  Future<LatLng?> getCurrentLatLng({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final loc = await getBestEffort(
      oneShotTimeout: timeout,
      streamTimeout: timeout,
    );

    final lat = loc?.latitude;
    final lng = loc?.longitude;

    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  /// Checks whether location permission is already granted
  Future<bool> hasPermission() async {
    final perm = await _location.hasPermission();

    return perm == PermissionStatus.granted ||
        perm == PermissionStatus.grantedLimited;
  }

  /// Stops listening to location updates
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  /// Cleans up the service when the app is closing
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}