// lib/services/notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // IMPORTANT:
  // Internal channel ID preserved to avoid breaking existing behavior.
  static const String _channelId = 'disasteraid_alerts';

  // Visible channel name updated only.
  static const String _channelName = 'RescueAid Alerts';

  static const String _channelDesc =
      'Important account and safety alerts';

  // ===============================================================
  // INITIALIZATION
  // ===============================================================

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
    );

    await _ensureAndroidChannel();
    await _requestPermissions();
  }

  // ===============================================================
  // ANDROID CHANNEL
  // EXISTING BEHAVIOUR PRESERVED
  // ===============================================================

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

    await androidPlugin.createNotificationChannel(
      channel,
    );
  }

  // ===============================================================
  // PERMISSIONS
  // ===============================================================

  static Future<void> _requestPermissions() async {
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'iOS Notification Permission Status: $granted',
      );
    }

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null && Platform.isAndroid) {
      final granted =
          await androidPlugin.requestNotificationsPermission();

      debugPrint(
        'Android Notification Permission Status: $granted',
      );
    }
  }

  // ===============================================================
  // UNIQUE ID
  // ===============================================================

  static int _id() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .remainder(1 << 31);
  }

  // ===============================================================
  // NORMAL NOTIFICATION
  // Login / Signup
  // ===============================================================

  static NotificationDetails _normalDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.active,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // ===============================================================
  // EMERGENCY NOTIFICATION
  // ===============================================================

  static NotificationDetails _emergencyDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // ===============================================================
  // SIGNUP
  // ===============================================================

  static Future<void> showSignupWelcome(
    String name,
  ) async {
    final cleanName = name.trim();

    await _plugin.show(
      _id(),
      'You’re all set',
      cleanName.isEmpty
          ? 'Your RescueAid account is ready.'
          : 'Welcome, $cleanName. Your account is ready.',
      _normalDetails(),
    );
  }

  // ===============================================================
  // LOGIN
  // ===============================================================

  static Future<void> showLoginWelcome(
    String name,
  ) async {
    final cleanName = name.trim();

    await _plugin.show(
      _id(),
      'Welcome back',
      cleanName.isEmpty
          ? 'You’re signed in to RescueAid.'
          : 'Signed in as $cleanName.',
      _normalDetails(),
    );
  }

  // ===============================================================
  // SOS PREPARED
  // ===============================================================

  static Future<void> sosPrepared({
    required String channel,
    required String emergency,
  }) async {
    await _plugin.show(
      _id(),
      'SOS ready to send',
      '$channel is prepared for $emergency.',
      _emergencyDetails(),
    );
  }

  // ===============================================================
  // SOS OPENED
  // ===============================================================

  static Future<void> sosOpened({
    required String channel,
  }) async {
    final lowerChannel =
        channel.trim().toLowerCase();

    final isSms =
        lowerChannel.contains('sms');

    final isWhatsApp =
        lowerChannel.contains('whatsapp');

    String title;
    String message;

    if (isSms) {
      title = 'SOS message opened';
      message =
          'Review the message, then tap Send.';
    } else if (isWhatsApp) {
      title = 'WhatsApp opened';
      message =
          'Review your SOS message and send it when ready.';
    } else {
      title = '$channel opened';
      message =
          'Complete the emergency action in the opened app.';
    }

    await _plugin.show(
      _id(),
      title,
      message,
      _emergencyDetails(),
    );
  }

  // ===============================================================
  // SOS SENT
  // ===============================================================

  static Future<void> sosSentAndroidDirect() async {
    await _plugin.show(
      _id(),
      'SOS sent',
      'Your emergency message was sent successfully.',
      _emergencyDetails(),
    );
  }

  // ===============================================================
  // SOS FAILED
  // ===============================================================

  static Future<void> sosFailed(
    String reason,
  ) async {
    final cleanReason =
        reason.trim();

    await _plugin.show(
      _id(),
      'Couldn’t send SOS',
      cleanReason.isEmpty
          ? 'The emergency action could not be completed.'
          : cleanReason,
      _emergencyDetails(),
    );
  }
}