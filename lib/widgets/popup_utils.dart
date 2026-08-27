// lib/widgets/popup_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';

/// Global notification helper used across the application.
///
/// Existing usage remains exactly the same:
///
/// PopupUtils.success(...)
/// PopupUtils.warning(...)
/// PopupUtils.error(...)
/// PopupUtils.info(...)
class PopupUtils {
  // ===============================================================
  // PUBLIC METHODS
  // ===============================================================

  static void success(String title, String message) {
    _showSnack(
      title: title,
      message: message,
      tone: AppColor.safeGreen,
      softTone: AppColor.safeGreen.withOpacity(0.10),
      icon: Icons.check_rounded,
    );
  }

  static void warning(String title, String message) {
    _showSnack(
      title: title,
      message: message,
      tone: AppColor.warning,
      softTone: AppColor.warning.withOpacity(0.11),
      icon: Icons.priority_high_rounded,
    );
  }

  static void error(String title, String message) {
    _showSnack(
      title: title,
      message: message,
      tone: AppColor.danger,
      softTone: AppColor.danger.withOpacity(0.10),
      icon: Icons.close_rounded,
    );
  }

  static void info(String title, String message) {
    _showSnack(
      title: title,
      message: message,
      tone: AppColor.info,
      softTone: AppColor.info.withOpacity(0.10),
      icon: Icons.info_outline_rounded,
    );
  }

  // ===============================================================
  // SNACKBAR
  // ===============================================================

  static void _showSnack({
    required String title,
    required String message,
    required Color tone,
    required Color softTone,
    required IconData icon,
  }) {
    // Prevent multiple notifications stacking over each other.
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      '',
      '',

      // ===========================================================
      // POSITION
      // ===========================================================

      snackPosition: SnackPosition.TOP,

      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(Get.context!).padding.top + 10,
      ),

      padding: EdgeInsets.zero,

      borderRadius: 20,

      duration: const Duration(
        seconds: 3,
      ),

      animationDuration: const Duration(
        milliseconds: 320,
      ),

      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,

      backgroundColor: Colors.transparent,

      boxShadows: const [],

      // Remove GetX default text spacing.
      titleText: const SizedBox.shrink(),
      messageText: Container(
        width: double.infinity,

        padding: const EdgeInsets.fromLTRB(
          14,
          13,
          10,
          13,
        ),

        decoration: BoxDecoration(
          color: AppColor.surface,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: AppColor.border,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =====================================================
            // STATUS ICON
            // =====================================================

            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: softTone,
                borderRadius: BorderRadius.circular(14),
              ),

              child: Center(
                child: Container(
                  width: 25,
                  height: 25,

                  decoration: BoxDecoration(
                    color: tone,
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),

                  if (message.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // =====================================================
            // CLOSE BUTTON
            // =====================================================

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
              },

              child: Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: AppColor.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),

      // ===========================================================
      // BEHAVIOUR
      // ===========================================================

      isDismissible: true,

      dismissDirection: DismissDirection.horizontal,

      shouldIconPulse: false,
    );
  }
}