// HAMZA KHAWAR FYP ///

// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

import 'services/local_notification_center.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/firestore_sync.dart';

import 'screens/auth/auth_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/splash_screen.dart';

import 'screens/quiz/quiz_list_screen.dart';
import 'screens/quiz/quiz_admin_upload_screen.dart';

import 'models/first_aid_model.dart';
import 'models/contact_model.dart';
import 'models/safety_tip_model.dart';
import 'models/quiz_model.dart';

/// Initializes all core services required before launching the application.
/// This includes Firebase connection, local storage setup, notification services,
/// connectivity monitoring, and background Firestore synchronization.
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase using platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Initialize local notification system used for alerts and reminders
  await LocalNotificationService.init();

  /// Initialize Hive for offline local storage
  await Hive.initFlutter();

  /// Register Hive adapters for storing custom data models
  Hive.registerAdapter(FirstAidModelAdapter());
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(SafetyTipModelAdapter());
  Hive.registerAdapter(QuizModelAdapter());

  /// Open Hive boxes used across the application
  await Hive.openBox<FirstAidModel>('firstAidBox');
  await Hive.openBox<ContactModel>('contactBox');
  await Hive.openBox<SafetyTipModel>('tipsBox');

  /// Quiz data is refreshed each launch to ensure updated content
  if (await Hive.boxExists('quizBox')) {
    await Hive.deleteBoxFromDisk('quizBox');
  }
  await Hive.openBox<QuizModel>('quizBox');

  /// Emergency kit checklist storage
  await Hive.openBox<String>('kitBox');

  /// Local storage for in-app notifications
  await Hive.openBox('notifBox');

  /// Start monitoring internet connectivity
  ConnectivityService.startMonitoring();

  /// Start background synchronization between Firestore and local storage
  await FirestoreSyncService.startLiveSync();

  /// Register global authentication controller using GetX
  Get.put(AuthController(), permanent: true);

  /// Initialize local notification center for in-app notification feed
  Get.put(LocalNotificationCenter(), permanent: true);
  await LocalNotificationCenter.to.init();
}

void main() async {
  await _initializeApp();
  runApp(const DisasterAidApp());
}

/// Root widget of the DisasterAid application.
/// Defines global theme, routing structure, and initial screen.
class DisasterAidApp extends StatelessWidget {
  const DisasterAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DisasterAid UI',
      debugShowCheckedModeBanner: false,

      /// Global application theme
      theme: AppTheme.light(),

      /// EasyLoading builder for global loading indicators
      builder: EasyLoading.init(),

      /// First screen shown when the application launches
      home: const SplashScreen(),

      /// Named routes used throughout the application
      routes: {
        '/auth': (_) => const AuthGate(),
        '/quiz-list': (_) => const QuizListScreen(),
        '/admin-upload-quiz': (_) => const QuizAdminUploadScreen(),
      },
    );
  }
}