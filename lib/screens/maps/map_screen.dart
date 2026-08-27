// lib/screens/maps/map_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'package:disaster_app_ui/widgets/popup_utils.dart';
import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/widgets/text_widget.dart';
import 'package:disaster_app_ui/services/openmap_service.dart';

enum PlaceType {
  hospital,
  police,
  fire_station,
  shelter,
}

class MapsScreen extends StatefulWidget {
  const MapsScreen({
    super.key,
  });

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  final Location _location = Location();

  final MapController _mapController = MapController();

  StreamSubscription<LocationData>? _locationSubscription;

  LatLng _currentPos = const LatLng(
    31.46318,
    73.0847,
  );

  List<Marker> _markers = [];

  List<LatLng> _polyline = [];

  String _distance = "~ Nearby";

  String _duration = "-- min";

  String _selectedName = "";

  bool _loadingPlaces = false;

  bool _locationReady = false;

  double _currentZoom = 15;

  PlaceType? _selectedPlaceType;

  late AnimationController _shimmerCtrl;

  static const String orsKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImM1YzkzMGFiM2ZjYTRhODc5NjU4MjY1OWVjMzM2ZTJkIiwiaCI6Im11cm11cjY0In0=';

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _initLocation();
      },
    );
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _locationSubscription?.cancel();

    _shimmerCtrl.dispose();

    super.dispose();
  }

  // ===============================================================
  // LOCATION
  // ===============================================================

  Future<void> _initLocation() async {
    try {
      // -----------------------------------------------------------
      // SERVICE
      // -----------------------------------------------------------

      bool enabled = await _location.serviceEnabled();

      if (!enabled) {
        enabled = await _location.requestService();
      }

      if (!enabled) {
        if (mounted) {
          PopupUtils.warning(
            "Location",
            "Location services are disabled.",
          );
        }

        return;
      }

      // -----------------------------------------------------------
      // PERMISSION
      // -----------------------------------------------------------

      var permission = await _location.hasPermission();

      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
      }

      final permissionGranted = permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited;

      if (!permissionGranted) {
        if (mounted) {
          PopupUtils.warning(
            "Location Permission",
            "Allow location access to find nearby emergency services.",
          );
        }

        return;
      }

      // -----------------------------------------------------------
      // LOCATION SETTINGS
      // -----------------------------------------------------------

      try {
        await _location.changeSettings(
          accuracy: LocationAccuracy.high,
          interval: 1000,
          distanceFilter: 3,
        );
      } catch (_) {
        // Some platforms/settings may ignore this.
      }

      // -----------------------------------------------------------
      // INITIAL LOCATION
      // -----------------------------------------------------------

      try {
        final loc = await _location.getLocation().timeout(
              const Duration(
                seconds: 6,
              ),
            );

        final lat = loc.latitude;
        final lon = loc.longitude;

        if (lat != null &&
            lon != null &&
            _validCoordinate(
              lat,
              lon,
            )) {
          if (!mounted) {
            return;
          }

          setState(() {
            _currentPos = LatLng(
              lat,
              lon,
            );

            _locationReady = true;
          });

          _moveMapToCurrentLocation();
        }
      } catch (e) {
        // Keep existing fallback coordinates if location
        // cannot be obtained immediately.
        debugPrint(
          'Initial location error: $e',
        );
      }

      // -----------------------------------------------------------
      // LIVE LOCATION
      // -----------------------------------------------------------

      await _locationSubscription?.cancel();

      _locationSubscription = _location.onLocationChanged.listen(
        (loc) {
          final lat = loc.latitude;
          final lon = loc.longitude;

          if (lat == null ||
              lon == null ||
              !_validCoordinate(
                lat,
                lon,
              )) {
            return;
          }

          if (!mounted) {
            return;
          }

          setState(() {
            _currentPos = LatLng(
              lat,
              lon,
            );

            _locationReady = true;
          });
        },
        onError: (error) {
          debugPrint(
            'Location stream error: $error',
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Location init error: $e',
      );
    }
  }

  // ===============================================================
  // COORDINATE VALIDATION
  // ===============================================================

  bool _validCoordinate(
    double lat,
    double lon,
  ) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  // ===============================================================
  // MOVE TO CURRENT LOCATION
  // ===============================================================

  void _moveMapToCurrentLocation() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        try {
          _mapController.move(
            _currentPos,
            _currentZoom,
          );
        } catch (e) {
          debugPrint(
            'Map move error: $e',
          );
        }
      },
    );
  }

  // ===============================================================
  // ZOOM
  // ===============================================================

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(
        3.0,
        19.0,
      );
    });

    _mapController.move(
      _mapController.camera.center,
      _currentZoom,
    );
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(
        3.0,
        19.0,
      );
    });

    _mapController.move(
      _mapController.camera.center,
      _currentZoom,
    );
  }

  // ===============================================================
  // PLACES
  // ===============================================================

  Future<void> _fetchPlaces(
    PlaceType type,
  ) async {
    if (_loadingPlaces) {
      return;
    }

    final amenity = switch (type) {
      PlaceType.hospital => 'hospital',
      PlaceType.police => 'police',
      PlaceType.fire_station => 'fire_station',
      PlaceType.shelter => 'shelter',
    };

    setState(() {
      _selectedPlaceType = type;

      _loadingPlaces = true;

      _markers.clear();

      _polyline.clear();

      _selectedName = "";

      _distance = "~ Nearby";

      _duration = "-- min";
    });

    PopupUtils.info(
      "Searching",
      "Nearby ${_placeLabel(type)}",
    );

    try {
      final places = await OpenMapService.fetchNearbyPlaces(
        center: _currentPos,
        type: amenity,
        radius: 5000,
      );

      if (!mounted) {
        return;
      }

      final markers = <Marker>[];

      for (final place in places) {
        final latValue = place['lat'];
        final lonValue = place['lon'];

        if (latValue is! num || lonValue is! num) {
          continue;
        }

        final lat = latValue.toDouble();

        final lon = lonValue.toDouble();

        if (!_validCoordinate(
          lat,
          lon,
        )) {
          continue;
        }

        final rawName = (place['name'] ?? '').toString().trim();

        final name = rawName.isNotEmpty ? rawName : _placeLabel(type);

        final destination = LatLng(
          lat,
          lon,
        );

        markers.add(
          Marker(
            point: destination,
            width: 56,
            height: 56,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _onSelect(
                  destination,
                  name,
                );
              },
              child: _placeMarker(type),
            ),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _markers = markers;
      });

      // -----------------------------------------------------------
      // RESULTS
      // -----------------------------------------------------------

      if (markers.isEmpty) {
        final serviceError = OpenMapService.lastError;

        if (serviceError != null && serviceError.trim().isNotEmpty) {
          PopupUtils.warning(
            "Map Service",
            "Nearby places could not be loaded. Please try again.",
          );
        } else {
          PopupUtils.warning(
            "No Results",
            "No nearby ${_placeLabel(type).toLowerCase()} found.",
          );
        }
      } else {
        PopupUtils.success(
          "Found",
          "${markers.length} locations",
        );
      }
    } catch (e) {
      if (mounted) {
        PopupUtils.error(
          "Map Error",
          "Unable to load nearby places.",
        );
      }

      debugPrint(
        'Places error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlaces = false;
        });
      }
    }
  }

  // ===============================================================
  // PLACE LABEL
  // ===============================================================

  String _placeLabel(
    PlaceType type,
  ) {
    switch (type) {
      case PlaceType.hospital:
        return "Hospital";

      case PlaceType.police:
        return "Police";

      case PlaceType.fire_station:
        return "Fire Station";

      case PlaceType.shelter:
        return "Shelter";
    }
  }

  // ===============================================================
  // ROUTING API
  // ===============================================================

  Future<void> _onSelect(
    LatLng dest,
    String name,
  ) async {
    PopupUtils.info(
      "Routing",
      "Calculating best path",
    );

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$orsKey'
      '&start=${_currentPos.longitude},${_currentPos.latitude}'
      '&end=${dest.longitude},${dest.latitude}',
    );

    try {
      final res = await http.get(url).timeout(
            const Duration(
              seconds: 20,
            ),
          );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(
          'Routing service returned ${res.statusCode}',
        );
      }

      final data = jsonDecode(res.body);

      if (data is! Map ||
          data['features'] is! List ||
          (data['features'] as List).isEmpty) {
        throw Exception(
          'No route available',
        );
      }

      final feature = (data['features'] as List).first;

      if (feature is! Map) {
        throw Exception(
          'Invalid route response',
        );
      }

      final properties = feature['properties'];

      final geometry = feature['geometry'];

      if (properties is! Map || geometry is! Map) {
        throw Exception(
          'Invalid route data',
        );
      }

      final segments = properties['segments'];

      final coordinates = geometry['coordinates'];

      if (segments is! List ||
          segments.isEmpty ||
          coordinates is! List ||
          coordinates.isEmpty) {
        throw Exception(
          'Route information unavailable',
        );
      }

      final segment = segments.first;

      if (segment is! Map) {
        throw Exception(
          'Invalid route segment',
        );
      }

      final distanceValue = segment['distance'];

      final durationValue = segment['duration'];

      if (distanceValue is! num || durationValue is! num) {
        throw Exception(
          'Route distance unavailable',
        );
      }

      final routePoints = <LatLng>[];

      for (final coordinate in coordinates) {
        if (coordinate is! List || coordinate.length < 2) {
          continue;
        }

        final longitude = coordinate[0];

        final latitude = coordinate[1];

        if (latitude is num && longitude is num) {
          routePoints.add(
            LatLng(
              latitude.toDouble(),
              longitude.toDouble(),
            ),
          );
        }
      }

      if (routePoints.isEmpty) {
        throw Exception(
          'Route geometry unavailable',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _markers = [
          Marker(
            point: dest,
            width: 56,
            height: 56,
            child: _selectedDestinationMarker(),
          ),
        ];

        _polyline = routePoints;

        _selectedName = name;

        _distance =
            "${(distanceValue.toDouble() / 1000).toStringAsFixed(2)} km";

        _duration = "${(durationValue.toDouble() / 60).toStringAsFixed(0)} min";
      });
    } catch (e) {
      debugPrint(
        'Route error: $e',
      );

      if (mounted) {
        PopupUtils.error(
          "Route Error",
          "Unable to calculate the route right now.",
        );
      }
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppScaffold(
      title: null,
      subtitle: null,
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 1,
      ),
      child: Column(
        children: [
          _pageHeader(),
          const SizedBox(height: 16),
          _serviceSelector(),
          const SizedBox(height: 14),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      24,
                    ),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPos,
                        initialZoom: _currentZoom,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                          // Keep package identifier unchanged.
                          userAgentPackageName: 'com.disasteraid.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _polyline,
                              strokeWidth: 5,
                              color: AppColor.primary,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPos,
                              width: 56,
                              height: 56,
                              child: _currentLocationMarker(),
                            ),
                            ..._markers,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _locationStatus(),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Column(
                    children: [
                      _mapButton(
                        icon: Icons.my_location_rounded,
                        onTap: () {
                          _moveMapToCurrentLocation();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _mapButton(
                        icon: Icons.add_rounded,
                        onTap: _zoomIn,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _mapButton(
                        icon: Icons.remove_rounded,
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),
                if (_loadingPlaces) _loadingOverlay(),
                if (_polyline.isNotEmpty) _routePanel(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ===============================================================
  // PAGE HEADER
  // ===============================================================

  Widget _pageHeader() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TextWidget(
            "Emergency Map",
            size: 27,
            weight: FontWeight.w800,
            color: AppColor.text,
            align: TextAlign.center,
          ),
          SizedBox(height: 5),
          TextWidget(
            "Find shelters and services near you",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SERVICE SELECTOR
  // ===============================================================

  Widget _serviceSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _serviceItem(
            type: PlaceType.hospital,
            icon: Icons.medical_services_outlined,
            label: "Hospital",
            color: AppColor.danger,
          ),
          const SizedBox(width: 9),
          _serviceItem(
            type: PlaceType.police,
            icon: Icons.local_police_outlined,
            label: "Police",
            color: AppColor.info,
          ),
          const SizedBox(width: 9),
          _serviceItem(
            type: PlaceType.fire_station,
            icon: Icons.fire_truck_outlined,
            label: "Fire",
            color: AppColor.warning,
          ),
          const SizedBox(width: 9),
          _serviceItem(
            type: PlaceType.shelter,
            icon: Icons.home_work_outlined,
            label: "Shelter",
            color: AppColor.safeGreen,
          ),
        ],
      ),
    );
  }

  Widget _serviceItem({
    required PlaceType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final selected = _selectedPlaceType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: () {
          _fetchPlaces(type);
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected ? color : AppColor.surface,
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: selected ? color : AppColor.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withOpacity(
                        0.18,
                      ),
                      blurRadius: 14,
                      offset: const Offset(
                        0,
                        6,
                      ),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(
                width: 8,
              ),
              TextWidget(
                label,
                size: 12.5,
                weight: FontWeight.w800,
                color: selected ? Colors.white : AppColor.text,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // CURRENT LOCATION MARKER
  // ===============================================================

  Widget _currentLocationMarker() {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(
          5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(
                0.22,
              ),
              blurRadius: 14,
              offset: const Offset(
                0,
                5,
              ),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColor.safeGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.navigation_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PLACE MARKER
  // ===============================================================

  Widget _placeMarker(
    PlaceType type,
  ) {
    final color = _colorForPlaceType(
      type,
    );

    final icon = _iconForPlaceType(
      type,
    );

    return Center(
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: color.withOpacity(
              0.30,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.12,
              ),
              blurRadius: 12,
              offset: const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 23,
          color: color,
        ),
      ),
    );
  }

  // ===============================================================
  // SELECTED MARKER
  // ===============================================================

  Widget _selectedDestinationMarker() {
    final color = _selectedPlaceType == null
        ? AppColor.primary
        : _colorForPlaceType(
            _selectedPlaceType!,
          );

    final icon = _selectedPlaceType == null
        ? Icons.location_on_rounded
        : _iconForPlaceType(
            _selectedPlaceType!,
          );

    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                0.30,
              ),
              blurRadius: 16,
              offset: const Offset(
                0,
                7,
              ),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 23,
        ),
      ),
    );
  }

  // ===============================================================
  // LOCATION STATUS
  // ===============================================================

  Widget _locationStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColor.surface.withOpacity(
          0.94,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColor.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 14,
            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _locationReady
                ? Icons.radio_button_checked_rounded
                : Icons.location_searching_rounded,
            color: _locationReady ? AppColor.safeGreen : AppColor.warning,
            size: 16,
          ),
          const SizedBox(
            width: 7,
          ),
          TextWidget(
            _locationReady ? "Live location" : "Locating...",
            size: 11.5,
            weight: FontWeight.w700,
            color: AppColor.text,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // MAP CONTROL
  // ===============================================================

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          14,
        ),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColor.surface.withOpacity(
              0.96,
            ),
            borderRadius: BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: AppColor.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.09,
                ),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColor.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ROUTE PANEL
  // ===============================================================

  Widget _routePanel() {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: Container(
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: AppColor.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.12,
              ),
              blurRadius: 22,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppColor.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextWidget(
                    _selectedName,
                    size: 15,
                    weight: FontWeight.w900,
                    color: AppColor.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              children: [
                Expanded(
                  child: _routeInfo(
                    icon: Icons.straighten_rounded,
                    label: "Distance",
                    value: _distance,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: _routeInfo(
                    icon: Icons.schedule_rounded,
                    label: "Travel time",
                    value: _duration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ROUTE INFO
  // ===============================================================

  Widget _routeInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColor.inputFill,
        borderRadius: BorderRadius.circular(
          13,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColor.primary,
            size: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  label,
                  size: 9.5,
                  color: AppColor.textMuted,
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  value,
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColor.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // LOADING
  // ===============================================================

  Widget _loadingOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                24,
              ),
              color: Colors.white.withOpacity(
                0.20,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.10,
                      ),
                      blurRadius: 16,
                      offset: const Offset(
                        0,
                        7,
                      ),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColor.primary,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextWidget(
                      "Searching nearby",
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColor.text,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // COLORS
  // ===============================================================

  Color _colorForPlaceType(
    PlaceType type,
  ) {
    switch (type) {
      case PlaceType.hospital:
        return AppColor.danger;

      case PlaceType.police:
        return AppColor.info;

      case PlaceType.fire_station:
        return AppColor.warning;

      case PlaceType.shelter:
        return AppColor.safeGreen;
    }
  }

  // ===============================================================
  // ICONS
  // ===============================================================

  IconData _iconForPlaceType(
    PlaceType type,
  ) {
    switch (type) {
      case PlaceType.hospital:
        return Icons.medical_services_rounded;

      case PlaceType.police:
        return Icons.local_police_rounded;

      case PlaceType.fire_station:
        return Icons.fire_truck_rounded;

      case PlaceType.shelter:
        return Icons.home_work_rounded;
    }
  }
}
