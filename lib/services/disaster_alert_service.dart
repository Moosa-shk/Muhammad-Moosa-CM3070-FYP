// lib/services/disaster_alert_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../models/disaster_alert_model.dart';
import 'location_service.dart';

/// ============================================================================
/// DISASTER ALERT SERVICE
/// ============================================================================
///
/// Professional alert aggregation service for RescueAid.
///
/// Sources:
///
/// 1. USGS
///    - Earthquakes near the user's real location
///    - Earthquakes inside the Pakistan monitoring region
///
/// 2. GDACS
///    - Multi-hazard disaster events affecting Pakistan
///
/// The service intentionally keeps every external source isolated.
/// If GDACS fails, USGS data can still be displayed.
/// If USGS fails, GDACS data can still be displayed.
///
/// An empty successful response is different from an API failure.
/// ============================================================================

class DisasterAlertService {
  final LocationService _locationService =
      LocationService.instance;

  // ==========================================================================
  // CONSTANTS
  // ==========================================================================

  static const int nearbyRadiusKm = 500;

  static const Duration currentWindow =
      Duration(hours: 24);

  static const Duration recentWindow =
      Duration(days: 30);

  // Pakistan monitoring bounds.
  static const double _pakMinLat = 23.5;
  static const double _pakMaxLat = 37.5;
  static const double _pakMinLon = 60.5;
  static const double _pakMaxLon = 77.5;

  // ==========================================================================
  // GDACS FEED FALLBACKS
  // ==========================================================================

  /// GDACS provides multiple official XML feeds.
  ///
  /// We try the smaller/recent feeds first and then fall back to the
  /// broader feed if required.
  static const List<String> _gdacsFeeds = [
    'https://www.gdacs.org/contentdata/xml/rss_24h.xml',
    'https://www.gdacs.org/contentdata/xml/rss_7d.xml',
    'https://www.gdacs.org/contentdata/xml/rss.xml',
  ];

  // ==========================================================================
  // PUBLIC API
  // ==========================================================================

  /// Main method used by the alerts screen.
  ///
  /// Returns a complete snapshot containing:
  ///
  /// - actual location status
  /// - nearby alerts
  /// - current Pakistan alerts
  /// - recent Pakistan alerts
  /// - individual source health
  Future<DisasterAlertSnapshot> fetchAlertSnapshot() async {
    // ------------------------------------------------------------------------
    // 1. LOCATION
    // ------------------------------------------------------------------------

    final locationResult =
        await _resolveUserLocation();

    // ------------------------------------------------------------------------
    // 2. START ALL NETWORK SOURCES
    // ------------------------------------------------------------------------

    final nearbyFuture =
        locationResult.position == null
            ? Future.value(
                const _SourceResult(
                  success: false,
                  skipped: true,
                  alerts: [],
                ),
              )
            : _safeSource(
                () => _fetchUSGSNearby(
                  locationResult.position!,
                ),
              );

    final pakistanEarthquakeFuture =
        _safeSource(
      _fetchUSGSPakistan,
    );

    final gdacsFuture =
        _safeSource(
      _fetchGDACSPakistan,
    );

    final results =
        await Future.wait([
      nearbyFuture,
      pakistanEarthquakeFuture,
      gdacsFuture,
    ]);

    final nearbySource = results[0];
    final pakistanUSGS = results[1];
    final gdacs = results[2];

    // ------------------------------------------------------------------------
    // 3. TOTAL SOURCE FAILURE
    // ------------------------------------------------------------------------

    final anyAlertSourceSucceeded =
        nearbySource.success ||
            pakistanUSGS.success ||
            gdacs.success;

    if (!anyAlertSourceSucceeded) {
      throw Exception(
        'Alert services are currently unavailable. Please try again.',
      );
    }

    // ------------------------------------------------------------------------
    // 4. PREPARE LISTS
    // ------------------------------------------------------------------------

    final now =
        DateTime.now().toUtc();

    final nearby =
        _dedupeAlerts(
      nearbySource.alerts,
    );

    final pakistanCombined =
        _dedupeAlerts([
      ...pakistanUSGS.alerts,
      ...gdacs.alerts,
    ]);

    // ------------------------------------------------------------------------
    // 5. NEARBY = <= 24 HOURS
    // ------------------------------------------------------------------------

    final nearbyCurrent =
        nearby.where((alert) {
      return _isCurrent(
        alert.publishedAt,
        now,
      );
    }).toList();

    // ------------------------------------------------------------------------
    // 6. PAKISTAN CURRENT = <= 24 HOURS
    // ------------------------------------------------------------------------

    final pakistanCurrent =
        pakistanCombined.where((alert) {
      return _isCurrent(
        alert.publishedAt,
        now,
      );
    }).toList();

    // ------------------------------------------------------------------------
    // 7. RECENT = > 24 HOURS AND <= 30 DAYS
    // ------------------------------------------------------------------------

    final recentPakistan =
        pakistanCombined.where((alert) {
      final date =
          alert.publishedAt.toUtc();

      final age =
          now.difference(date);

      if (age.isNegative) {
        return false;
      }

      return age > currentWindow &&
          age <= recentWindow;
    }).toList();

    // ------------------------------------------------------------------------
    // 8. NEWEST FIRST
    // ------------------------------------------------------------------------

    _sortNewestFirst(
      nearbyCurrent,
    );

    _sortNewestFirst(
      pakistanCurrent,
    );

    _sortNewestFirst(
      recentPakistan,
    );

    // ------------------------------------------------------------------------
    // 9. HUMAN READABLE WARNING
    // ------------------------------------------------------------------------

    final unavailableSources =
        <String>[];

    if (locationResult.position != null &&
        !nearbySource.success) {
      unavailableSources.add(
        'nearby earthquake service',
      );
    }

    if (!pakistanUSGS.success) {
      unavailableSources.add(
        'USGS Pakistan',
      );
    }

    if (!gdacs.success) {
      unavailableSources.add(
        'GDACS',
      );
    }

    String? partialWarning;

    if (unavailableSources.isNotEmpty) {
      partialWarning =
          'Some live sources are temporarily unavailable: '
          '${unavailableSources.join(', ')}.';
    }

    // ------------------------------------------------------------------------
    // 10. SNAPSHOT
    // ------------------------------------------------------------------------

    return DisasterAlertSnapshot(
      nearbyAlerts: nearbyCurrent,
      pakistanCurrentAlerts:
          pakistanCurrent,
      recentPakistanAlerts:
          recentPakistan,

      userLocation:
          locationResult.position,

      locationAvailable:
          locationResult.position != null,

      locationMessage:
          locationResult.message,

      nearbySourceAvailable:
          nearbySource.success,

      usgsPakistanAvailable:
          pakistanUSGS.success,

      gdacsAvailable:
          gdacs.success,

      partialWarning:
          partialWarning,

      fetchedAt:
          DateTime.now(),
    );
  }

  /// --------------------------------------------------------------------------
  /// BACKWARD COMPATIBILITY
  /// --------------------------------------------------------------------------
  ///
  /// Existing code elsewhere in the app can still call the old method.
  Future<List<DisasterAlert>>
      fetchRealTimeAlerts() async {
    final snapshot =
        await fetchAlertSnapshot();

    return _dedupeAlerts([
      ...snapshot.nearbyAlerts,
      ...snapshot.pakistanCurrentAlerts,
      ...snapshot.recentPakistanAlerts,
    ]);
  }

  // ==========================================================================
  // LOCATION
  // ==========================================================================

  Future<_LocationResult>
      _resolveUserLocation() async {
    try {
      // ----------------------------------------------------------------------
      // Request permission/service through the existing global location service.
      // ----------------------------------------------------------------------

      final ready =
          await _locationService
              .ensureReady()
              .timeout(
                const Duration(
                  seconds: 10,
                ),
              );

      if (!ready) {
        return const _LocationResult(
          position: null,
          message:
              'Location permission is not available.',
        );
      }

      // ----------------------------------------------------------------------
      // Try best-effort location.
      // ----------------------------------------------------------------------

      final location =
          await _locationService
              .getBestEffort(
                oneShotTimeout:
                    const Duration(
                  seconds: 6,
                ),
                streamTimeout:
                    const Duration(
                  seconds: 7,
                ),
              )
              .timeout(
                const Duration(
                  seconds: 14,
                ),
              );

      final lat =
          location?.latitude;

      final lng =
          location?.longitude;

      if (lat == null ||
          lng == null) {
        return const _LocationResult(
          position: null,
          message:
              'Current GPS location could not be determined.',
        );
      }

      if (!_validLatLng(
        lat,
        lng,
      )) {
        return const _LocationResult(
          position: null,
          message:
              'The device returned an invalid location.',
        );
      }

      return _LocationResult(
        position:
            LatLng(
          lat,
          lng,
        ),
        message:
            'Location available',
      );
    } catch (_) {
      return const _LocationResult(
        position: null,
        message:
            'Current location is temporarily unavailable.',
      );
    }
  }

  // ==========================================================================
  // USGS — NEAR USER
  // ==========================================================================

  Future<List<DisasterAlert>>
      _fetchUSGSNearby(
    LatLng center,
  ) async {
    final startTime =
        DateTime.now()
            .toUtc()
            .subtract(
              const Duration(
                days: 7,
              ),
            )
            .toIso8601String();

    final uri =
        Uri.https(
      'earthquake.usgs.gov',
      '/fdsnws/event/1/query',
      {
        'format':
            'geojson',

        'starttime':
            startTime,

        'latitude':
            center.latitude
                .toString(),

        'longitude':
            center.longitude
                .toString(),

        'maxradiuskm':
            nearbyRadiusKm
                .toString(),

        'orderby':
            'time',

        'limit':
            '300',
      },
    );

    final response =
        await http
            .get(
              uri,
              headers:
                  const {
                'Accept':
                    'application/json',
                'User-Agent':
                    'RescueAid/1.0 (Flutter)',
              },
            )
            .timeout(
              const Duration(
                seconds: 15,
              ),
            );

    if (response.statusCode !=
        200) {
      throw Exception(
        'USGS nearby HTTP ${response.statusCode}',
      );
    }

    return _parseUSGS(
      response.body,
      source:
          'USGS Nearby',
    );
  }

  // ==========================================================================
  // USGS — PAKISTAN
  // ==========================================================================

  Future<List<DisasterAlert>>
      _fetchUSGSPakistan() async {
    final startTime =
        DateTime.now()
            .toUtc()
            .subtract(
              recentWindow,
            )
            .toIso8601String();

    final uri =
        Uri.https(
      'earthquake.usgs.gov',
      '/fdsnws/event/1/query',
      {
        'format':
            'geojson',

        'starttime':
            startTime,

        'minlatitude':
            _pakMinLat
                .toString(),

        'maxlatitude':
            _pakMaxLat
                .toString(),

        'minlongitude':
            _pakMinLon
                .toString(),

        'maxlongitude':
            _pakMaxLon
                .toString(),

        'orderby':
            'time',

        'limit':
            '500',
      },
    );

    final response =
        await http
            .get(
              uri,
              headers:
                  const {
                'Accept':
                    'application/json',
                'User-Agent':
                    'RescueAid/1.0 (Flutter)',
              },
            )
            .timeout(
              const Duration(
                seconds: 15,
              ),
            );

    if (response.statusCode !=
        200) {
      throw Exception(
        'USGS Pakistan HTTP ${response.statusCode}',
      );
    }

    return _parseUSGS(
      response.body,
      source:
          'USGS',
    );
  }

  // ==========================================================================
  // USGS PARSER
  // ==========================================================================

  List<DisasterAlert> _parseUSGS(
    String body, {
    required String source,
  }) {
    final decoded =
        jsonDecode(body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid USGS response.',
      );
    }

    final features =
        decoded['features'];

    if (features is! List) {
      return [];
    }

    final alerts =
        <DisasterAlert>[];

    for (final feature
        in features) {
      if (feature is! Map) {
        continue;
      }

      final properties =
          feature['properties'];

      if (properties is! Map) {
        continue;
      }

      final timestamp =
          properties['time'];

      if (timestamp is! num) {
        continue;
      }

      final magnitude =
          (properties['mag']
                  as num?)
              ?.toDouble();

      final place =
          (properties['place'] ??
                  'Pakistan region')
              .toString()
              .trim();

      final url =
          (properties['url'] ??
                  '')
              .toString();

      final id =
          (feature['id'] ??
                  '')
              .toString();

      final title =
          magnitude == null
              ? 'Earthquake Detected'
              : 'Magnitude ${magnitude.toStringAsFixed(1)} Earthquake';

      final summary =
          place.isEmpty
              ? 'Earthquake activity was detected in the monitored region.'
              : 'Earthquake detected near $place.';

      alerts.add(
        DisasterAlert(
          id: id.isEmpty
              ? '$source-$timestamp'
              : id,

          title:
              title,

          summary:
              summary,

          publishedAt:
              DateTime
                  .fromMillisecondsSinceEpoch(
            timestamp.toInt(),
            isUtc: true,
          ),

          source:
              source,

          url:
              url,

          magnitude:
              magnitude,

          severity:
              _earthquakeSeverity(
            magnitude,
          ),
        ),
      );
    }

    return alerts;
  }

  // ==========================================================================
  // GDACS
  // ==========================================================================

  Future<List<DisasterAlert>>
      _fetchGDACSPakistan() async {
    Object? lastError;

    // ------------------------------------------------------------------------
    // Try every official feed until one responds correctly.
    // ------------------------------------------------------------------------

    for (final feed
        in _gdacsFeeds) {
      try {
        final response =
            await http
                .get(
                  Uri.parse(feed),
                  headers:
                      const {
                    'Accept':
                        'application/rss+xml, application/xml, text/xml',
                    'User-Agent':
                        'RescueAid/1.0 (Flutter)',
                  },
                )
                .timeout(
                  const Duration(
                    seconds: 15,
                  ),
                );

        if (response.statusCode !=
            200) {
          lastError =
              'GDACS HTTP ${response.statusCode}';

          continue;
        }

        if (response.body
            .trim()
            .isEmpty) {
          lastError =
              'GDACS returned an empty response';

          continue;
        }

        final alerts =
            _parseGDACS(
          response.body,
        );

        return alerts;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception(
      lastError?.toString() ??
          'GDACS is unavailable.',
    );
  }

  // ==========================================================================
  // GDACS PARSER
  // ==========================================================================

  List<DisasterAlert> _parseGDACS(
    String xmlSource,
  ) {
    final document =
        XmlDocument.parse(
      xmlSource,
    );

    final items =
        document
            .findAllElements(
              'item',
            )
            .toList();

    final alerts =
        <DisasterAlert>[];

    for (final item
        in items) {
      final title =
          _directChildText(
            item,
            'title',
          ) ??
              '';

      final description =
          _directChildText(
            item,
            'description',
          ) ??
              '';

      final link =
          _directChildText(
            item,
            'link',
          ) ??
              '';

      final pubDate =
          _directChildText(
        item,
        'pubDate',
      );

      final country =
          _descendantByLocalName(
            item,
            'country',
          ) ??
              '';

      final eventType =
          _descendantByLocalName(
            item,
            'eventtype',
          ) ??
              '';

      final alertLevel =
          _descendantByLocalName(
            item,
            'alertlevel',
          ) ??
              '';

      final severity =
          _descendantByLocalName(
            item,
            'severity',
          ) ??
              '';

      final combined =
          '$title $description $country'
              .toLowerCase();

      // ----------------------------------------------------------------------
      // Pakistan relevance.
      // ----------------------------------------------------------------------

      if (!_mentionsPakistan(
        combined,
      )) {
        continue;
      }

      final published =
          _parseFeedDate(
        pubDate,
      );

      if (published == null) {
        continue;
      }

      final cleanedDescription =
          _stripHtml(
        description,
      );

      final finalTitle =
          title.trim().isNotEmpty
              ? title.trim()
              : _eventTypeTitle(
                  eventType,
                );

      alerts.add(
        DisasterAlert(
          id:
              '${finalTitle}_${published.millisecondsSinceEpoch}_$link'
                  .hashCode
                  .toString(),

          title:
              finalTitle,

          summary:
              cleanedDescription
                      .isNotEmpty
                  ? cleanedDescription
                  : 'A disaster event affecting Pakistan has been reported by GDACS.',

          publishedAt:
              published,

          source:
              'GDACS',

          url:
              link,

          severity:
              _gdacsSeverity(
            alertLevel:
                alertLevel,
            severity:
                severity,
          ),

          magnitude:
              _extractMagnitude(
            '$title $description',
          ),
        ),
      );
    }

    return _dedupeAlerts(
      alerts,
    );
  }

  // ==========================================================================
  // SOURCE WRAPPER
  // ==========================================================================

  Future<_SourceResult> _safeSource(
    Future<List<DisasterAlert>>
        Function() request,
  ) async {
    try {
      final alerts =
          await request();

      return _SourceResult(
        success: true,
        alerts: alerts,
      );
    } catch (e) {
      return _SourceResult(
        success: false,
        alerts: const [],
        error:
            e.toString(),
      );
    }
  }

  // ==========================================================================
  // DEDUPLICATION
  // ==========================================================================

  List<DisasterAlert> _dedupeAlerts(
    Iterable<DisasterAlert> input,
  ) {
    final unique =
        <String, DisasterAlert>{};

    for (final alert
        in input) {
      final normalizedTitle =
          alert.title
              .trim()
              .toLowerCase();

      final timestampBucket =
          alert.publishedAt
              .toUtc()
              .millisecondsSinceEpoch ~/
          const Duration(
            minutes: 10,
          ).inMilliseconds;

      final key =
          '${alert.source}|'
          '${alert.id}|'
          '$normalizedTitle|'
          '$timestampBucket';

      unique[key] = alert;
    }

    final result =
        unique.values.toList();

    _sortNewestFirst(
      result,
    );

    return result;
  }

  // ==========================================================================
  // TIME
  // ==========================================================================

  bool _isCurrent(
    DateTime date,
    DateTime now,
  ) {
    final age =
        now.difference(
      date.toUtc(),
    );

    if (age.isNegative) {
      return false;
    }

    return age <=
        currentWindow;
  }

  void _sortNewestFirst(
    List<DisasterAlert> alerts,
  ) {
    alerts.sort(
      (a, b) =>
          b.publishedAt.compareTo(
        a.publishedAt,
      ),
    );
  }

  // ==========================================================================
  // SEVERITY
  // ==========================================================================

  String _earthquakeSeverity(
    num? magnitude,
  ) {
    if (magnitude == null) {
      return 'Low';
    }

    if (magnitude >= 6.0) {
      return 'Severe';
    }

    if (magnitude >= 5.0) {
      return 'High';
    }

    if (magnitude >= 4.0) {
      return 'Moderate';
    }

    return 'Low';
  }

  String _gdacsSeverity({
    required String alertLevel,
    required String severity,
  }) {
    final combined =
        '$alertLevel $severity'
            .toLowerCase();

    if (combined.contains(
      'red',
    )) {
      return 'Severe';
    }

    if (combined.contains(
      'orange',
    )) {
      return 'High';
    }

    if (combined.contains(
      'yellow',
    )) {
      return 'Moderate';
    }

    if (combined.contains(
      'green',
    )) {
      return 'Low';
    }

    return 'Moderate';
  }

  // ==========================================================================
  // PAKISTAN DETECTION
  // ==========================================================================

  bool _mentionsPakistan(
    String text,
  ) {
    const indicators = [
      'pakistan',
      'islamabad',
      'rawalpindi',
      'lahore',
      'karachi',
      'peshawar',
      'quetta',
      'faisalabad',
      'multan',
      'hyderabad',
      'sialkot',
      'gujranwala',
      'bahawalpur',
      'sukkur',
      'abbottabad',
      'mansehra',
      'swat',
      'gilgit',
      'skardu',
      'muzaffarabad',
      'balochistan',
      'baluchistan',
      'punjab',
      'sindh',
      'khyber pakhtunkhwa',
      'kpk',
      'azad kashmir',
    ];

    return indicators.any(
      text.contains,
    );
  }

  // ==========================================================================
  // XML HELPERS
  // ==========================================================================

  String? _directChildText(
    XmlElement parent,
    String localName,
  ) {
    for (final child
        in parent.children) {
      if (child is! XmlElement) {
        continue;
      }

      if (child.name.local
              .toLowerCase() ==
          localName.toLowerCase()) {
        final text =
            child.innerText.trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return null;
  }

  String? _descendantByLocalName(
    XmlElement element,
    String localName,
  ) {
    for (final node
        in element.descendants) {
      if (node is! XmlElement) {
        continue;
      }

      if (node.name.local
              .toLowerCase() ==
          localName.toLowerCase()) {
        final text =
            node.innerText.trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return null;
  }

  // ==========================================================================
  // DATE PARSER
  // ==========================================================================

  DateTime? _parseFeedDate(
    String? raw,
  ) {
    if (raw == null ||
        raw.trim().isEmpty) {
      return null;
    }

    final value =
        raw.trim();

    try {
      return HttpDate.parse(
        value,
      ).toUtc();
    } catch (_) {}

    try {
      return DateTime.parse(
        value,
      ).toUtc();
    } catch (_) {}

    return null;
  }

  // ==========================================================================
  // HTML CLEANER
  // ==========================================================================

  String _stripHtml(
    String value,
  ) {
    return value
        .replaceAll(
          RegExp(
            r'<[^>]*>',
            multiLine: true,
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          '&nbsp;',
          ' ',
        )
        .replaceAll(
          '&amp;',
          '&',
        )
        .replaceAll(
          '&lt;',
          '<',
        )
        .replaceAll(
          '&gt;',
          '>',
        )
        .replaceAll(
          RegExp(
            r'\s+',
          ),
          ' ',
        )
        .trim();
  }

  // ==========================================================================
  // GDACS EVENT TITLE
  // ==========================================================================

  String _eventTypeTitle(
    String type,
  ) {
    switch (type
        .trim()
        .toUpperCase()) {
      case 'EQ':
        return 'Earthquake Alert in Pakistan';

      case 'FL':
        return 'Flood Alert in Pakistan';

      case 'TC':
        return 'Cyclone Alert for Pakistan';

      case 'DR':
        return 'Drought Alert in Pakistan';

      case 'WF':
        return 'Wildfire Alert in Pakistan';

      case 'VO':
        return 'Volcanic Activity Alert';

      default:
        return 'Disaster Alert for Pakistan';
    }
  }

  // ==========================================================================
  // MAGNITUDE
  // ==========================================================================

  double? _extractMagnitude(
    String text,
  ) {
    final patterns = [
      RegExp(
        r'\bM\s*([0-9]+(?:\.[0-9]+)?)',
        caseSensitive: false,
      ),
      RegExp(
        r'magnitude[:\s]*([0-9]+(?:\.[0-9]+)?)',
        caseSensitive: false,
      ),
    ];

    for (final expression
        in patterns) {
      final match =
          expression.firstMatch(
        text,
      );

      final parsed =
          double.tryParse(
        match?.group(1) ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  // ==========================================================================
  // COORDINATES
  // ==========================================================================

  bool _validLatLng(
    double lat,
    double lng,
  ) {
    return lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }
}

/// ============================================================================
/// ALERT SNAPSHOT
/// ============================================================================

class DisasterAlertSnapshot {
  final List<DisasterAlert>
      nearbyAlerts;

  final List<DisasterAlert>
      pakistanCurrentAlerts;

  final List<DisasterAlert>
      recentPakistanAlerts;

  final LatLng? userLocation;

  final bool locationAvailable;

  final String locationMessage;

  final bool nearbySourceAvailable;

  final bool usgsPakistanAvailable;

  final bool gdacsAvailable;

  final String? partialWarning;

  final DateTime fetchedAt;

  const DisasterAlertSnapshot({
    required this.nearbyAlerts,
    required this.pakistanCurrentAlerts,
    required this.recentPakistanAlerts,
    required this.userLocation,
    required this.locationAvailable,
    required this.locationMessage,
    required this.nearbySourceAvailable,
    required this.usgsPakistanAvailable,
    required this.gdacsAvailable,
    required this.partialWarning,
    required this.fetchedAt,
  });

  bool get pakistanDataAvailable =>
      usgsPakistanAvailable ||
      gdacsAvailable;
}

/// ============================================================================
/// INTERNAL SOURCE RESULT
/// ============================================================================

class _SourceResult {
  final bool success;
  final bool skipped;
  final List<DisasterAlert> alerts;
  final String? error;

  const _SourceResult({
    required this.success,
    required this.alerts,
    this.skipped = false,
    this.error,
  });
}

/// ============================================================================
/// INTERNAL LOCATION RESULT
/// ============================================================================

class _LocationResult {
  final LatLng? position;
  final String message;

  const _LocationResult({
    required this.position,
    required this.message,
  });
}