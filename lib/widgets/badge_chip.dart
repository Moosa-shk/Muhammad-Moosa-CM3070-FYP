// lib/widgets/badge_chip.dart

import 'package:flutter/material.dart';

import '../config/colors.dart';
import 'text_widget.dart';

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
      margin: const EdgeInsets.all(6),

      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        14,
        8,
      ),

      decoration: BoxDecoration(
        color: AppColor.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: AppColor.border,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =====================================================
          // MEDAL ICON
          // =====================================================

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),

              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: color.withOpacity(0.14),
              ),
            ),

            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 22,
                ),

                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 7,
                    height: 7,

                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,

                      border: Border.all(
                        color: AppColor.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // =====================================================
          // LABEL
          // =====================================================

          TextWidget(
            label,
            size: 13,
            weight: FontWeight.w800,
            color: AppColor.text,
          ),

          const SizedBox(width: 8),

          // =====================================================
          // ACHIEVEMENT MARKER
          // =====================================================

          Container(
            width: 22,
            height: 22,

            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.check_rounded,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}