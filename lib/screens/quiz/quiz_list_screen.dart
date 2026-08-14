// lib/screens/quiz/quiz_list_screen.dart


import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:disaster_app_ui/config/colors.dart';

import 'categories_detail_screen.dart';
import 'leaderboard_screen.dart';

/// Quiz home screen showing overall progress and quiz categories.
/// Users can view their progress and select a category to start the quiz.

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return AppScaffold(
      title: "Gamified Quiz",
      subtitle: "Earn XP and unlock kit items",
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),

      // Leaderboard button in app bar
      appBarActions: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.border),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.emoji_events_rounded,
              color: AppColor.primary,
              size: 26,
            ),
            onPressed: () => Get.to(() => const LeaderboardScreen()),
          ),
        ),
      ],

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          /// User overall quiz progress
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('questions')
                .snapshots(),
            builder: (_, questionSnap) {
              if (!questionSnap.hasData) return const SizedBox();

              final totalQuestions = questionSnap.data!.docs.length;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('quizAttempts')
                    .where('isCorrect', isEqualTo: true)
                    .snapshots(),
                builder: (_, attemptSnap) {
                  if (!attemptSnap.hasData) return const SizedBox();

                  final correctAnswered = attemptSnap.data!.docs.length;

                  final safeAnswered = correctAnswered > totalQuestions
                      ? totalQuestions
                      : correctAnswered;

                  final progress =
                      totalQuestions == 0 ? 0.0 : safeAnswered / totalQuestions;

                  return _ProgressCard(
                    safeAnswered: safeAnswered,
                    totalQuestions: totalQuestions,
                    progress: progress.clamp(0, 1),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 22),

          /// Categories header with total count
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('questions')
                .snapshots(),
            builder: (_, snap) {
              final count = snap.data?.docs
                      .map((e) => e['category']?.toString())
                      .whereType<String>()
                      .toSet()
                      .length ??
                  0;

              return Row(
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColor.text,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: AppColor.primary.withOpacity(0.22)),
                    ),
                    child: Text(
                      "$count",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColor.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          /// Category list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('questions')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  );
                }

                final categories = snap.data!.docs
                    .map((e) => e['category']?.toString())
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();

                if (categories.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColor.cardFill,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColor.border),
                      ),
                      child: const Text(
                        "No categories found yet.",
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 140),
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final category = categories[i];

                    return _CategoryTile(
                      title: category,
                      icon: _iconForCategory(category),
                      onTap: () => Get.to(
                        () => CategoriesDetailScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Selects a suitable icon based on category name
  IconData _iconForCategory(String c) {
    final t = c.toLowerCase();

    if (t.contains("earth")) return Icons.public_rounded;
    if (t.contains("flood")) return Icons.water_rounded;
    if (t.contains("fire")) return Icons.local_fire_department_rounded;
    if (t.contains("first")) return Icons.health_and_safety_rounded;
    if (t.contains("storm") || t.contains("weather"))
      return Icons.cloud_rounded;

    return Icons.quiz_rounded;
  }
}

/// Progress card displaying total correct answers
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.safeAnswered,
    required this.totalQuestions,
    required this.progress,
  });

  final int safeAnswered;
  final int totalQuestions;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.26),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "TOTAL PROGRESS",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.88),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: const Text(
                  "XP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "$safeAnswered / $totalQuestions",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.22),
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            totalQuestions == 0
                ? "Add questions to start progress."
                : "Keep going — unlock more kit items!",
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile used to display each quiz category
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColor.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.primary.withOpacity(0.22)),
              ),
              child: Icon(icon, color: AppColor.primary),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColor.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColor.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}