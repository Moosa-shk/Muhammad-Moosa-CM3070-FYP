// lib/screens/quiz/quiz_screen.dart

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/services/quiz_progress_service.dart';

import 'categories_detail_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> questions;

  const QuizScreen({
    super.key,
    required this.category,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _playableQuestions;

  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;

  late final AnimationController _unlockController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // =============================================================
    // QUESTION VALIDATION
    // ORIGINAL LOGIC PRESERVED
    // =============================================================

    _playableQuestions = widget.questions
        .where(
          (q) =>
              q['question'] != null &&
              q['options'] is List &&
              (q['options'] as List).isNotEmpty &&
              q['answer'] != null,
        )
        .toList();

    if (_playableQuestions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Quiz Error',
          'No valid questions found',
          backgroundColor: AppColor.danger,
          colorText: Colors.white,
        );

        Get.back();
      });
    }

    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 520,
      ),
    );

    _scaleAnim = CurvedAnimation(
      parent: _unlockController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _unlockController.dispose();
    super.dispose();
  }

  // ===============================================================
  // ANSWER LOGIC
  // EXACT BACKEND / PROGRESS LOGIC PRESERVED
  // ===============================================================

  Future<void> _onAnswerTap(int index) async {
    if (answered) return;

    final q = _playableQuestions[currentIndex];

    final questionId = q['id'].toString();

    final options = List<String>.from(
      q['options'],
    );

    final selected = options[index];
    final correct = q['answer'].toString();

    final isCorrect =
        selected.trim().toLowerCase() ==
        correct.trim().toLowerCase();

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    final xp = isCorrect
        ? (q['xp'] ?? 10) as int
        : 0;

    final rewarded =
        await QuizProgressService.saveAttempt(
      questionId: questionId,
      category: widget.category,
      isCorrect: isCorrect,
      xp: xp,
      difficulty: q['difficulty'],
      questionText: q['question'],
    );

    if (rewarded && isCorrect) {
      final box = Hive.box<String>(
        'kitBox',
      );

      if (!box.values.contains(questionId)) {
        box.add(questionId);

        _showKitUnlockedAnimation();
      }
    }
  }

  // ===============================================================
  // NEXT QUESTION
  // ORIGINAL FLOW PRESERVED
  // ===============================================================

  void _next() {
    if (!answered) return;

    if (currentIndex <
        _playableQuestions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        answered = false;
      });
    } else {
      Get.off(
        () => CategoriesDetailScreen(
          category: widget.category,
        ),
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    if (_playableQuestions.isEmpty) {
      return const SizedBox();
    }

    final q =
        _playableQuestions[currentIndex];

    final options =
        List<String>.from(
      q['options'],
    );

    final correct =
        q['answer'].toString();

    final xp =
        (q['xp'] ?? 10) as int;

    final difficulty =
        (q['difficulty'] ?? '')
            .toString()
            .trim();

    final questionProgress =
        (currentIndex + 1) /
            _playableQuestions.length;

    final selectedIsCorrect =
        selectedIndex != null &&
        options[selectedIndex!]
                .trim()
                .toLowerCase() ==
            correct
                .trim()
                .toLowerCase();

    return AppScaffold(
      title: null,
      subtitle: null,
      showBack: true,
      scroll: false,

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 92,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =================================================
                // PAGE HEADER
                // =================================================

                _quizHeader(
                  difficulty: difficulty,
                  xp: xp,
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================================
                // QUESTION PROGRESS
                // =================================================

                _questionProgress(
                  progress: questionProgress,
                ),

                const SizedBox(
                  height: 18,
                ),

                // =================================================
                // QUESTION STAGE
                // =================================================

                _questionStage(
                  question:
                      q['question'].toString(),
                ),

                const SizedBox(
                  height: 18,
                ),

                // =================================================
                // ANSWER LABEL
                // =================================================

                Row(
                  children: [
                    const Text(
                      "Choose an answer",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            AppColor.text,
                      ),
                    ),

                    const Spacer(),

                    if (!answered)
                      Text(
                        "${options.length} choices",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppColor.textMuted,
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 11,
                ),

                // =================================================
                // ANSWERS
                // =================================================

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),

                    physics:
                        const BouncingScrollPhysics(),

                    itemCount:
                        options.length,

                    itemBuilder:
                        (_, index) {
                      final state =
                          _optionState(
                        answered:
                            answered,
                        selectedIndex:
                            selectedIndex,
                        i:
                            index,
                        optionText:
                            options[index],
                        correct:
                            correct,
                      );

                      return TweenAnimationBuilder<
                          double>(
                        duration: Duration(
                          milliseconds:
                              260 +
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
                                18 *
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
                            _answerTile(
                          index:
                              index,
                          text:
                              options[index],
                          state:
                              state,
                          onTap:
                              () =>
                                  _onAnswerTap(
                            index,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // =================================================
                // ANSWER FEEDBACK
                // =================================================

                if (answered) ...[
                  const SizedBox(
                    height: 6,
                  ),

                  _answerFeedback(
                    correct:
                        selectedIsCorrect,
                    xp:
                        xp,
                  ),
                ],
              ],
            ),
          ),

          // =======================================================
          // FIXED CONTINUE BUTTON
          // =======================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 20,

            child: SizedBox(
              height: 58,

              child: ElevatedButton(
                onPressed:
                    answered
                        ? _next
                        : null,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColor.secondary,

                  disabledBackgroundColor:
                      AppColor
                          .inputFill,

                  elevation:
                      answered
                          ? 7
                          : 0,

                  shadowColor:
                      AppColor.secondary
                          .withOpacity(
                    0.18,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      currentIndex ==
                              _playableQuestions
                                      .length -
                                  1
                          ? "FINISH QUIZ"
                          : "CONTINUE",

                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing:
                            0.7,
                        fontWeight:
                            FontWeight.w900,
                        color: answered
                            ? Colors.white
                            : AppColor
                                .textMuted,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Icon(
                      currentIndex ==
                              _playableQuestions
                                      .length -
                                  1
                          ? Icons
                              .flag_outlined
                          : Icons
                              .arrow_forward_rounded,

                      size: 20,

                      color: answered
                          ? Colors.white
                          : AppColor
                              .textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // QUIZ HEADER
  // ===============================================================

  Widget _quizHeader({
    required String difficulty,
    required int xp,
  }) {
    return SizedBox(
      width:
          double.infinity,

      child:
          Column(
        children: [
          Text(
            widget.category
                .toUpperCase(),

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize:
                  24,
              fontWeight:
                  FontWeight.w900,
              color:
                  AppColor.text,
              letterSpacing:
                  -0.3,
            ),
          ),

          const SizedBox(
            height:
                6,
          ),

          const Text(
            "Answer to earn XP",

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              fontSize:
                  12.5,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColor.textMuted,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              _headerTag(
                icon:
                    Icons.bolt_rounded,
                text:
                    "$xp XP",
                color:
                    AppColor.warning,
              ),

              if (difficulty
                  .isNotEmpty) ...[
                const SizedBox(
                  width:
                      8,
                ),

                _headerTag(
                  icon:
                      Icons
                          .tune_rounded,
                  text:
                      _prettyDifficulty(
                    difficulty,
                  ),
                  color:
                      AppColor.info,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
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
            color.withOpacity(
          0.09,
        ),

        borderRadius:
            BorderRadius.circular(
          999,
        ),

        border:
            Border.all(
          color:
              color.withOpacity(
            0.13,
          ),
        ),
      ),

      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size:
                15,
            color:
                color,
          ),

          const SizedBox(
            width:
                5,
          ),

          Text(
            text,

            style:
                TextStyle(
              fontSize:
                  11,
              fontWeight:
                  FontWeight.w800,
              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // QUESTION PROGRESS
  // ===============================================================

  Widget _questionProgress({
    required double progress,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "QUESTION ${currentIndex + 1}",

              style:
                  const TextStyle(
                fontSize:
                    11,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColor.textMuted,
                letterSpacing:
                    1,
              ),
            ),

            const Spacer(),

            Text(
              "${currentIndex + 1} / ${_playableQuestions.length}",

              style:
                  const TextStyle(
                fontSize:
                    11,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppColor.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(
          height:
              8,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            999,
          ),

          child:
              LinearProgressIndicator(
            value:
                progress,

            minHeight:
                7,

            backgroundColor:
                AppColor.inputFill,

            color:
                AppColor.primary,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // QUESTION STAGE
  // ===============================================================

  Widget _questionStage({
    required String question,
  }) {
    return TweenAnimationBuilder<
        double>(
      duration:
          const Duration(
        milliseconds:
            420,
      ),

      tween:
          Tween(
        begin:
            0,
        end:
            1,
      ),

      curve:
          Curves.easeOutCubic,

      builder:
          (_, value, child) {
        return Opacity(
          opacity:
              value,

          child:
              Transform.scale(
            scale:
                0.97 +
                    (0.03 *
                        value),

            alignment:
                Alignment.topCenter,

            child:
                child,
          ),
        );
      },

      child:
          Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          22,
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
                0.16,
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
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width:
                  42,
              height:
                  42,

              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withOpacity(
                  0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),

              child:
                  const Icon(
                Icons
                    .help_outline_rounded,
                color:
                    Colors.white,
                size:
                    21,
              ),
            ),

            const SizedBox(
              height:
                  17,
            ),

            Text(
              question,

              style:
                  const TextStyle(
                fontSize:
                    19,
                height:
                    1.42,
                fontWeight:
                    FontWeight.w800,
                color:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ANSWER TILE
  // ===============================================================

  Widget _answerTile({
    required int index,
    required String text,
    required _OptState state,
    required VoidCallback onTap,
  }) {
    final background =
        _optionBg(state);

    final border =
        _optionBorder(state);

    final textColor =
        _optionTextColor(state);

    final accent =
        _optionIconColor(state);

    final trailingIcon =
        _optionIcon(state);

    final letter =
        String.fromCharCode(
      65 + index,
    );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom:
            11,
      ),

      child:
          Material(
        color:
            Colors.transparent,

        child:
            InkWell(
          onTap:
              answered
                  ? null
                  : onTap,

          borderRadius:
              BorderRadius.circular(
            17,
          ),

          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds:
                  220,
            ),

            width:
                double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  13,
              vertical:
                  13,
            ),

            decoration:
                BoxDecoration(
              color:
                  background,

              borderRadius:
                  BorderRadius.circular(
                17,
              ),

              border:
                  Border.all(
                color:
                    border,
              ),

              boxShadow: state ==
                          _OptState.correct ||
                      state ==
                          _OptState.wrong
                  ? [
                      BoxShadow(
                        color: accent
                            .withOpacity(
                          0.10,
                        ),
                        blurRadius:
                            14,
                        offset:
                            const Offset(
                          0,
                          7,
                        ),
                      ),
                    ]
                  : [],
            ),

            child:
                Row(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds:
                        220,
                  ),

                  width:
                      40,
                  height:
                      40,

                  alignment:
                      Alignment.center,

                  decoration:
                      BoxDecoration(
                    color: accent
                        .withOpacity(
                      state ==
                              _OptState
                                  .idle
                          ? 0.07
                          : 0.12,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    border:
                        Border.all(
                      color: accent
                          .withOpacity(
                        0.14,
                      ),
                    ),
                  ),

                  child:
                      Text(
                    letter,

                    style:
                        TextStyle(
                      fontSize:
                          13,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          accent,
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      13,
                ),

                Expanded(
                  child:
                      Text(
                    text,

                    style:
                        TextStyle(
                      color:
                          textColor,

                      fontWeight:
                          FontWeight.w700,

                      fontSize:
                          14,

                      height:
                          1.3,
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      10,
                ),

                Icon(
                  trailingIcon,
                  color:
                      accent,
                  size:
                      21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ANSWER FEEDBACK
  // ===============================================================

  Widget _answerFeedback({
    required bool correct,
    required int xp,
  }) {
    final color =
        correct
            ? AppColor.safeGreen
            : AppColor.danger;

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds:
            220,
      ),

      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal:
            14,
        vertical:
            12,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          15,
        ),

        border:
            Border.all(
          color:
              color.withOpacity(
            0.14,
          ),
        ),
      ),

      child:
          Row(
        children: [
          Container(
            width:
                34,
            height:
                34,

            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                0.12,
              ),

              shape:
                  BoxShape.circle,
            ),

            child:
                Icon(
              correct
                  ? Icons.check_rounded
                  : Icons.close_rounded,

              color:
                  color,

              size:
                  19,
            ),
          ),

          const SizedBox(
            width:
                11,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  correct
                      ? "Correct"
                      : "Not quite",

                  style:
                      TextStyle(
                    fontSize:
                        13,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        color,
                  ),
                ),

                const SizedBox(
                  height:
                      2,
                ),

                Text(
                  correct
                      ? "+$xp XP earned"
                      : "The correct answer is highlighted.",

                  style:
                      const TextStyle(
                    fontSize:
                        11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColor.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DIFFICULTY
  // ORIGINAL INTERPRETATION PRESERVED
  // ===============================================================

  String _prettyDifficulty(String d) {
    final t = d.toLowerCase();

    if (t.contains('easy')) {
      return "Easy";
    }

    if (t.contains('medium')) {
      return "Medium";
    }

    if (t.contains('hard')) {
      return "Hard";
    }

    return d;
  }

  // ===============================================================
  // OPTION STATE
  // ORIGINAL LOGIC PRESERVED
  // ===============================================================

  _OptState _optionState({
    required bool answered,
    required int? selectedIndex,
    required int i,
    required String optionText,
    required String correct,
  }) {
    if (!answered) {
      if (selectedIndex == i) {
        return _OptState.selected;
      }

      return _OptState.idle;
    }

    final isCorrect =
        optionText.trim().toLowerCase() ==
        correct.trim().toLowerCase();

    if (isCorrect) {
      return _OptState.correct;
    }

    if (selectedIndex == i) {
      return _OptState.wrong;
    }

    return _OptState.disabled;
  }

  // ===============================================================
  // OPTION COLORS
  // UI ONLY
  // ===============================================================

  Color _optionBg(_OptState state) {
    switch (state) {
      case _OptState.correct:
        return AppColor.safeGreen
            .withOpacity(0.08);

      case _OptState.wrong:
        return AppColor.danger
            .withOpacity(0.07);

      case _OptState.selected:
        return AppColor.primary
            .withOpacity(0.08);

      case _OptState.disabled:
        return AppColor.surface
            .withOpacity(0.58);

      case _OptState.idle:
        return AppColor.surface;
    }
  }

  Color _optionBorder(
    _OptState state,
  ) {
    switch (state) {
      case _OptState.correct:
        return AppColor.safeGreen
            .withOpacity(0.32);

      case _OptState.wrong:
        return AppColor.danger
            .withOpacity(0.28);

      case _OptState.selected:
        return AppColor.primary
            .withOpacity(0.30);

      case _OptState.disabled:
        return AppColor.border;

      case _OptState.idle:
        return AppColor.border;
    }
  }

  Color _optionTextColor(
    _OptState state,
  ) {
    switch (state) {
      case _OptState.correct:
        return AppColor.text;

      case _OptState.wrong:
        return AppColor.text;

      case _OptState.selected:
        return AppColor.text;

      case _OptState.disabled:
        return AppColor.textMuted
            .withOpacity(0.70);

      case _OptState.idle:
        return AppColor.text;
    }
  }

  IconData _optionIcon(
    _OptState state,
  ) {
    switch (state) {
      case _OptState.correct:
        return Icons
            .check_circle_rounded;

      case _OptState.wrong:
        return Icons
            .cancel_rounded;

      case _OptState.selected:
        return Icons
            .radio_button_checked_rounded;

      case _OptState.disabled:
        return Icons
            .radio_button_unchecked_rounded;

      case _OptState.idle:
        return Icons
            .radio_button_unchecked_rounded;
    }
  }

  Color _optionIconColor(
    _OptState state,
  ) {
    switch (state) {
      case _OptState.correct:
        return AppColor.safeGreen;

      case _OptState.wrong:
        return AppColor.danger;

      case _OptState.selected:
        return AppColor.primary;

      case _OptState.disabled:
        return AppColor.textMuted
            .withOpacity(0.50);

      case _OptState.idle:
        return AppColor.textMuted;
    }
  }

  // ===============================================================
  // KIT UNLOCK ANIMATION
  // TRIGGER LOGIC PRESERVED — VISUAL CHANGED ONLY
  // ===============================================================

  void _showKitUnlockedAnimation() {
    _unlockController.forward(
      from: 0,
    );

    final overlay =
        Overlay.of(context);

    final entry =
        OverlayEntry(
      builder:
          (_) => Center(
        child:
            ScaleTransition(
          scale:
              _scaleAnim,

          child:
              Material(
            color:
                Colors.transparent,

            child:
                Container(
              width:
                  220,

              padding:
                  const EdgeInsets.fromLTRB(
                22,
                24,
                22,
                22,
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
                    blurRadius:
                        30,
                    color:
                        Colors.black
                            .withOpacity(
                      0.22,
                    ),
                    offset:
                        const Offset(
                      0,
                      14,
                    ),
                  ),
                ],
              ),

              child:
                  Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  Container(
                    width:
                        62,
                    height:
                        62,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white
                              .withOpacity(
                        0.10,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        19,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .backpack_outlined,
                      size:
                          31,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height:
                        15,
                  ),

                  const Text(
                    "KIT UPDATED",

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w900,

                      fontSize:
                          14,

                      letterSpacing:
                          1,

                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height:
                        5,
                  ),

                  Text(
                    "New safety progress saved",

                    textAlign:
                        TextAlign.center,

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w600,

                      fontSize:
                          11,

                      color:
                          Colors.white
                              .withOpacity(
                        0.68,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(
      const Duration(
        seconds: 1,
      ),
      entry.remove,
    );
  }
}

enum _OptState {
  idle,
  selected,
  correct,
  wrong,
  disabled,
}