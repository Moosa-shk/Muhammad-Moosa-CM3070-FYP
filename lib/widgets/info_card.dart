import 'package:flutter/material.dart';
import '../config/colors.dart';
import 'text_widget.dart';

/// InfoCard is a reusable UI component used to present
/// important information or navigation options in the app.
/// Each card displays an icon, a title, a short description,
/// and allows users to tap it to open another screen.
class InfoCard extends StatelessWidget {

  /// Title displayed on the card
  final String title;

  /// Short descriptive subtitle
  final String subtitle;

  /// Icon representing the feature or information
  final IconData icon;

  /// Function executed when the card is tapped
  final VoidCallback onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      /// Detect tap gesture on the card
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),

        /// Card visual styling
        decoration: BoxDecoration(
          color: AppColor.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.border),

          /// Soft shadow to give elevation effect
          boxShadow: [
            BoxShadow(
              color: AppColor.shadow,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          children: [

            /// Icon container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColor.primary),
            ),

            const SizedBox(width: 14),

            /// Title and subtitle text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title,
                    weight: FontWeight.w900,
                    size: 16,
                  ),

                  const SizedBox(height: 4),

                  TextWidget(
                    subtitle,
                    color: AppColor.textMuted,
                    size: 13,
                  ),
                ],
              ),
            ),

            /// Arrow icon indicating navigation
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColor.textMuted.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}