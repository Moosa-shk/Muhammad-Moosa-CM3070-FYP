// lib/screens/quiz/categories_detail_screen.dart

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/widgets/text_widget.dart';

import 'quiz_screen.dart';

class CategoriesDetailScreen extends StatelessWidget {
  final String category;

  const CategoriesDetailScreen({
    super.key,
    required this.category,
  });

  static const List<String> kitImages = [
    'assets/images/kit_first_aid.png',
    'assets/images/kit_flashlight.png',
    'assets/images/kit_water.png',
    'assets/images/kit_radio.png',
    'assets/images/kit_food.png',
  ];

  // ===============================================================
  // FIRESTORE CATEGORY MAPPING
  // PRESERVED
  // ===============================================================

  String get _categoryId {
    switch (category) {
      case 'Emergency Basics':
        return 'emergency_basics';

      case 'Food & Water Safety':
        return 'food_water_safety';

      case 'First Aid & Health':
        return 'first_aid_health';

      case 'Disaster Response':
        return 'disaster_response';

      default:
        return category
            .trim()
            .toLowerCase()
            .replaceAll('&', 'and')
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
            .replaceAll(RegExp(r'^_+|_+$'), '');
    }
  }

  // ===============================================================
  // FIRESTORE QUESTIONS REFERENCE
  // PRESERVED
  // ===============================================================

  CollectionReference<Map<String, dynamic>> get _questionsRef {
    return FirebaseFirestore.instance
        .collection('quizzes')
        .doc(_categoryId)
        .collection('questions');
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to access quizzes.',
          ),
        ),
      );
    }

    final uid = user.uid;

    return AppScaffold(
      title: null,
      subtitle: null,
      showBack: true,
      scroll: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _questionsRef.snapshots(),

        builder: (
          context,
          questionSnap,
        ) {
          // =======================================================
          // QUESTIONS ERROR
          // =======================================================

          if (questionSnap.hasError) {
            return _errorState(
              title:
                  'Unable to load questions',
              message:
                  questionSnap.error.toString(),
            );
          }

          // =======================================================
          // QUESTIONS LOADING
          // =======================================================

          if (questionSnap.connectionState ==
              ConnectionState.waiting) {
            return _loadingState();
          }

          final questionDocs =
              questionSnap.data?.docs ?? [];

          final totalQuestions =
              questionDocs.length;

          // =======================================================
          // USER QUIZ ATTEMPTS
          // FIRESTORE LOGIC PRESERVED
          // =======================================================

          return StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('quizAttempts')
                .where(
                  'category',
                  isEqualTo: category,
                )
                .where(
                  'isCorrect',
                  isEqualTo: true,
                )
                .snapshots(),

            builder: (
              context,
              attemptSnap,
            ) {
              // ===================================================
              // ATTEMPT ERROR
              // ===================================================

              if (attemptSnap.hasError) {
                return _errorState(
                  title:
                      'Unable to load quiz progress',
                  message:
                      attemptSnap.error.toString(),
                );
              }

              // ===================================================
              // ATTEMPT LOADING
              // ===================================================

              if (attemptSnap.connectionState ==
                  ConnectionState.waiting) {
                return _loadingState();
              }

              final attempts =
                  attemptSnap.data?.docs ?? [];

              final completedQuestions =
                  attempts
                      .map(
                        (d) => d
                            .data()['questionId']
                            ?.toString(),
                      )
                      .whereType<String>()
                      .toSet()
                      .length;

              final safeCompleted =
                  completedQuestions.clamp(
                0,
                totalQuestions,
              );

              final unlockedKits =
                  safeCompleted.clamp(
                0,
                kitImages.length,
              );

              final allKitsUnlocked =
                  unlockedKits ==
                          kitImages.length &&
                      totalQuestions > 0;

              final progress =
                  totalQuestions == 0
                      ? 0.0
                      : safeCompleted /
                          totalQuestions;

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CUSTOM CATEGORY HEADER
                  // =================================================

                  _pageHeader(
                    completed:
                        safeCompleted,
                    total:
                        totalQuestions,
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // =================================================
                  // PROGRESS COMMAND PANEL
                  // =================================================

                  _progressPanel(
                    completed:
                        safeCompleted,
                    totalQuestions:
                        totalQuestions,
                    unlocked:
                        unlockedKits,
                    progress:
                        progress,
                    completedCategory:
                        allKitsUnlocked,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =================================================
                  // KIT LOCKER TITLE
                  // =================================================

                  _kitHeading(
                    unlocked:
                        unlockedKits,
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  // =================================================
                  // KIT LOCKER
                  // =================================================

                  Expanded(
                    child: totalQuestions == 0
                        ? _emptyQuestionsState()
                        : _kitLocker(
                            unlockedKits:
                                unlockedKits,
                          ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // =================================================
                  // START / COMPLETED ACTION
                  // =================================================

                  _startButton(
                    allKitsUnlocked:
                        allKitsUnlocked,
                    totalQuestions:
                        totalQuestions,
                    onPressed: () async {
                      try {
                        final snap =
                            await _questionsRef
                                .get();

                        final questions =
                            snap.docs.map(
                          (d) {
                            return <
                                String,
                                dynamic>{
                              'id': d.id,
                              ...d.data(),
                            };
                          },
                        ).toList();

                        if (questions
                            .isEmpty) {
                          Get.snackbar(
                            'Quiz',
                            'No questions found for this category.',
                            backgroundColor:
                                AppColor
                                    .danger,
                            colorText:
                                Colors
                                    .white,
                          );

                          return;
                        }

                        Get.to(
                          () => QuizScreen(
                            category:
                                category,
                            questions:
                                questions,
                          ),
                        );
                      } on FirebaseException catch (e) {
                        Get.snackbar(
                          'Firebase Error',
                          e.message ??
                              e.code,
                          backgroundColor:
                              AppColor
                                  .danger,
                          colorText:
                              Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          e.toString(),
                          backgroundColor:
                              AppColor
                                  .danger,
                          colorText:
                              Colors.white,
                        );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ===============================================================
  // CUSTOM PAGE HEADER
  // ===============================================================

  Widget _pageHeader({
    required int completed,
    required int total,
  }) {
    return SizedBox(
      width: double.infinity,

      child: Column(
        children: [
          TextWidget(
            category.toUpperCase(),
            size: 25,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          const SizedBox(
            height: 6,
          ),

          const TextWidget(
            "Unlock safety kit items by answering correctly",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),

            decoration:
                BoxDecoration(
              color:
                  AppColor.inputFill,

              borderRadius:
                  BorderRadius.circular(
                999,
              ),

              border:
                  Border.all(
                color:
                    AppColor.border,
              ),
            ),

            child: TextWidget(
              "$completed of $total completed",
              size: 11,
              weight:
                  FontWeight.w800,
              color:
                  AppColor.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROGRESS PANEL
  // ===============================================================

  Widget _progressPanel({
    required int completed,
    required int totalQuestions,
    required int unlocked,
    required double progress,
    required bool completedCategory,
  }) {
    return Container(
      width: double.infinity,

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

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withOpacity(
                    0.10,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Icon(
                  completedCategory
                      ? Icons
                          .workspace_premium_rounded
                      : Icons
                          .inventory_2_outlined,
                  color:
                      Colors.white,
                  size:
                      24,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const TextWidget(
                      "Safety Kit Progress",
                      size: 16,
                      weight:
                          FontWeight.w800,
                      color:
                          Colors.white,
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    TextWidget(
                      completedCategory
                          ? "All kit items unlocked"
                          : "$unlocked of ${kitImages.length} items unlocked",
                      size: 11.5,
                      color: Colors
                          .white
                          .withOpacity(
                        0.72,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      11,
                  vertical:
                      7,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withOpacity(
                    0.10,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    999,
                  ),
                ),

                child:
                    TextWidget(
                  completedCategory
                      ? "DONE"
                      : "${(progress * 100).round()}%",

                  size:
                      11,

                  weight:
                      FontWeight.w900,

                  color:
                      Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              999,
            ),

            child:
                LinearProgressIndicator(
              value:
                  progress.clamp(
                0,
                1,
              ),

              minHeight:
                  10,

              backgroundColor:
                  Colors.white
                      .withOpacity(
                0.13,
              ),

              color:
                  Colors.white,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _progressStat(
                  icon:
                      Icons.quiz_outlined,

                  value:
                      "$completed/$totalQuestions",

                  label:
                      "Questions",
                ),
              ),

              Container(
                width:
                    1,

                height:
                    34,

                color:
                    Colors.white
                        .withOpacity(
                  0.16,
                ),
              ),

              Expanded(
                child:
                    _progressStat(
                  icon:
                      Icons.backpack_outlined,

                  value:
                      "$unlocked/${kitImages.length}",

                  label:
                      "Kit items",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white
              .withOpacity(
            0.90,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            TextWidget(
              value,
              size: 13,
              weight:
                  FontWeight.w900,
              color:
                  Colors.white,
            ),

            TextWidget(
              label,
              size: 10,
              color: Colors.white
                  .withOpacity(
                0.62,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===============================================================
  // KIT HEADING
  // ===============================================================

  Widget _kitHeading({
    required int unlocked,
  }) {
    return Row(
      children: [
        const Expanded(
          child: TextWidget(
            "Safety Kit",
            size: 18,
            weight:
                FontWeight.w900,
            color:
                AppColor.text,
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
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

          child:
              TextWidget(
            "$unlocked unlocked",
            size:
                10.5,
            weight:
                FontWeight.w800,
            color:
                AppColor.primary,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // KIT LOCKER
  // ===============================================================

  Widget _kitLocker({
    required int unlockedKits,
  }) {
    return ListView.separated(
      scrollDirection:
          Axis.horizontal,

      physics:
          const BouncingScrollPhysics(),

      itemCount:
          kitImages.length,

      separatorBuilder:
          (_, __) =>
              const SizedBox(
        width: 12,
      ),

      itemBuilder:
          (_, index) {
        final unlocked =
            index <
                unlockedKits;

        return TweenAnimationBuilder<
            double>(
          duration: Duration(
            milliseconds:
                350 +
                    (index *
                        70),
          ),

          tween:
              Tween(
            begin: 0,
            end: 1,
          ),

          curve:
              Curves.easeOutCubic,

          builder:
              (_, value, child) {
            return Opacity(
              opacity:
                  value,

              child:
                  Transform.translate(
                offset:
                    Offset(
                  12 *
                      (1 -
                          value),
                  0,
                ),

                child:
                    child,
              ),
            );
          },

          child:
              _kitCard(
            image:
                kitImages[index],
            number:
                index + 1,
            unlocked:
                unlocked,
          ),
        );
      },
    );
  }

  Widget _kitCard({
    required String image,
    required int number,
    required bool unlocked,
  }) {
    return Container(
      width: 152,

      padding:
          const EdgeInsets.all(
        14,
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
          color: unlocked
              ? AppColor
                  .primary
                  .withOpacity(
                    0.16,
                  )
              : AppColor
                  .border,
        ),

        boxShadow: [
          BoxShadow(
            color:
                AppColor.shadow,

            blurRadius:
                15,

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
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      8,
                  vertical:
                      5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      AppColor.inputFill,

                  borderRadius:
                      BorderRadius.circular(
                    999,
                  ),
                ),

                child:
                    TextWidget(
                  "KIT $number",
                  size:
                      9.5,
                  weight:
                      FontWeight.w800,
                  color:
                      AppColor.textMuted,
                ),
              ),

              Container(
                width:
                    30,

                height:
                    30,

                decoration:
                    BoxDecoration(
                  color: unlocked
                      ? AppColor
                          .safeSoft
                      : AppColor
                          .inputFill,

                  shape:
                      BoxShape.circle,
                ),

                child:
                    Icon(
                  unlocked
                      ? Icons
                          .check_rounded
                      : Icons
                          .lock_outline_rounded,

                  size:
                      16,

                  color: unlocked
                      ? AppColor
                          .safeGreen
                      : AppColor
                          .textMuted,
                ),
              ),
            ],
          ),

          const Spacer(),

          Center(
            child:
                AnimatedOpacity(
              opacity:
                  unlocked
                      ? 1
                      : 0.20,

              duration:
                  const Duration(
                milliseconds:
                    180,
              ),

              child:
                  Image.asset(
                image,
                height:
                    78,

                fit:
                    BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          TextWidget(
            unlocked
                ? "Unlocked"
                : "Locked",

            size:
                12,

            weight:
                FontWeight.w800,

            color: unlocked
                ? AppColor
                    .safeGreen
                : AppColor
                    .textMuted,
          ),

          const SizedBox(
            height: 3,
          ),

          TextWidget(
            unlocked
                ? "Added to your kit"
                : "Complete question ${number.clamp(1, 5)}",

            size:
                10.5,

            color:
                AppColor.textMuted,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EMPTY QUESTIONS
  // ===============================================================

  Widget _emptyQuestionsState() {
    return Container(
      width: double.infinity,

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

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: const [
          Icon(
            Icons
                .inventory_2_outlined,
            size: 42,
            color:
                AppColor.textMuted,
          ),

          SizedBox(
            height: 12,
          ),

          TextWidget(
            "No questions found",
            size: 16,
            weight:
                FontWeight.w800,
            color:
                AppColor.text,
          ),

          SizedBox(
            height: 5,
          ),

          TextWidget(
            "Quiz content is not available for this category.",
            size: 12,
            color:
                AppColor.textMuted,
            align:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // START QUIZ BUTTON
  // ===============================================================

  Widget _startButton({
    required bool allKitsUnlocked,
    required int totalQuestions,
    required Future<void> Function()
        onPressed,
  }) {
    final disabled =
        allKitsUnlocked ||
            totalQuestions == 0;

    return SizedBox(
      width:
          double.infinity,
      height:
          58,

      child:
          ElevatedButton(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              allKitsUnlocked
                  ? AppColor
                      .safeGreen
                  : AppColor
                      .primary,

          disabledBackgroundColor:
              allKitsUnlocked
                  ? AppColor
                      .safeGreen
                      .withOpacity(
                        0.55,
                      )
                  : Colors
                      .grey
                      .shade300,

          elevation:
              disabled
                  ? 0
                  : 8,

          shadowColor:
              AppColor.primary
                  .withOpacity(
            0.20,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),

        onPressed: disabled
            ? null
            : () async {
                await onPressed();
              },

        child:
            Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              allKitsUnlocked
                  ? Icons
                      .verified_rounded
                  : Icons
                      .play_arrow_rounded,

              color:
                  Colors.white,

              size:
                  22,
            ),

            const SizedBox(
              width: 8,
            ),

            TextWidget(
              allKitsUnlocked
                  ? "CATEGORY COMPLETED"
                  : "START QUIZ",

              size:
                  14,

              weight:
                  FontWeight.w900,

              color:
                  Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // LOADING STATE
  // ===============================================================

  Widget _loadingState() {
    return const Center(
      child:
          CircularProgressIndicator(
        color:
            AppColor.primary,
      ),
    );
  }

  // ===============================================================
  // ERROR STATE
  // ===============================================================

  Widget _errorState({
    required String title,
    required String message,
  }) {
    return Center(
      child:
          Container(
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
            color: AppColor
                .danger
                .withOpacity(
              0.20,
            ),
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width:
                  56,
              height:
                  56,

              decoration:
                  BoxDecoration(
                color:
                    AppColor.dangerSoft,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child:
                  const Icon(
                Icons
                    .error_outline_rounded,
                color:
                    AppColor.danger,
                size:
                    28,
              ),
            ),

            const SizedBox(
              height:
                  14,
            ),

            TextWidget(
              title,
              size:
                  16,
              weight:
                  FontWeight.w900,
              color:
                  AppColor.text,
              align:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  7,
            ),

            TextWidget(
              message,
              size:
                  11.5,
              color:
                  AppColor.textMuted,
              align:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}