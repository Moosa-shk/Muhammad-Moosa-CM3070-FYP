import 'package:flutter/material.dart';
import '../config/colors.dart';
import 'text_widget.dart';

/// QuizOptionCard represents a selectable option within the quiz module.
/// It visually indicates whether the option is selected and allows
/// users to choose an answer by tapping the card.
class QuizOptionCard extends StatelessWidget {

  /// Text representing the quiz answer option
  final String option;

  /// Boolean value indicating whether this option is currently selected
  final bool selected;

  /// Callback function triggered when the user taps the option
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      /// Handle user tap interaction
      onTap: onTap,

      /// AnimatedContainer allows smooth transitions
      /// when the option selection state changes
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),

        /// Card styling
        decoration: BoxDecoration(

          /// Background color changes when selected
          color: selected
              ? AppColor.primary.withOpacity(0.10)
              : AppColor.cardFill,

          borderRadius: BorderRadius.circular(16),

          /// Border color highlights the selected option
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.borderStrong,
            width: 1.5,
          ),

          /// Shadow effect for visual elevation
          boxShadow: [
            BoxShadow(
              color: AppColor.shadow,
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [

            /// Radio-style icon showing selected or unselected state
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColor.primary : AppColor.textMuted,
            ),

            const SizedBox(width: 12),

            /// Display option text
            Expanded(
              child: TextWidget(
                option,
                size: 15,
                weight: FontWeight.w700,
                color: AppColor.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}