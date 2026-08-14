// lib/services/chatbot_service.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/chat_message.dart';
import '../models/disaster_alert_model.dart';
import '../widgets/bot_alert_cards.dart';
import '../widgets/bot_places_cards.dart';
import 'chatbot/intent_router.dart';
import 'chatbot/knowledge_base.dart';

// existing services
import 'location_service.dart';
import 'disaster_alert_service.dart';
import 'openmap_service.dart';

/// ChatbotService handles the chatbot logic of the application.
/// It analyzes the user's message, detects the intent, and
/// returns an appropriate response such as alerts, nearby services,
/// SOS guidance, or general disaster knowledge.
class ChatbotService {
  ChatbotService({
    LocationService? locationService,
    DisasterAlertService? alertService,
    IntentRouter? router,
  })  : _location = locationService ?? LocationService.instance,
        _alerts = alertService ?? DisasterAlertService(),
        _router = router ?? IntentRouter();

  final LocationService _location;
  final DisasterAlertService _alerts;
  final IntentRouter _router;

  /// Main chatbot reply function.
  /// It detects the intent of the user's message
  /// and returns a ready ChatMessage (text or widget).
  Future<ChatMessage> reply(String userText) async {
    final intent = _router.detect(userText);

    switch (intent) {

      /// SOS instructions
      case BotIntent.sos:
        return ChatMessage(
          role: ChatRole.bot,
          text:
              "To send an SOS request, press the **SOS Emergency** button on the Home screen.\nMake sure your emergency contact is set in the profile.\nInclude a short message and share your location.",
        );

      /// Disaster alerts panel
      case BotIntent.alerts:
        return await _handleAlertsPanel();

      /// Nearby hospitals
      case BotIntent.nearbyHospital:
        return await _handleNearbyPanel(type: "hospital", label: "Hospitals");

      /// Nearby shelters
      case BotIntent.nearbyShelter:
        return await _handleNearbyPanel(type: "shelter", label: "Shelters");

      /// Nearby police stations
      case BotIntent.nearbyPolice:
        return await _handleNearbyPanel(type: "police", label: "Police Stations");

      /// Nearby fire stations
      case BotIntent.nearbyFire:
        return await _handleNearbyPanel(
            type: "fire_station", label: "Fire Stations");

      /// General questions handled by offline knowledge
      case BotIntent.general:
        final offline = FreeKnowledge.answer(userText);

        if (offline != null) {
          return ChatMessage(role: ChatRole.bot, text: offline);
        }

        return ChatMessage(
          role: ChatRole.bot,
          text:
              "I am running in FREE mode.\nTry asking:\n- alerts\n- nearest hospital\n- nearest shelter\n- police near me\n- fire station\n- earthquake safety\n- flood safety",
        );
    }
  }

  // ================= ALERTS SECTION =================

  /// Builds the disaster alerts panel shown in the chatbot.
  /// It fetches alerts, filters them for Pakistan, and
  /// categorizes them into near, current, and recent alerts.
  Future<ChatMessage> _handleAlertsPanel() async {
    final raw = await _alerts.fetchRealTimeAlerts();
    final cleaned = raw.map(_sanitizeAlert).toList();

    /// Keep only alerts related to Pakistan or major Pakistani cities
    final pakistanOnly = cleaned.where((a) {
      final t = ("${a.title} ${a.summary}").toLowerCase();
      return _mentionsPakistan(t);
    }).toList();

    final now = DateTime.now();

    /// Alerts near the user (USGS earthquakes within last 24 hours)
    final nearYou = pakistanOnly
        .where((a) =>
            a.source == "USGS" &&
            now.difference(a.publishedAt).inHours <= 24 &&
            a.magnitude != null)
        .toList();

    /// Current alerts in Pakistan (non-USGS within last 24 hours)
    final currentPakistan = pakistanOnly
        .where((a) =>
            a.source != "USGS" && now.difference(a.publishedAt).inHours <= 24)
        .toList();

    /// Older alerts (more than 24 hours old)
    final recentPakistan = pakistanOnly
        .where((a) => now.difference(a.publishedAt).inHours > 24)
        .toList();

    return ChatMessage(
      role: ChatRole.bot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Alerts",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),

          BotAlertsPanel(
            title: "Current Alerts • Near You",
            alerts: nearYou,
            emptyTitle: "You Are Safe",
            emptySubtitle: "No active alerts near your location",
          ),

          const SizedBox(height: 14),

          BotAlertsPanel(
            title: "Current Alerts • Pakistan",
            alerts: currentPakistan,
            emptyTitle: "All Clear",
            emptySubtitle: "No active disaster alerts in Pakistan",
          ),

          const SizedBox(height: 14),

          BotAlertsPanel(
            title: "Recent Alerts • Pakistan",
            alerts: recentPakistan,
            emptyTitle: "No Recent Alerts",
            emptySubtitle: "There have been no recent disaster events",
          ),
        ],
      ),
    );
  }

  /// Checks if an alert text mentions Pakistan or major cities
  bool _mentionsPakistan(String text) {
    final keys = [
      "pakistan",
      "lahore",
      "karachi",
      "islamabad",
      "rawalpindi",
      "peshawar",
      "quetta",
      "multan",
      "faisalabad",
      "hyderabad",
      "sialkot",
    ];
    return keys.any(text.contains);
  }

  /// Detects if an alert refers to multiple countries
  bool _isMultiCountry(String text) {
    final countries = [
      "afghanistan",
      "india",
      "iran",
      "iraq",
      "china",
      "turkey",
      "türkiye",
      "syria",
      "kazakhstan",
      "kyrgyzstan",
      "tajikistan",
      "turkmenistan",
      "uzbekistan",
      "nepal",
      "bangladesh",
      "sri lanka",
    ];

    int count = 0;

    for (final c in countries) {
      if (text.contains(c)) count++;
      if (count >= 2) return true;
    }

    return false;
  }

  /// Cleans alert text when multiple countries are mentioned
  DisasterAlert _sanitizeAlert(DisasterAlert alert) {
    final text = "${alert.title} ${alert.summary}".toLowerCase();

    if (_isMultiCountry(text)) {
      return DisasterAlert(
        id: alert.id,
        title: _rewriteTitle(alert.title),
        summary: _rewriteSummary(alert.summary),
        publishedAt: alert.publishedAt,
        source: alert.source,
        url: alert.url,
        severity: alert.severity,
        magnitude: alert.magnitude,
      );
    }

    return alert;
  }

  /// Rewrites alert titles to be Pakistan-specific
  String _rewriteTitle(String title) {
    final t = title.toLowerCase();

    if (t.contains("drought")) return "Drought Ongoing in Pakistan";
    if (t.contains("flood")) return "Flood Alert in Pakistan";
    if (t.contains("earthquake")) return "Earthquake Detected in Pakistan";
    if (t.contains("cyclone")) return "Cyclone Alert for Pakistan";

    return "Disaster Alert for Pakistan";
  }

  /// Rewrites summaries into simplified Pakistan-focused alerts
  String _rewriteSummary(String summary) {
    final s = summary.toLowerCase();

    if (s.contains("drought")) {
      return "Drought conditions are currently affecting parts of Pakistan. Authorities advise precautionary measures.";
    }

    if (s.contains("flood")) {
      return "Flood risk remains active in Pakistan. Stay alert and follow official guidance.";
    }

    if (s.contains("earthquake")) {
      return "Seismic activity has been detected in Pakistan. Monitor official updates.";
    }

    return "A disaster alert is currently active for Pakistan.";
  }

  // ================= NEARBY PLACES SECTION =================

  /// Returns nearby emergency facilities such as hospitals,
  /// shelters, police stations, or fire stations.
  Future<ChatMessage> _handleNearbyPanel({
    required String type,
    required String label,
  }) async {

    final ok = await _location.ensureReady();

    if (!ok) {
      return ChatMessage(
        role: ChatRole.bot,
        text:
            "Please allow location permission in Settings and turn location services ON.\nThen I will show nearby $label.",
      );
    }

    final pos = await _getLatLng();

    if (pos == null) {
      return ChatMessage(
        role: ChatRole.bot,
        text:
            "Location could not be detected.\n\nIf you are using an iOS Simulator:\nFeatures → Location → Select a location.\n\nThen try again: nearest hospital",
      );
    }

    final results = await OpenMapService.fetchNearbyPlaces(
      center: pos,
      type: type,
      radius: 3000,
    );

    final places = results.map((p) {
      final tags = (p['tags'] as Map?) ?? {};
      final name = (tags['name'] ?? "Unnamed").toString();

      return BotPlace(
        name: name,
        lat: (p['lat'] as num).toDouble(),
        lon: (p['lon'] as num).toDouble(),
      );
    }).toList();

    return ChatMessage(
      role: ChatRole.bot,
      child: BotPlacesPanel(
        title: "Nearby $label (3km)",
        places: places,
      ),
    );
  }

  /// Gets the current user latitude and longitude
  Future<LatLng?> _getLatLng() async {
    final loc = await _location.getBestEffort();
    final lat = loc?.latitude;
    final lon = loc?.longitude;

    if (lat == null || lon == null) return null;

    return LatLng(lat, lon);
  }
}