// lib/services/local_notification_center.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../config/colors.dart';
import '../models/app_notification.dart';

/// This controller manages local notifications inside the app.
/// Notifications are stored locally using Hive so they remain
/// available even if the app restarts.
class LocalNotificationCenter extends GetxController {

  /// Quick access instance using GetX
  static LocalNotificationCenter get to => Get.find<LocalNotificationCenter>();

  /// Hive storage configuration
  static const String _boxName = "notifBox";
  static const String _keyList = "items";

  /// Observable list used by the UI
  final items = <AppNotificationModel>[].obs;

  /// Hive box reference
  late Box _box;

  /// Initializes the notification system
  /// Loads existing notifications from Hive
  Future<void> init() async {
    _box = Hive.box(_boxName);
    _loadFromHive();

    // Optional: add demo notifications if list is empty
    if (items.isEmpty) {
      seedDemo(); // remove if you don't want demo data
    }
  }

  /// Loads notifications from Hive storage
  void _loadFromHive() {
    final raw = (_box.get(_keyList) as List?) ?? [];

    final list = raw
        .whereType<Map>()
        .map((m) => AppNotificationModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();

    // Sort notifications so newest ones appear first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    items.assignAll(list);
  }

  /// Saves the current notification list back to Hive
  Future<void> _saveToHive() async {
    final raw = items.map((e) => e.toMap()).toList();
    await _box.put(_keyList, raw);
  }

  /// Clears all notifications
  Future<void> clearAll() async {
    items.clear();
    await _saveToHive();
  }

  /// Adds a new notification to the list
  Future<void> add(AppNotificationModel n) async {

    // Insert at the top so newest notification appears first
    items.insert(0, n);

    // Limit list size to keep storage light
    if (items.length > 80) {
      items.removeRange(80, items.length);
    }

    await _saveToHive();
  }

  // ================== QUICK LOG HELPERS ==================
  // These helper functions make it easy to create
  // different types of notifications in the app.

  /// Logs a disaster alert notification
  Future<void> logAlert({
    required String title,
    required String message,
    String? severity,
    String? source,
    String? link,
  }) {
    return add(
      AppNotificationModel(
        id: "alert-${DateTime.now().microsecondsSinceEpoch}",
        type: AppNotifType.alert,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        icon: Icons.warning_rounded,
        iconColor: AppColor.danger.value,
        severity: severity,
        source: source,
        link: link,
      ),
    );
  }

  /// Logs an SOS related notification
  Future<void> logSOS({
    required String title,
    required String message,
    String? link,
  }) {
    return add(
      AppNotificationModel(
        id: "sos-${DateTime.now().microsecondsSinceEpoch}",
        type: AppNotifType.sos,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        icon: Icons.sos_rounded,
        iconColor: AppColor.primary.value,
        severity: "High",
        source: "SOS",
        link: link,
      ),
    );
  }

  /// Logs nearby location related notifications
  /// (example: hospital, shelter, police etc.)
  Future<void> logNearby({
    required String title,
    required String message,
    String? link,
  }) {
    return add(
      AppNotificationModel(
        id: "nearby-${DateTime.now().microsecondsSinceEpoch}",
        type: AppNotifType.nearby,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        icon: Icons.place_rounded,
        iconColor: AppColor.safeGreen.value,
        source: "Nearby",
        link: link,
      ),
    );
  }

  /// Logs simple system notifications
  Future<void> logSystem({
    required String title,
    required String message,
  }) {
    return add(
      AppNotificationModel(
        id: "sys-${DateTime.now().microsecondsSinceEpoch}",
        type: AppNotifType.system,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        icon: Icons.info_rounded,
        iconColor: AppColor.secondary.value,
        source: "System",
      ),
    );
  }

  /// Adds some example notifications for testing
  /// (can be removed in production)
  void seedDemo() {
    logAlert(
      title: "Earthquake Alert",
      message: "Mild tremor detected in Pakistan region (sample).",
      severity: "Moderate",
      source: "USGS",
    );

    logSOS(
      title: "SOS Prepared",
      message: "Your emergency message is ready to send (sample).",
    );

    logNearby(
      title: "Nearest Hospital",
      message: "Tap to open Google Maps (sample).",
      link: "https://maps.google.com/?q=31.418000,73.079100",
    );
  }
}