// lib/services/sos_service.dart
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:disaster_app_ui/services/location_service.dart';

/// This enum represents the different emergency types
/// a user can select when triggering an SOS alert.
enum EmergencyType { medical, fire, flood, other }

/// This extension converts the enum value into
/// a readable text label that can be used in the message.
extension EmergencyTypeX on EmergencyType {
  String get label {
    switch (this) {
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.flood:
        return 'Flood';
      case EmergencyType.other:
        return 'other';
    }
  }
}

/// This model represents the final SOS data
/// that will be sent through SMS, WhatsApp or other channels.
class SosPayload {
  final String message;
  final String? mapsLink;
  final int? batteryPercent;
  final DateTime timestamp;
  final LocationData? location;
  final EmergencyType type;

  const SosPayload({
    required this.message,
    required this.timestamp,
    required this.type,
    this.mapsLink,
    this.batteryPercent,
    this.location,
  });

  /// Used when we want to slightly modify
  /// the existing payload without rebuilding everything.
  SosPayload copyWith({
    String? message,
    String? mapsLink,
    int? batteryPercent,
    DateTime? timestamp,
    LocationData? location,
    EmergencyType? type,
  }) {
    return SosPayload(
      message: message ?? this.message,
      mapsLink: mapsLink ?? this.mapsLink,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      type: type ?? this.type,
    );
  }
}

/// Main service responsible for generating
/// and sending SOS alerts in the application.
class SosService {
  SosService._();

  static final LocationService _loc = LocationService.instance;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final Battery _battery = Battery();

  /// Native Android channel used for sending SMS directly
  /// through the Android SmsManager.
  static const MethodChannel _smsChannel =
      MethodChannel('disasteraid/sms');

  /// Removes unwanted characters from phone numbers.
  static String sanitizePhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9+]'), '');

  /// Extracts only digits from phone numbers.
  static String _digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  /// Formats numbers correctly for WhatsApp messaging.
  static String whatsappPhone(String phone) {
    final digits = _digitsOnly(phone);

    if (digits.startsWith('92')) return digits;

    if (digits.length == 11 && digits.startsWith('03')) {
      return '92${digits.substring(1)}';
    }

    return digits;
  }

  /// Checks whether the app is running on a real device.
  /// Some features like calls or SMS may not work on emulators.
  static Future<bool> isPhysicalDevice() async {
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.isPhysicalDevice ?? false;
    }

    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.isPhysicalDevice ?? false;
    }

    return true;
  }

  static String _fmt2(int n) => n.toString().padLeft(2, '0');

  /// Converts DateTime into a readable timestamp.
  static String formatTimestamp(DateTime dt) {
    final d = '${dt.year}-${_fmt2(dt.month)}-${_fmt2(dt.day)}';
    final t = '${_fmt2(dt.hour)}:${_fmt2(dt.minute)}';
    return '$d $t';
  }

  /// Creates a Google Maps link from coordinates.
  static String mapsLink(double lat, double lng) {
    final latStr = lat.toStringAsFixed(6);
    final lngStr = lng.toStringAsFixed(6);
    return 'https://www.google.com/maps/search/?api=1&query=$latStr,$lngStr';
  }

  /// Ensures latitude and longitude values are valid.
  static bool _validLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Builds the SOS message with all relevant information
  /// including user name, emergency type, time, battery
  /// and location if available.
  static Future<SosPayload> buildPayload({
    required String userName,
    required EmergencyType type,
    bool tryLocation = true,
    String? customNote,
  }) async {

    final now = DateTime.now();

    int? batteryPercent;
    try {
      batteryPercent = await _battery.batteryLevel;
    } catch (_) {}

    LocationData? loc;
    String? link;

    if (tryLocation) {
      try {
        loc = await _loc.getBestEffort(
          oneShotTimeout: const Duration(seconds: 3),
          streamTimeout: const Duration(seconds: 3),
        );

        final lat = loc?.latitude;
        final lng = loc?.longitude;

        if (lat != null && lng != null && _validLatLng(lat, lng)) {
          link = mapsLink(lat, lng);
        }
      } catch (_) {}
    }

    final buffer = StringBuffer()
      ..writeln('SOS! I need help.')
      ..writeln('Emergency Type: ${type.label}')
      ..writeln('Name: $userName');

    final note = (customNote ?? '').trim();
    if (note.isNotEmpty) buffer.writeln('Note: $note');

    buffer
      ..writeln('Please contact me urgently.')
      ..writeln()
      ..writeln('Time: ${formatTimestamp(now)}')
      ..writeln(
          'Battery: ${batteryPercent == null ? 'N/A' : '$batteryPercent%'}');

    if (link != null) {
      buffer..writeln()..writeln('My location: $link');
    }

    return SosPayload(
      message: buffer.toString().trim(),
      mapsLink: link,
      batteryPercent: batteryPercent,
      timestamp: now,
      location: loc,
      type: type,
    );
  }

  /// Fetches only the location link separately if needed.
  static Future<String?> fetchMapsLink() async {
    try {
      final loc = await _loc
          .getBestEffort(
            oneShotTimeout: const Duration(seconds: 3),
            streamTimeout: const Duration(seconds: 3),
          )
          .timeout(const Duration(seconds: 6));

      final lat = loc?.latitude;
      final lng = loc?.longitude;

      if (lat == null || lng == null) return null;
      if (!_validLatLng(lat, lng)) return null;

      return mapsLink(lat, lng);
    } catch (_) {
      return null;
    }
  }

  /// Opens the SMS composer with the SOS message.
  static Future<void> openSmsComposer({
    required String phone,
    required String message,
  }) async {

    final clean = sanitizePhone(phone);
    if (clean.isEmpty) throw Exception('Invalid emergency number.');

    final physical = await isPhysicalDevice();
    if (!physical) {
      throw Exception('SMS not supported on emulator/simulator.');
    }

    final uri = Uri.parse('sms:$clean?body=${Uri.encodeComponent(message)}');
    await _launchExternal(uri);
  }

  /// Android-only direct SMS sending using native code.
  static Future<void> sendDirectSmsAndroid({
    required String phone,
    required String message,
  }) async {

    if (!Platform.isAndroid) {
      throw Exception('Direct SMS is Android-only.');
    }

    final clean = sanitizePhone(phone);
    if (clean.isEmpty) throw Exception('Invalid emergency number.');

    final perm = await Permission.sms.request();
    if (!perm.isGranted) {
      throw Exception('SMS permission denied.');
    }

    await _smsChannel.invokeMethod('sendSms', {
      'phone': clean,
      'message': message,
    });
  }

  /// Makes an emergency call.
  static Future<void> callEmergency(String phone) async {

    final clean = sanitizePhone(phone);
    if (clean.isEmpty) throw Exception('Invalid emergency number.');

    final physical = await isPhysicalDevice();
    if (!physical) {
      throw Exception('Calls not supported on emulator.');
    }

    await _launchExternal(Uri.parse('tel:$clean'));
  }

  /// Opens the generated Google Maps link.
  static Future<void> openMapsLink(String link) async {
    await _launchExternal(Uri.parse(link));
  }

  /// Opens WhatsApp with the SOS message.
  static Future<void> openWhatsApp({
    required String phone,
    required String message,
  }) async {

    final digits = whatsappPhone(phone);
    if (digits.isEmpty) throw Exception('Invalid WhatsApp number.');

    final url = 'https://wa.me/$digits?text=${Uri.encodeComponent(message)}';

    await _launchExternal(Uri.parse(url));
  }

  /// Helper method used to open external apps.
  static Future<void> _launchExternal(Uri uri) async {

    final ok = await canLaunchUrl(uri);
    if (!ok) throw Exception('Cannot open: $uri');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}