// lib/config/colors.dart
import 'package:flutter/material.dart';

/// Central color palette used across the app.
class AppColor {
  // Brand
  static const Color primary = Color(0xFFF55959);
  static const Color secondary = Color(0xFF323137);

  // Background & surfaces
  static const Color bg = Color(0xFFF3F2E9);
  static const Color surface = Colors.white;

  // Text
  static const Color text = Color(0xFF1B1B1B);
  static const Color textMuted = Color(0xFF5A5A5A);

  // Borders & shadows
  static const Color border = Color(0x1A000000);
  static const Color borderStrong = Color(0x26000000);
  static const Color shadow = Color(0x1A000000);

  // Status
  static const Color safeGreen = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFE53935);

  // Glass UI fills
  static const Color cardFill = Color(0xCCFFFFFF);
  static const Color inputFill = Color(0xE6FFFFFF);
}