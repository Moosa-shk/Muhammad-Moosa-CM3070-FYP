import 'package:flutter/material.dart';
import '../config/colors.dart';
import 'text_widget.dart';

/// BadgeChip is a small reusable UI component used
/// to display short labels with an icon. It can be used
/// to represent achievements, alerts, or status indicators
/// inside the application interface.
class BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const BadgeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      /// Margin around the chip to separate it from other elements
      margin: const EdgeInsets.all(8),

      /// Padding inside the chip
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      /// Styling of the chip container
      decoration: BoxDecoration(
        color: AppColor.cardFill,

        /// Border color changes depending on the chip type
        border: Border.all(color: color.withOpacity(0.35)),

        borderRadius: BorderRadius.circular(18),

        /// Light shadow effect for depth
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      /// Layout containing the icon and label
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// Icon container
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(

              /// Light background for icon
              color: color.withOpacity(0.12),

              borderRadius: BorderRadius.circular(12),
            ),

            /// Icon representing the chip category
            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(width: 10),

          /// Text label describing the badge
          TextWidget(
            label,
            color: color,
            size: 14,
            weight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}