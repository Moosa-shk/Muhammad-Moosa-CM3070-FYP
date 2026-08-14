// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

/// This file defines the main visual theme used across the application.
/// It ensures that colors, text styles, and input fields remain
/// consistent throughout the app interface.
class AppTheme {

  /// Returns the light theme configuration for the app.
  /// The design follows Material 3 guidelines while applying
  /// custom colors defined in AppColor.
  static ThemeData light() {

    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(

      /// Main background color of screens
      scaffoldBackgroundColor: AppColor.bg,

      /// Defines the main color scheme used by the UI
      colorScheme: base.colorScheme.copyWith(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        surface: AppColor.surface,
        onSurface: AppColor.text,
        onPrimary: Colors.white,
      ),

      /// Custom text styles used throughout the app
      textTheme: base.textTheme.copyWith(

        /// Headline style used for important titles
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColor.text,
        ),

        /// Section titles used in screens
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColor.text,
        ),

        /// Main body text style
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: AppColor.text,
          fontWeight: FontWeight.w600,
        ),

        /// Secondary text used for hints or muted content
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColor.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Styling for input fields used in forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.inputFill,

        /// Padding inside text fields
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        /// Style of labels inside inputs
        labelStyle: TextStyle(
          color: AppColor.textMuted.withOpacity(0.85),
          fontWeight: FontWeight.w600,
        ),

        /// Color of icons inside input fields
        prefixIconColor: AppColor.textMuted.withOpacity(0.80),

        /// Border style when the input is not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColor.borderStrong,
            width: 1,
          ),
        ),

        /// Border style when the input field is active
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColor.primary.withOpacity(0.65),
            width: 1.4,
          ),
        ),
      ),

      /// AppBar styling used across screens
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColor.text,
        centerTitle: true,
      ),
    );
  }
}