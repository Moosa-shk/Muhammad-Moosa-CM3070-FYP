// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/colors.dart';

/// Main global application theme.
///
/// Existing API remains:
///
/// AppTheme.light()
class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(
      useMaterial3: true,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme,
    );

    return base.copyWith(
      // ===========================================================
      // GLOBAL
      // ===========================================================

      scaffoldBackgroundColor: AppColor.bg,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        surface: AppColor.surface,
        onSurface: AppColor.text,
        onPrimary: Colors.white,
        error: AppColor.danger,
      ),

      // ===========================================================
      // TYPOGRAPHY
      // ===========================================================

      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),

        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),

        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.55,
        ),

        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w800,
        ),

        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w700,
        ),

        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),

        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColor.textMuted,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),

        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColor.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ===========================================================
      // APP BAR
      // ===========================================================

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColor.text,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColor.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),

      // ===========================================================
      // INPUTS
      // ===========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.inputFill,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),

        labelStyle: const TextStyle(
          color: AppColor.textMuted,
          fontWeight: FontWeight.w600,
        ),

        hintStyle: TextStyle(
          color: AppColor.textMuted.withOpacity(0.72),
          fontWeight: FontWeight.w500,
        ),

        prefixIconColor: AppColor.textMuted,
        suffixIconColor: AppColor.textMuted,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.borderStrong,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.primary,
            width: 1.4,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.danger,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.danger,
            width: 1.4,
          ),
        ),
      ),

      // ===========================================================
      // CARDS
      // ===========================================================

      cardTheme: CardThemeData(
        color: AppColor.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColor.border,
          ),
        ),
      ),

      // ===========================================================
      // ELEVATED BUTTONS
      // ===========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,

          minimumSize: const Size(
            0,
            54,
          ),

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),

      // ===========================================================
      // OUTLINED BUTTONS
      // ===========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primary,

          minimumSize: const Size(
            0,
            54,
          ),

          side: const BorderSide(
            color: AppColor.borderStrong,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ===========================================================
      // PROGRESS
      // ===========================================================

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.primary,
        linearTrackColor: AppColor.primarySoft,
        circularTrackColor: AppColor.primarySoft,
      ),

      // ===========================================================
      // DIVIDERS
      // ===========================================================

      dividerTheme: const DividerThemeData(
        color: AppColor.border,
        thickness: 1,
      ),

      // ===========================================================
      // SNACKBAR
      // ===========================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.secondary,
        behavior: SnackBarBehavior.floating,

        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}