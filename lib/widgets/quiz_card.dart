import 'package:flutter/material.dart';

import '../config/colors.dart';
import 'text_widget.dart';

/// QuizOptionCard represents a selectable option within the quiz module.
///
/// IMPORTANT:
/// Public API is intentionally preserved:
/// - option
/// - selected
/// - onTap
///
/// Only the visual design has been updated.
class QuizOptionCard extends StatelessWidget {
  /// Text representing the quiz answer option
  final String option;

  /// Whether this option is currently selected
  final bool selected;

  /// Triggered when the user taps this option
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 68,
            ),
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              16,
              12,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primary.withOpacity(0.08)
                  : AppColor.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColor.primary.withOpacity(0.55)
                    : AppColor.border,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppColor.primary.withOpacity(0.10)
                      : AppColor.shadow,
                  blurRadius: selected ? 18 : 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                // =================================================
                // SELECTION INDICATOR
                // =================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.primary
                        : AppColor.inputFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColor.primary
                          : AppColor.borderStrong,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColor.primary.withOpacity(
                                0.20,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    transitionBuilder: (
                      child,
                      animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      key: ValueKey(selected),
                      size: selected ? 22 : 19,
                      color: selected
                          ? Colors.white
                          : AppColor.textMuted,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // =================================================
                // OPTION
                // =================================================

                Expanded(
                  child: TextWidget(
                    option,
                    size: 14.5,
                    weight: selected
                        ? FontWeight.w900
                        : FontWeight.w700,
                    color: selected
                        ? AppColor.text
                        : AppColor.text,
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // RIGHT SELECTION STATE
                // =================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.primary.withOpacity(0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColor.primary
                          : AppColor.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(
                            Icons.circle,
                            size: 9,
                            color: AppColor.primary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}