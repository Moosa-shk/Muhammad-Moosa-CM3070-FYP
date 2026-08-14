// lib/services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// This service handles all local notifications in the app.
/// It initializes the notification plugin, requests permissions,
/// and provides helper functions to show different notification types.
class LocalNotificationService {

  /// Main plugin used for showing local notifications
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Notification channel details (mainly used on Android)
  static const String _channelId = 'disasteraid_alerts';
  static const String _channelName = 'DisasterAid Alerts';
  static const String _channelDesc = 'Important account and safety alerts';

  /// Initializes the notification system when the app starts
  static Future<void> init() async {

    // Android initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Combine platform settings
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize notification plugin
    await _plugin.initialize(initSettings);

    // Create Android notification channel
    await _ensureAndroidChannel();

    // Request notification permissions
    await _requestPermissions();
  }

  /// Creates the Android notification channel if it doesn't exist
  static Future<void> _ensureAndroidChannel() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Requests notification permissions for both Android and iOS
  static Future<void> _requestPermissions() async {

    // iOS permission request
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 iOS Notification Permission Status: $granted');
    }

    // Android permission request (Android 13+)
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null && Platform.isAndroid) {
      final granted = await androidPlugin.requestNotificationsPermission();

      print('🔔 Android Notification Permission Status: $granted');
    }
  }

  /// Generates a unique notification ID
  static int _id() => DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

  /// Creates notification configuration (priority, importance etc.)
  static NotificationDetails _details({bool urgent = false}) {

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: urgent ? Importance.max : Importance.high,
      priority: urgent ? Priority.high : Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // -------------------------------
  // Auth notifications
  // -------------------------------

  /// Shows a welcome notification after signup
  static Future<void> showSignupWelcome(String name) async {
    await _plugin.show(
      _id(),
      'Welcome to DisasterAid_FYP 👋',
      'Stay safe, $name',
      _details(),
    );
  }

  /// Shows a welcome back notification after login
  static Future<void> showLoginWelcome(String name) async {
    await _plugin.show(
      _id(),
      'Welcome back 👋',
      'Good to see you again, $name',
      _details(),
    );
  }

  // -------------------------------
  // SOS notifications
  // -------------------------------

  /// Notification when an SOS message is prepared
  static Future<void> sosPrepared({
    required String channel,
    required String emergency,
  }) async {
    await _plugin.show(
      _id(),
      'SOS Ready',
      '$channel prepared for $emergency',
      _details(urgent: true),
    );
  }

  /// Notification when SOS action opens another app
  static Future<void> sosOpened({
    required String channel,
  }) async {
    await _plugin.show(
      _id(),
      '$channel Opened',
      channel.toLowerCase().contains('sms')
          ? 'Tap Send in Messages to deliver SOS'
          : 'Complete action in opened app',
      _details(urgent: true),
    );
  }

  /// Notification when SOS is sent directly from Android
  static Future<void> sosSentAndroidDirect() async {
    await _plugin.show(
      _id(),
      'SOS Sent ✅',
      'Direct SMS sent from your phone',
      _details(urgent: true),
    );
  }

  /// Notification shown if SOS sending fails
  static Future<void> sosFailed(String reason) async {
    await _plugin.show(
      _id(),
      'SOS Failed',
      reason,
      _details(urgent: true),
    );
  }
}