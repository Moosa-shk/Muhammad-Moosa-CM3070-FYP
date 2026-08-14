import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This service manages the progress of quiz attempts.
/// It stores each attempt and recalculates the user's XP.
/// The logic ensures that XP is only rewarded once per question
/// and the total XP cannot exceed the maximum available XP.
class QuizProgressService {

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Saves a quiz attempt and updates the user's total XP.
  /// The method returns TRUE only if the question was answered
  /// correctly for the first time.
  static Future<bool> saveAttempt({
    required String questionId,
    required String category,
    required bool isCorrect,
    required int xp,
    required String difficulty,
    required String questionText,
  }) async {

    final uid = _auth.currentUser!.uid;

    /// Reference to the user document
    final userRef = _firestore.collection('users').doc(uid);

    /// Each question attempt is stored using the question ID
    final attemptRef = userRef.collection('quizAttempts').doc(questionId);

    /// A Firestore transaction is used to ensure that
    /// the data remains consistent even if multiple writes happen.
    return _firestore.runTransaction<bool>((transaction) async {

      // --------------------------------------------------
      // 1️⃣ Check if the question was already answered before
      // --------------------------------------------------
      final attemptSnap = await transaction.get(attemptRef);

      final wasCorrectBefore =
          attemptSnap.exists && attemptSnap['isCorrect'] == true;

      // --------------------------------------------------
      // 2️⃣ Save or update the quiz attempt
      // --------------------------------------------------
      /// The attempt is stored again to keep the latest answer,
      /// but XP will only be awarded once.
      transaction.set(attemptRef, {
        'questionId': questionId,
        'category': category,
        'question': questionText,
        'difficulty': difficulty,
        'isCorrect': isCorrect,
        'xp': isCorrect ? xp : 0,
        'answeredAt': FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------
      // 3️⃣ Recalculate total XP from all correct answers
      // --------------------------------------------------
      /// All correct attempts are retrieved and summed
      /// to determine the user's total XP.
      final attemptsQuery = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quizAttempts')
          .where('isCorrect', isEqualTo: true)
          .get();

      int recalculatedXP = 0;

      for (final doc in attemptsQuery.docs) {
        recalculatedXP += (doc['xp'] ?? 0) as int;
      }

      // --------------------------------------------------
      // 4️⃣ Ensure XP does not exceed the maximum possible XP
      // --------------------------------------------------
      /// This prevents users from gaining more XP
      /// than the total XP available across all questions.
      final questionsSnap =
          await _firestore.collectionGroup('questions').get();

      int maxPossibleXP = 0;

      for (final q in questionsSnap.docs) {
        final raw = q['xp'];
        if (raw is int) {
          maxPossibleXP += raw;
        }
      }

      if (recalculatedXP > maxPossibleXP) {
        recalculatedXP = maxPossibleXP;
      }

      // --------------------------------------------------
      // 5️⃣ Update the user's XP in the database
      // --------------------------------------------------
      transaction.set(
        userRef,
        {
          'totalXP': recalculatedXP,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // --------------------------------------------------
      // 6️⃣ Return reward status
      // --------------------------------------------------
      /// XP is awarded only if the user answered correctly
      /// and had not answered the question correctly before.
      return isCorrect && !wasCorrectBefore;
    });
  }
}