// lib/screens/quiz/categories_detail_screen.dart
// This screen shows the progress of a quiz category and unlocks safety kit items
// based on the number of correct answers the user gives.

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:disaster_app_ui/config/colors.dart';
import 'quiz_screen.dart';

class CategoriesDetailScreen extends StatelessWidget {
  final String category;

  const CategoriesDetailScreen({
    super.key,
    required this.category,
  });

  // Images representing emergency safety kit items
  static const List<String> kitImages = [
    'assets/images/kit_first_aid.png',
    'assets/images/kit_flashlight.png',
    'assets/images/kit_water.png',
    'assets/images/kit_radio.png',
    'assets/images/kit_food.png',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return AppScaffold(
      title: category.toUpperCase(),
      subtitle: "Unlock safety kit items by answering correctly",
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      // Fetch all questions belonging to the selected category
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('questions')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (_, questionSnap) {
          if (!questionSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            );
          }

          final totalQuestions = questionSnap.data!.docs.length;

          // Fetch user's correct attempts for this category
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('quizAttempts')
                .where('category', isEqualTo: category)
                .where('isCorrect', isEqualTo: true)
                .snapshots(),
            builder: (_, attemptSnap) {
              final attempts = attemptSnap.data?.docs ?? [];

              final completedQuestions =
                  attempts.map((d) => d['questionId']).toSet().length;

              final safeCompleted = completedQuestions.clamp(0, totalQuestions);
              final unlockedKits = safeCompleted.clamp(0, kitImages.length);
              final allKitsUnlocked = unlockedKits == kitImages.length;

              final progress =
                  totalQuestions == 0 ? 0.0 : safeCompleted / totalQuestions;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Progress card showing quiz completion and unlocked items
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 650),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: AppColor.cardFill,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColor.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.shadow,
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColor.primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.primary.withOpacity(0.20),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: AppColor.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Safety Kit Progress",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: AppColor.text,
                                  ),
                                ),
                              ),
                              _miniPill(
                                allKitsUnlocked ? "Completed" : "In progress",
                                color: allKitsUnlocked
                                    ? AppColor.safeGreen
                                    : AppColor.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.55),
                              color: AppColor.primary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Text(
                                "$safeCompleted / $totalQuestions questions",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "$unlockedKits / ${kitImages.length} items unlocked",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Unlocked Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColor.text,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid showing unlocked safety kit items
                  Expanded(
                    child: unlockedKits == 0
                        ? _emptyState(totalQuestions: totalQuestions)
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 140),
                            itemCount: unlockedKits,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (_, i) {
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 380 + i * 90),
                                tween: Tween(begin: 0, end: 1),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, child) => Opacity(
                                  opacity: v,
                                  child: Transform.scale(
                                    scale: 0.95 + (0.05 * v),
                                    child: child,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.cardFill,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColor.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.shadow,
                                        blurRadius: 16,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      kitImages[i],
                                      height: 74,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Button to start the quiz
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: allKitsUnlocked
                              ? Colors.grey.shade400
                              : AppColor.primary,
                          elevation: allKitsUnlocked ? 0 : 10,
                          shadowColor: AppColor.primary.withOpacity(0.30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: allKitsUnlocked || totalQuestions == 0
                            ? null
                            : () async {
                                final snap = await FirebaseFirestore.instance
                                    .collectionGroup('questions')
                                    .where('category', isEqualTo: category)
                                    .get();

                                final questions = snap.docs
                                    .map((d) => {'id': d.id, ...d.data()})
                                    .toList();

                                Get.to(() => QuizScreen(
                                      category: category,
                                      questions: questions,
                                    ));
                              },
                        child: Text(
                          allKitsUnlocked ? "CATEGORY COMPLETED" : "START QUIZ",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: allKitsUnlocked
                                ? Colors.white.withOpacity(0.92)
                                : Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Small status pill used inside the progress card
  static Widget _miniPill(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }

  // UI shown when no items are unlocked yet
  Widget _emptyState({required int totalQuestions}) {
    final subtitle = totalQuestions == 0
        ? "No questions found for this category."
        : "Answer questions to unlock safety kit items.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No items unlocked yet",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColor.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}