import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/colors.dart';

/// PopupUtils provides helper methods to show user feedback messages
/// such as success, warning, error, and informational notifications.
/// These messages are displayed using GetX snackbar notifications.
class PopupUtils {

  /// Displays a success notification (e.g., when an operation completes successfully)
  static void success(String title, String message) {
    _showSnack(title, message, AppColor.safeGreen, Icons.check_circle_rounded);
  }

  /// Displays a warning notification (e.g., when attention is required)
  static void warning(String title, String message) {
    _showSnack(title, message, AppColor.primary, Icons.warning_rounded);
  }

  /// Displays an error notification (e.g., when something fails)
  static void error(String title, String message) {
    _showSnack(title, message, AppColor.danger, Icons.error_rounded);
  }

  /// Displays an informational notification (e.g., helpful guidance)
  static void info(String title, String message) {
    _showSnack(title, message, AppColor.secondary, Icons.info_outline_rounded);
  }

  /// Internal helper function that builds and displays the snackbar
  static void _showSnack(
    String title,
    String message,
    Color tone,
    IconData icon,
  ) {

    /// GetX snackbar is used to display the message on screen
    Get.snackbar(
      title,
      message,

      /// Snackbar background styling
      backgroundColor: AppColor.cardFill,

      /// Text color for readability
      colorText: AppColor.text,

      /// Icon representing the notification type
      icon: Container(
        decoration: BoxDecoration(
          color: tone.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: tone.withOpacity(0.22)),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: tone, size: 22),
      ),

      /// Margin around the snackbar
      margin: const EdgeInsets.all(16),

      /// Rounded corners for modern UI style
      borderRadius: 18,

      /// Snackbar position on the screen
      snackPosition: SnackPosition.BOTTOM,

      /// Duration for which the snackbar remains visible
      duration: const Duration(seconds: 3),

      /// Shadow effect to improve visibility
      boxShadows: [
        BoxShadow(
          color: tone.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}