// lib/config/colors.dart

import 'package:flutter/material.dart';

/// Central color palette used across the app.
///
/// Design direction:
/// - Clean light background
/// - Professional slate blue brand
/// - High contrast typography
/// - Soft neutral cards
/// - Controlled emergency status colors
class AppColor {
  // =============================================================
  // BRAND
  // =============================================================

  /// Main brand / CTA / selected-state color
  static const Color primary = Color(0xFF3B5F82);

  /// Main deep neutral
  static const Color secondary = Color(0xFF1E2B38);

  // =============================================================
  // BACKGROUND & SURFACES
  // =============================================================

  /// Main screen background
  static const Color bg = Color(0xFFF7F9FC);

  /// Main surface/card color
  static const Color surface = Color(0xFFFFFFFF);

  // =============================================================
  // TEXT
  // =============================================================

  /// Main dark text
  static const Color text = Color(0xFF1E2833);

  /// Secondary / helper text
  static const Color textMuted = Color(0xFF6B7785);

  // =============================================================
  // BORDERS & SHADOWS
  // =============================================================

  /// Very light border
  static const Color border = Color(0xFFE7EBF0);

  /// Stronger input/card border
  static const Color borderStrong = Color(0xFFD5DCE5);

  /// Soft neutral shadow
  static const Color shadow = Color(0x140F1C2A);

  // =============================================================
  // STATUS COLORS
  // =============================================================

  /// Safe / success
  static const Color safeGreen = Color(0xFF4F8F68);

  /// Critical / danger
  static const Color danger = Color(0xFFD65353);

  /// Warning / caution
  static const Color warning = Color(0xFFD89B4B);

  /// Informational
  static const Color info = Color(0xFF4B7EA8);

  // =============================================================
  // COMPONENT FILLS
  // =============================================================

  /// Main elevated card fill
  static const Color cardFill = Color(0xFFFFFFFF);

  /// Form field fill
  static const Color inputFill = Color(0xFFF4F6F9);

  /// Soft tinted blue surface
  static const Color primarySoft = Color(0xFFEAF0F6);

  /// Soft success surface
  static const Color safeSoft = Color(0xFFEAF3ED);

  /// Soft danger surface
  static const Color dangerSoft = Color(0xFFFBEDED);

  /// Soft warning surface
  static const Color warningSoft = Color(0xFFFAF2E6);
}