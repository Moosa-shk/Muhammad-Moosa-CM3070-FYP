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

    _playableQuestions = widget.questions
        .where((q) =>
            q['question'] != null &&
            q['options'] is List &&
            (q['options'] as List).isNotEmpty &&
            q['answer'] != null)
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
      duration: const Duration(milliseconds: 520),
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

  Future<void> _onAnswerTap(int index) async {
    if (answered) return;

    final q = _playableQuestions[currentIndex];
    final questionId = q['id'].toString();
    final options = List<String>.from(q['options']);
    final selected = options[index];
    final correct = q['answer'].toString();

    final isCorrect =
        selected.trim().toLowerCase() == correct.trim().toLowerCase();

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    final xp = isCorrect ? (q['xp'] ?? 10) as int : 0;

    final rewarded = await QuizProgressService.saveAttempt(
      questionId: questionId,
      category: widget.category,
      isCorrect: isCorrect,
      xp: xp,
      difficulty: q['difficulty'],
      questionText: q['question'],
    );

    if (rewarded && isCorrect) {
      final box = Hive.box<String>('kitBox');
      if (!box.values.contains(questionId)) {
        box.add(questionId);
        _showKitUnlockedAnimation();
      }
    }
  }

  void _next() {
    if (!answered) return;

    if (currentIndex < _playableQuestions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        answered = false;
      });
    } else {
      Get.off(() => CategoriesDetailScreen(category: widget.category));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_playableQuestions.isEmpty) return const SizedBox();

    final q = _playableQuestions[currentIndex];
    final options = List<String>.from(q['options']);
    final correct = q['answer'].toString();
    final xp = (q['xp'] ?? 10) as int;
    final difficulty = (q['difficulty'] ?? '').toString().trim();

    return AppScaffold(
      title: widget.category.toUpperCase(),
      subtitle: "Answer to earn XP",
      showBack: true,
      scroll: false,

      // ✅ FIX: give AppScaffold normal padding so title/subtitle align
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Stack(
        children: [
          // ✅ FIX: remove 24 here because AppScaffold already padded
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 128),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 420),
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - v)),
                      child: child,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "QUESTION ${currentIndex + 1} / ${_playableQuestions.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                          color: AppColor.textMuted,
                        ),
                      ),
                      const Spacer(),
                      _pill("XP $xp", icon: Icons.bolt_rounded),
                      if (difficulty.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _pill(_prettyDifficulty(difficulty),
                            icon: Icons.speed_rounded),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 520),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColor.cardFill,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColor.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Text(
                      q['question'],
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1.45,
                        fontWeight: FontWeight.w900,
                        color: AppColor.text,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                ...List.generate(options.length, (i) {
                  final state = _optionState(
                    answered: answered,
                    selectedIndex: selectedIndex,
                    i: i,
                    optionText: options[i],
                    correct: correct,
                  );

                  final bg = _optionBg(state);
                  final border = _optionBorder(state);
                  final textColor = _optionTextColor(state);
                  final icon = _optionIcon(state);
                  final iconColor = _optionIconColor(state);

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 280 + (i * 90)),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _onAnswerTap(i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: iconColor.withOpacity(0.18),
                                ),
                              ),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i],
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ✅ FIX: button aligned with same padding (no 24 because scaffold padded)
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: answered ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: answered ? 10 : 0,
                  shadowColor: AppColor.primary.withOpacity(0.30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  currentIndex == _playableQuestions.length - 1
                      ? "FINISH"
                      : "NEXT",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: answered ? Colors.white : Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== helpers (unchanged) =====

  Widget _pill(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: AppColor.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _prettyDifficulty(String d) {
    final t = d.toLowerCase();
    if (t.contains('easy')) return "Easy";
    if (t.contains('medium')) return "Medium";
    if (t.contains('hard')) return "Hard";
    return d;
  }

  _OptState _optionState({
    required bool answered,
    required int? selectedIndex,
    required int i,
    required String optionText,
    required String correct,
  }) {
    if (!answered) {
      if (selectedIndex == i) return _OptState.selected;
      return _OptState.idle;
    }

    final isCorrect = optionText.trim().toLowerCase() ==
        correct.trim().toLowerCase();

    if (isCorrect) return _OptState.correct;
    if (selectedIndex == i) return _OptState.wrong;
    return _OptState.disabled;
  }

  Color _optionBg(_OptState s) {
    switch (s) {
      case _OptState.correct:
        return AppColor.safeGreen.withOpacity(0.14);
      case _OptState.wrong:
        return AppColor.danger.withOpacity(0.12);
      case _OptState.selected:
        return AppColor.primary.withOpacity(0.12);
      case _OptState.disabled:
        return Colors.white.withOpacity(0.55);
      case _OptState.idle:
      default:
        return Colors.white.withOpacity(0.92);
    }
  }

  Color _optionBorder(_OptState s) {
    switch (s) {
      case _OptState.correct:
        return AppColor.safeGreen.withOpacity(0.35);
      case _OptState.wrong:
        return AppColor.danger.withOpacity(0.30);
      case _OptState.selected:
        return AppColor.primary.withOpacity(0.35);
      case _OptState.disabled:
        return AppColor.border;
      case _OptState.idle:
      default:
        return AppColor.border;
    }
  }

  Color _optionTextColor(_OptState s) {
    switch (s) {
      case _OptState.correct:
        return AppColor.safeGreen;
      case _OptState.wrong:
        return AppColor.danger;
      case _OptState.selected:
        return AppColor.secondary;
      case _OptState.disabled:
        return AppColor.textMuted.withOpacity(0.85);
      case _OptState.idle:
      default:
        return AppColor.text;
    }
  }

  IconData _optionIcon(_OptState s) {
    switch (s) {
      case _OptState.correct:
        return Icons.check_rounded;
      case _OptState.wrong:
        return Icons.close_rounded;
      case _OptState.selected:
        return Icons.radio_button_checked_rounded;
      case _OptState.disabled:
      case _OptState.idle:
      default:
        return Icons.circle_outlined;
    }
  }

  Color _optionIconColor(_OptState s) {
    switch (s) {
      case _OptState.correct:
        return AppColor.safeGreen;
      case _OptState.wrong:
        return AppColor.danger;
      case _OptState.selected:
        return AppColor.primary;
      case _OptState.disabled:
      case _OptState.idle:
      default:
        return AppColor.textMuted;
    }
  }

  void _showKitUnlockedAnimation() {
    _unlockController.forward(from: 0);

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColor.border),
              boxShadow: [
                BoxShadow(
                  blurRadius: 26,
                  color: Colors.black.withOpacity(0.22),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_rounded,
                    size: 54, color: AppColor.primary),
                SizedBox(height: 12),
                Text(
                  "PROGRESS UPDATED",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                    color: AppColor.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), entry.remove);
  }
}

enum _OptState { idle, selected, correct, wrong, disabled }