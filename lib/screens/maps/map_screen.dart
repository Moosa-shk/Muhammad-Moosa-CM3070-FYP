// lib/screens/maps/map_screen.dart
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart'; // ✅ NEW global design
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:disaster_app_ui/widgets/popup_utils.dart';
import 'package:disaster_app_ui/config/colors.dart';

enum PlaceType { hospital, police, fire_station, shelter }

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  final Location _location = Location();
  final MapController _mapController = MapController();

  LatLng _currentPos = const LatLng(31.46318, 73.0847);
  List<Marker> _markers = [];
  List<LatLng> _polyline = [];

  String _distance = "~ Nearby";
  String _duration = "-- min";
  String _selectedName = "";

  bool _menuOpen = false;
  bool _loadingPlaces = false;
  double _currentZoom = 15;

  late AnimationController _shimmerCtrl;

  static const String orsKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImM1YzkzMGFiM2ZjYTRhODc5NjU4MjY1OWVjMzM2ZTJkIiwiaCI6Im11cm11cjY0In0=';

  @override
  void initState() {
    super.initState();
    _initLocation();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      bool enabled = await _location.serviceEnabled();
      if (!enabled) enabled = await _location.requestService();

      var perm = await _location.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await _location.requestPermission();
      }
      if (perm != PermissionStatus.granted) return;

      final loc = await _location.getLocation();
      if (loc.latitude != null && loc.longitude != null) {
        setState(() => _currentPos = LatLng(loc.latitude!, loc.longitude!));
        _mapController.move(_currentPos, _currentZoom);
      }

      _location.onLocationChanged.listen((loc) {
        if (loc.latitude == null || loc.longitude == null) return;
        setState(() => _currentPos = LatLng(loc.latitude!, loc.longitude!));
      });
    } catch (_) {}
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 19.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 19.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  Future<void> _fetchPlaces(PlaceType type) async {
    final amenity = switch (type) {
      PlaceType.hospital => 'hospital',
      PlaceType.police => 'police',
      PlaceType.fire_station => 'fire_station',
      PlaceType.shelter => 'shelter',
    };

    setState(() {
      _loadingPlaces = true;
      _markers.clear();
      _polyline.clear();
    });

    PopupUtils.info("Searching", "Nearby $amenity");

    final query = '''
[out:json][timeout:25];
(
  node["amenity"="$amenity"](around:4000,${_currentPos.latitude},${_currentPos.longitude});
  way["amenity"="$amenity"](around:4000,${_currentPos.latitude},${_currentPos.longitude});
  relation["amenity"="$amenity"](around:4000,${_currentPos.latitude},${_currentPos.longitude});
);
out center;
''';

    try {
      final res = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      );

      if (!res.body.trim().startsWith('{')) {
        PopupUtils.warning("Busy", "Map service busy. Try again.");
        return;
      }

      final data = jsonDecode(res.body);
      final elements = data['elements'] ?? [];

      final markers = <Marker>[];

      for (final e in elements) {
        double? lat, lon;

        if (e['lat'] != null && e['lon'] != null) {
          lat = (e['lat'] as num).toDouble();
          lon = (e['lon'] as num).toDouble();
        } else if (e['center'] != null) {
          lat = (e['center']['lat'] as num?)?.toDouble();
          lon = (e['center']['lon'] as num?)?.toDouble();
        }

        if (lat == null || lon == null) continue;

        final name = e['tags']?['name'] ?? amenity.capitalizeFirst!;

        markers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 56,
            height: 56,
            child: GestureDetector(
              onTap: () => _onSelect(LatLng(lat!, lon!), name),
              child: const Icon(
                Icons.location_on,
                color: AppColor.primary,
                size: 44,
              ),
            ),
          ),
        );
      }

      if (markers.isEmpty) {
        PopupUtils.warning("No Results", "No $amenity nearby");
      } else {
        PopupUtils.success("Found", "${markers.length} locations");
      }

      setState(() => _markers = markers);
    } catch (e) {
      PopupUtils.error("Map Error", e.toString());
    } finally {
      setState(() => _loadingPlaces = false);
    }
  }

  Future<void> _onSelect(LatLng dest, String name) async {
    PopupUtils.info("Routing", "Calculating best path");

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$orsKey'
      '&start=${_currentPos.longitude},${_currentPos.latitude}'
      '&end=${dest.longitude},${dest.latitude}',
    );

    try {
      final res = await http.get(url);
      final data = jsonDecode(res.body);

      final feat = data['features'][0];
      final seg = feat['properties']['segments'][0];
      final coords = feat['geometry']['coordinates'] as List;

      setState(() {
        _markers = [
          Marker(
            point: dest,
            width: 56,
            height: 56,
            child: const Icon(Icons.location_on,
                color: AppColor.primary, size: 44),
          )
        ];
        _polyline = coords.map((c) => LatLng(c[1], c[0])).toList();
        _selectedName = name;
        _distance = "${(seg['distance'] / 1000).toStringAsFixed(2)} km";
        _duration = "${(seg['duration'] / 60).toStringAsFixed(0)} min";
      });
    } catch (e) {
      PopupUtils.error("Route Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Emergency Map",
      subtitle: "Find shelters and services near you",
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      appBarActions: [
        _circleBtn(
          Icons.my_location,
          () => _mapController.move(_currentPos, _currentZoom),
        ),
      ],
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPos,
                    initialZoom: _currentZoom,
                    onTap: (_, __) => setState(() => _menuOpen = false),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.disasteraid.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _polyline,
                          strokeWidth: 5,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPos,
                          width: 56,
                          height: 56,
                          child: const Icon(Icons.my_location,
                              color: AppColor.safeGreen, size: 34),
                        ),
                        ..._markers,
                      ],
                    ),
                  ],
                ),

                // zoom + menu overlays inside map card
                _zoomControls(),
                _floatingMenu(),
                if (_loadingPlaces) _shimmerOverlay(),
              ],
            ),
          ),

          if (_polyline.isNotEmpty) _routeCard(),
         
        ],
      ),
    
    );
    
  }

  Widget _zoomControls() => Positioned(
        left: 14,
        bottom: 18,
        child: Column(
          children: [
            _circleBtn(Icons.add, _zoomIn),
            const SizedBox(height: 10),
            _circleBtn(Icons.remove, _zoomOut),
          ],
        ),
      );

  Widget _shimmerOverlay() => Positioned.fill(
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => Container(
            color: Colors.white.withOpacity(0.16),
          ),
        ),
      );

  Widget _routeCard() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColor.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColor.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Distance: $_distance",
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Duration: $_duration",
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _pill(
                icon: Icons.route_rounded,
                label: "Route",
              ),
            ],
          ),
        ),
      );

  Widget _floatingMenu() {
    final items = [
      ('Hospital', Icons.local_hospital, PlaceType.hospital),
      ('Police', Icons.local_police, PlaceType.police),
      ('Fire', Icons.local_fire_department, PlaceType.fire_station),
      ('Shelter', Icons.home_work, PlaceType.shelter),
    ];

    return Positioned(
      right: 14,
      bottom: 18,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            constraints: BoxConstraints(maxHeight: _menuOpen ? 260 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColor.border),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withOpacity(0.10),
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: items
                        .map((i) => _glassChip(i.$1, i.$2, () {
                              _fetchPlaces(i.$3);
                              setState(() => _menuOpen = false);
                            }))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _circleBtn(
            _menuOpen ? Icons.close : Icons.place,
            () => setState(() => _menuOpen = !_menuOpen),
          ),
        ],
      ),
    );
  }

  Widget _pill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.primary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: AppColor.primary),
        ),
      );

  Widget _glassChip(String label, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColor.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColor.text,
                ),
              ),
            ],
          ),
        ),
      );
}