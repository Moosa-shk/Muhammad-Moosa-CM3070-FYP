// lib/screens/quiz/quiz_list_screen.dart

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/widgets/text_widget.dart';

import 'categories_detail_screen.dart';
import 'leaderboard_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return AppScaffold(
      title: null,
      subtitle: null,
      scroll: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // =======================================================
          // CUSTOM QUIZ HEADER
          // =======================================================

          _pageHeader(),

          const SizedBox(height: 22),

          // =======================================================
          // OVERALL QUIZ PROGRESS
          // =======================================================

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('questions')
                .snapshots(),
            builder: (_, questionSnap) {
              if (!questionSnap.hasData) {
                return _progressLoading();
              }

              final totalQuestions =
                  questionSnap.data!.docs.length;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('quizAttempts')
                    .where(
                      'isCorrect',
                      isEqualTo: true,
                    )
                    .snapshots(),
                builder: (_, attemptSnap) {
                  if (!attemptSnap.hasData) {
                    return _progressLoading();
                  }

                  final correctAnswered =
                      attemptSnap.data!.docs.length;

                  final safeAnswered =
                      correctAnswered >
                              totalQuestions
                          ? totalQuestions
                          : correctAnswered;

                  final progress =
                      totalQuestions == 0
                          ? 0.0
                          : safeAnswered /
                              totalQuestions;

                  return _ProgressDashboard(
                    safeAnswered:
                        safeAnswered,
                    totalQuestions:
                        totalQuestions,
                    progress:
                        progress.clamp(
                      0,
                      1,
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // =======================================================
          // CATEGORY SUMMARY HEADER
          // =======================================================

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('questions')
                .snapshots(),
            builder: (_, snap) {
              final count = snap.data?.docs
                      .map(
                        (e) => e['category']
                            ?.toString(),
                      )
                      .whereType<String>()
                      .toSet()
                      .length ??
                  0;

              return _categoryHeading(
                count,
              );
            },
          ),

          const SizedBox(height: 14),

          // =======================================================
          // CATEGORY BOARD
          // =======================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('questions')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppColor.primary,
                    ),
                  );
                }

                final categories = snap
                    .data!.docs
                    .map(
                      (e) => e['category']
                          ?.toString(),
                    )
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();

                if (categories.isEmpty) {
                  return _emptyCategories();
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets.only(
                    bottom: 140,
                  ),

                  physics:
                      const BouncingScrollPhysics(),

                  itemCount:
                      categories.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),

                  itemBuilder: (_, i) {
                    final category =
                        categories[i];

                    return _CategoryCard(
                      title: category,
                      icon:
                          _iconForCategory(
                        category,
                      ),
                      color:
                          _colorForCategory(
                        category,
                      ),
                      onTap: () {
                        Get.to(
                          () =>
                              CategoriesDetailScreen(
                            category:
                                category,
                          ),
                        );
                      },
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

  // ===============================================================
  // PAGE HEADER
  // ===============================================================

  Widget _pageHeader() {
    return SizedBox(
      width: double.infinity,

      child: Stack(
        alignment: Alignment.center,
        children: [
          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 56,
            ),

            child: Column(
              children: [
                TextWidget(
                  "Gamified Quiz",
                  size: 27,
                  weight:
                      FontWeight.w800,
                  color:
                      AppColor.text,
                  align:
                      TextAlign.center,
                ),

                SizedBox(
                  height: 5,
                ),

                TextWidget(
                  "Earn XP and unlock kit items",
                  size: 12.5,
                  color:
                      AppColor.textMuted,
                  align:
                      TextAlign.center,
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,

            child: Material(
              color:
                  Colors.transparent,

              child: InkWell(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),

                onTap: () {
                  Get.to(
                    () =>
                        const LeaderboardScreen(),
                  );
                },

                child: Container(
                  width: 46,
                  height: 46,

                  decoration:
                      BoxDecoration(
                    color:
                        AppColor.surface,

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    border:
                        Border.all(
                      color:
                          AppColor.border,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColor.shadow,
                        blurRadius:
                            12,
                        offset:
                            const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons
                        .leaderboard_rounded,
                    color:
                        AppColor.primary,
                    size:
                        22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CATEGORY HEADING
  // ===============================================================

  Widget _categoryHeading(
    int count,
  ) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              TextWidget(
                "Quiz Categories",
                size: 18,
                weight:
                    FontWeight.w900,
                color:
                    AppColor.text,
              ),

              SizedBox(height: 3),

              TextWidget(
                "Choose a topic to continue",
                size: 11.5,
                color:
                    AppColor.textMuted,
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),

          decoration:
              BoxDecoration(
            color:
                AppColor.primarySoft,

            borderRadius:
                BorderRadius.circular(
              999,
            ),
          ),

          child: TextWidget(
            "$count",
            size: 11,
            weight:
                FontWeight.w900,
            color:
                AppColor.primary,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CATEGORY ICON
  // ===============================================================

  IconData _iconForCategory(
    String category,
  ) {
    final t =
        category.toLowerCase();

    if (t.contains(
      "emergency",
    )) {
      return Icons
          .emergency_outlined;
    }

    if (t.contains(
          "food",
        ) ||
        t.contains(
          "water",
        )) {
      return Icons
          .water_drop_outlined;
    }

    if (t.contains(
      "first",
    )) {
      return Icons
          .medical_services_outlined;
    }

    if (t.contains(
      "response",
    )) {
      return Icons
          .shield_outlined;
    }

    if (t.contains(
      "earth",
    )) {
      return Icons
          .public_outlined;
    }

    if (t.contains(
      "flood",
    )) {
      return Icons
          .waves_outlined;
    }

    if (t.contains(
      "fire",
    )) {
      return Icons
          .local_fire_department_outlined;
    }

    if (t.contains("storm") ||
        t.contains("weather")) {
      return Icons
          .thunderstorm_outlined;
    }

    return Icons
        .school_outlined;
  }

  // ===============================================================
  // CATEGORY COLOR
  // UI ONLY
  // ===============================================================

  Color _colorForCategory(
    String category,
  ) {
    final t =
        category.toLowerCase();

    if (t.contains(
      "emergency",
    )) {
      return AppColor.warning;
    }

    if (t.contains(
          "food",
        ) ||
        t.contains(
          "water",
        )) {
      return AppColor.info;
    }

    if (t.contains(
      "first",
    )) {
      return AppColor.danger;
    }

    if (t.contains(
      "response",
    )) {
      return AppColor.safeGreen;
    }

    return AppColor.primary;
  }

  // ===============================================================
  // PROGRESS LOADING
  // ===============================================================

  Widget _progressLoading() {
    return Container(
      width: double.infinity,
      height: 150,

      decoration:
          BoxDecoration(
        color:
            AppColor.surface,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              AppColor.border,
        ),
      ),

      child: const Center(
        child:
            CircularProgressIndicator(
          color:
              AppColor.primary,
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY CATEGORIES
  // ===============================================================

  Widget _emptyCategories() {
    return Center(
      child: Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          22,
        ),

        decoration:
            BoxDecoration(
          color:
              AppColor.surface,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                AppColor.border,
          ),
        ),

        child:
            const Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .quiz_outlined,
              size:
                  38,
              color:
                  AppColor.textMuted,
            ),

            SizedBox(
              height:
                  12,
            ),

            TextWidget(
              "No categories found yet",
              size:
                  15,
              weight:
                  FontWeight.w800,
              color:
                  AppColor.text,
              align:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PROGRESS DASHBOARD
// =================================================================

class _ProgressDashboard
    extends StatelessWidget {
  const _ProgressDashboard({
    required this.safeAnswered,
    required this.totalQuestions,
    required this.progress,
  });

  final int safeAnswered;
  final int totalQuestions;
  final double progress;

  @override
  Widget build(
    BuildContext context,
  ) {
    final percentage =
        (progress * 100).round();

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColor.secondary,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColor
                .secondary
                .withOpacity(
              0.15,
            ),

            blurRadius:
                20,

            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),

      child:
          Row(
        children: [
          // =======================================================
          // CIRCULAR PROGRESS
          // =======================================================

          SizedBox(
            width:
                90,
            height:
                90,

            child:
                Stack(
              alignment:
                  Alignment.center,

              children: [
                SizedBox(
                  width:
                      86,
                  height:
                      86,

                  child:
                      CircularProgressIndicator(
                    value:
                        progress,

                    strokeWidth:
                        8,

                    backgroundColor:
                        Colors.white
                            .withOpacity(
                      0.12,
                    ),

                    color:
                        Colors.white,
                  ),
                ),

                Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    TextWidget(
                      "$percentage%",
                      size:
                          18,
                      weight:
                          FontWeight.w900,
                      color:
                          Colors.white,
                    ),

                    const TextWidget(
                      "DONE",
                      size:
                          9,
                      weight:
                          FontWeight.w700,
                      color:
                          Color(
                        0xBFFFFFFF,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                18,
          ),

          // =======================================================
          // PROGRESS TEXT
          // =======================================================

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const TextWidget(
                  "Overall Progress",
                  size:
                      15,
                  weight:
                      FontWeight.w800,
                  color:
                      Colors.white,
                ),

                const SizedBox(
                  height:
                      5,
                ),

                TextWidget(
                  "$safeAnswered of $totalQuestions questions",
                  size:
                      12,
                  color:
                      Colors.white
                          .withOpacity(
                    0.72,
                  ),
                ),

                const SizedBox(
                  height:
                      14,
                ),

                Row(
                  children: [
                    _miniMetric(
                      icon:
                          Icons.check_rounded,
                      value:
                          "$safeAnswered",
                      label:
                          "Correct",
                    ),

                    const SizedBox(
                      width:
                          10,
                    ),

                    _miniMetric(
                      icon:
                          Icons.quiz_outlined,
                      value:
                          "$totalQuestions",
                      label:
                          "Total",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child:
          Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal:
              10,
          vertical:
              9,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white
                  .withOpacity(
            0.09,
          ),

          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        child:
            Row(
          children: [
            Icon(
              icon,
              size:
                  16,
              color:
                  Colors.white,
            ),

            const SizedBox(
              width:
                  7,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  TextWidget(
                    value,
                    size:
                        12,
                    weight:
                        FontWeight.w900,
                    color:
                        Colors.white,
                  ),

                  TextWidget(
                    label,
                    size:
                        9.5,
                    color:
                        Colors.white
                            .withOpacity(
                      0.60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// CATEGORY CARD
// =================================================================

class _CategoryCard
    extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),

        onTap:
            onTap,

        child:
            Container(
          padding:
              const EdgeInsets.all(
            15,
          ),

          decoration:
              BoxDecoration(
            color:
                AppColor.surface,

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            border:
                Border.all(
              color:
                  AppColor.border,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    AppColor.shadow,

                blurRadius:
                    14,

                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    width:
                        44,
                    height:
                        44,

                    decoration:
                        BoxDecoration(
                      color:
                          color.withOpacity(
                        0.10,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child:
                        Icon(
                      icon,
                      color:
                          color,
                      size:
                          22,
                    ),
                  ),

                  Container(
                    width:
                        30,
                    height:
                        30,

                    decoration:
                        BoxDecoration(
                      color:
                          AppColor.inputFill,

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        const Icon(
                      Icons
                          .arrow_outward_rounded,
                      color:
                          AppColor.textMuted,
                      size:
                          16,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              TextWidget(
                title,
                size:
                    14,
                weight:
                    FontWeight.w900,
                color:
                    AppColor.text,
                maxLines:
                    2,
                overflow:
                    TextOverflow.ellipsis,
              ),

              const SizedBox(
                height:
                    6,
              ),

              Row(
                children: [
                  Container(
                    width:
                        6,
                    height:
                        6,

                    decoration:
                        BoxDecoration(
                      color:
                          color,
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const SizedBox(
                    width:
                        6,
                  ),

                  const Expanded(
                    child:
                        TextWidget(
                      "Open quiz",
                      size:
                          10.5,
                      color:
                          AppColor.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}