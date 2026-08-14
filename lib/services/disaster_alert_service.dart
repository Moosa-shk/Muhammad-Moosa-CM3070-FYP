import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/disaster_alert_model.dart';

/// Service responsible for fetching real-time disaster alerts
/// from multiple external sources such as USGS and GDACS.
/// The alerts are filtered to show only events relevant to Pakistan.
class DisasterAlertService {

  /// Fetches real-time disaster alerts from multiple APIs in parallel.
  /// This improves performance by retrieving earthquake and disaster
  /// alerts simultaneously.
  Future<List<DisasterAlert>> fetchRealTimeAlerts() async {
    try {

      /// Run both API requests at the same time
      final results = await Future.wait([
        _fetchEarthquakesPakistanOnly(),
        _fetchGDACSAllPakistanAlerts(),
      ]).timeout(const Duration(seconds: 6));

      /// Combine results from both sources into a single list
      return [...results[0], ...results[1]];
    } catch (_) {

      /// If any error occurs, return an empty alert list
      return [];
    }
  }

  // ==========================
  // EARTHQUAKES — PAKISTAN ONLY
  // ==========================

  /// Fetch earthquake data from the USGS API.
  /// The query is restricted to geographical coordinates
  /// that correspond to Pakistan.
  Future<List<DisasterAlert>> _fetchEarthquakesPakistanOnly() async {

    /// USGS earthquake API request with Pakistan bounding box
    final uri = Uri.parse(
      "https://earthquake.usgs.gov/fdsnws/event/1/query"
      "?format=geojson"
      "&minlatitude=23.5"
      "&maxlatitude=37.5"
      "&minlongitude=60.5"
      "&maxlongitude=77.5"
      "&orderby=time",
    );

    /// Send HTTP request with timeout protection
    final res =
        await http.get(uri).timeout(const Duration(seconds: 4));

    /// If API request fails, return empty list
    if (res.statusCode != 200) return [];

    /// Decode JSON response
    final data = json.decode(res.body);
    final List features = data['features'] ?? [];

    /// Convert each earthquake entry into a DisasterAlert model
    return features.map((e) {
      final p = e['properties'];
      return DisasterAlert(
        id: e['id'],
        title: "Earthquake Detected",
        summary: p['place'] ?? "Earthquake in Pakistan",
        publishedAt:
            DateTime.fromMillisecondsSinceEpoch(p['time']),
        source: "USGS",
        url: p['url'] ?? "",
        magnitude: (p['mag'] as num?)?.toDouble(),
        severity: _eqSeverity(p['mag']),
      );
    }).toList();
  }

  /// Determines earthquake severity level based on magnitude.
  String _eqSeverity(num? mag) {
    if (mag == null) return "Low";
    if (mag >= 6) return "Severe";
    if (mag >= 4.5) return "Moderate";
    return "Low";
  }

  // ==========================
  // GDACS — ALL DISASTERS
  // ==========================

  /// Fetch disaster alerts from the GDACS RSS feed.
  /// This includes floods, cyclones, and other disasters.
  Future<List<DisasterAlert>> _fetchGDACSAllPakistanAlerts() async {

    /// Send HTTP request to the GDACS RSS feed
    final res = await http
        .get(Uri.parse("https://www.gdacs.org/xml/rss.xml"))
        .timeout(const Duration(seconds: 4));

    /// If request fails, return empty list
    if (res.statusCode != 200) return [];

    final xml = res.body;
    final List<DisasterAlert> alerts = [];

    /// Parse RSS feed manually and extract disaster items
    for (final item in xml.split("<item>").skip(1)) {

      final title = _x(item, "title") ?? "";
      final desc = _x(item, "description") ?? "";
      final pubDate = _x(item, "pubDate");
      final link = _x(item, "link") ?? "";

      /// Filter results so only Pakistan-related alerts are included
      if (!_mentionsPakistan("$title $desc".toLowerCase())) continue;

      /// Convert RSS entry into DisasterAlert model
      alerts.add(
        DisasterAlert(
          id: "$title-$pubDate".hashCode.toString(),
          title: title,
          summary: desc,
          publishedAt:
              DateTime.tryParse(pubDate ?? "") ?? DateTime.now(),
          source: "GDACS",
          url: link,
          severity: "High",
          magnitude: null,
        ),
      );
    }

    return alerts;
  }

  /// Checks whether a disaster alert references Pakistan
  /// or one of its major cities.
  bool _mentionsPakistan(String text) =>
      ["pakistan", "lahore", "karachi", "islamabad"]
          .any(text.contains);

  /// Helper function used to extract values from RSS XML tags.
  String? _x(String xml, String tag) {
    final s = xml.indexOf("<$tag>");
    final e = xml.indexOf("</$tag>");
    if (s == -1 || e == -1) return null;
    return xml.substring(s + tag.length + 2, e);
  }
}