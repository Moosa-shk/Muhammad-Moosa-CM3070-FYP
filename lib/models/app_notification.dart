// lib/models/app_notification.dart

import 'package:flutter/material.dart';

/// Types of notifications used inside the application.
enum AppNotifType { alert, sos, nearby, system }

/// Model representing a notification shown in the app.
class AppNotificationModel {
  final String id;
  final AppNotifType type;
  final String title;
  final String message;
  final DateTime createdAt;

  // UI representation
  final IconData icon;
  final int iconColor;

  // Optional metadata
  final String? severity;
  final String? source;
  final String? link;

  AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
    this.severity,
    this.source,
    this.link,
  });

  /// Converts the model into a Map for storage (Hive / local persistence).
  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type.name,
        "title": title,
        "message": message,
        "createdAt": createdAt.millisecondsSinceEpoch,
        "iconCode": icon.codePoint,
        "iconFontFamily": icon.fontFamily,
        "iconFontPackage": icon.fontPackage,
        "iconColor": iconColor,
        "severity": severity,
        "source": source,
        "link": link,
      };

  /// Creates a notification model from stored map data.
  static AppNotificationModel fromMap(Map data) {
    final String typeName = (data["type"] ?? "system").toString();

    final AppNotifType t = AppNotifType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => AppNotifType.system,
    );

    return AppNotificationModel(
      id: (data["id"] ?? "").toString(),
      type: t,
      title: (data["title"] ?? "").toString(),
      message: (data["message"] ?? "").toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data["createdAt"] as int?) ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      icon: IconData(
        (data["iconCode"] as int?) ?? Icons.notifications.codePoint,
        fontFamily: (data["iconFontFamily"] as String?) ?? 'MaterialIcons',
        fontPackage: data["iconFontPackage"] as String?,
      ),
      iconColor: (data["iconColor"] as int?) ?? Colors.grey.value,
      severity: data["severity"] as String?,
      source: data["source"] as String?,
      link: data["link"] as String?,
    );
  }
}