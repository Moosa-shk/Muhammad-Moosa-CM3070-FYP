import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/first_aid_model.dart';
import '../models/contact_model.dart';
import '../models/safety_tip_model.dart';
import '../models/quiz_model.dart';

/// This service is used to sync data from Firestore to local Hive storage.
/// The purpose is to keep important data available offline inside the app.
/// Whenever Firestore updates, the local cache is refreshed automatically.
class FirestoreSyncService {

  // Stream subscriptions used to listen to Firestore updates
  static StreamSubscription? _firstAidSub;
  static StreamSubscription? _contactSub;
  static StreamSubscription? _safetySub;
  static StreamSubscription? _quizSub;

  /// Starts the live synchronization process.
  /// Data is downloaded from Firestore and stored locally in Hive.
  static Future<void> startLiveSync() async {

    // Stop any existing listeners before starting new ones
    await stopLiveSync();

    // Open Hive boxes used for local caching
    final firstAidBox = Hive.box<FirstAidModel>('firstAidBox');
    final contactBox = Hive.box<ContactModel>('contactBox');
    final tipsBox = Hive.box<SafetyTipModel>('tipsBox');
    final quizBox = Hive.box<QuizModel>('quizBox');

    print('🚀 FirestoreSyncService: Starting live sync...');

    // ================= FIRST AID =================
    // Listen to Firestore first aid collection and update local cache
    _firstAidSub = FirebaseFirestore.instance
        .collection('firstAid')
        .snapshots()
        .listen((snap) async {

      // Clear old cached data
      await firstAidBox.clear();

      // Save new data locally
      for (final d in snap.docs) {
        firstAidBox.add(FirstAidModel.fromMap(d.data()));
      }

      print('✅ [firstAid] synced: ${firstAidBox.length}');
    });

    // ================= CONTACTS =================
    // Sync emergency contact information
    _contactSub = FirebaseFirestore.instance
        .collection('contacts')
        .snapshots()
        .listen((snap) async {

      await contactBox.clear();

      for (final d in snap.docs) {
        contactBox.add(ContactModel.fromMap(d.data()));
      }

      print('✅ [contacts] synced: ${contactBox.length}');
    });

    // ================= SAFETY TIPS =================
    // Sync disaster safety tips used in the app
    _safetySub = FirebaseFirestore.instance
        .collection('safetyTips')
        .snapshots()
        .listen((snap) async {

      await tipsBox.clear();

      for (final d in snap.docs) {
        tipsBox.add(SafetyTipModel.fromMap(d.data()));
      }

      print('✅ [safetyTips] synced: ${tipsBox.length}');
    });

    // ================= QUIZ QUESTIONS =================
    // Quiz questions are stored in nested collections,
    // so a collectionGroup query is used to fetch them.
    _quizSub = FirebaseFirestore.instance
        .collectionGroup('questions')
        .snapshots()
        .listen((snap) async {

      await quizBox.clear();

      for (final doc in snap.docs) {
        final data = doc.data();

        // Convert options safely into a string list
        final options = (data['options'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        int correctIndex = -1;

        // Determine which option is correct
        if (data.containsKey('correctIndex')) {
          correctIndex = data['correctIndex'] is int
              ? data['correctIndex']
              : int.tryParse('${data['correctIndex']}') ?? -1;

        } else if (data.containsKey('answer')) {

          // If answer text is provided instead of index
          final answer = data['answer']?.toString() ?? '';
          correctIndex = options.indexOf(answer);
        }

        // Save quiz question locally
        quizBox.add(
          QuizModel(
            id: doc.id,
            question: data['question']?.toString() ?? '',
            options: options,
            correctIndex: correctIndex,
            category: data['category']?.toString() ?? 'General',
            difficulty: data['difficulty']?.toString() ?? 'Basic',
            xp: data['xp'] is int
                ? data['xp']
                : int.tryParse('${data['xp']}') ?? 10,
            kitItemId: data['kitItemId']?.toString() ?? '',
          ),
        );
      }

      print('✅ [quiz questions cached] ${quizBox.length}');
    });
  }

  /// Stops all Firestore listeners.
  /// This is useful when restarting sync or closing the service.
  static Future<void> stopLiveSync() async {

    await _firstAidSub?.cancel();
    await _contactSub?.cancel();
    await _safetySub?.cancel();
    await _quizSub?.cancel();

    _firstAidSub = null;
    _contactSub = null;
    _safetySub = null;
    _quizSub = null;

    print('🛑 FirestoreSyncService: All listeners stopped');
  }
}