// ===============================================================
// auth_ui.dart
// ---------------------------------------------------------------
// This file contains reusable UI components used in the
// authentication screens of the application.
//
// The purpose of this file is to maintain consistent styling
// across login and signup interfaces by centralizing the design
// tokens and reusable widgets such as:
// • Glass cards
// • Input fields
// • Primary buttons
// • Dropdown selectors
//
// These widgets follow a modern "glass UI" design and are styled
// using the application's primary color palette defined in
// AppColor.
// ===============================================================

import 'dart:ui';
import 'package:disaster_app_ui/config/colors.dart';
import 'package:flutter/material.dart';


// ===============================================================
// AuthTokens
// ---------------------------------------------------------------
// This class contains centralized theme values used throughout
// the authentication UI. These tokens help maintain consistency
// in colors, borders, shadows, and text styling.
// ===============================================================

class AuthTokens {
  static const bool isLight = true;

  /// Main text color
  static const Color text = Color(0xFF1B1B1B);

  /// Secondary muted text color
  static const Color textMuted = Color(0xFF5A5A5A);

  /// Glass card background
  static const Color cardFill = Color(0xCCFFFFFF);

  /// Text field background
  static const Color inputFill = Color(0xE6FFFFFF);

  /// Light border color
  static const Color border = Color(0x1A000000);

  /// Stronger border color
  static const Color borderStrong = Color(0x26000000);

  /// Default shadow
  static Color shadow = Colors.black.withOpacity(0.10);

  /// Hint text color
  static Color hint = textMuted.withOpacity(0.85);
}


// ===============================================================
// AuthGlassCard
// ---------------------------------------------------------------
// A reusable glass-style card used to wrap authentication forms.
// It applies blur effects, soft shadows, and rounded corners to
// achieve a modern frosted-glass UI appearance.
// ===============================================================

class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AuthTokens.cardFill,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AuthTokens.border),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                offset: const Offset(0, 16),
                color: AuthTokens.shadow,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}


// ===============================================================
// AuthField
// ---------------------------------------------------------------
// A custom text field used in authentication forms such as
// login and signup screens. It includes consistent styling,
// icons, borders, and typography.
// ===============================================================

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AuthTokens.borderStrong,
        width: 1,
      ),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AuthTokens.text,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
      cursorColor: AppColor.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AuthTokens.textMuted.withOpacity(0.85),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: AuthTokens.hint),
        prefixIcon: Icon(
          icon,
          color: AuthTokens.textMuted.withOpacity(0.80),
        ),
        filled: true,
        fillColor: AuthTokens.inputFill,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: AppColor.primary.withOpacity(0.65),
            width: 1.4,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}


// ===============================================================
// AuthPrimaryButton
// ---------------------------------------------------------------
// A reusable primary button for authentication actions such as
// Login and Sign Up. It includes press animation and loading
// indicator support to enhance user interaction.
// ===============================================================

class AuthPrimaryButton extends StatefulWidget {
  const AuthPrimaryButton({
    super.key,
    required this.title,
    required this.onTap,
    this.loading = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool loading;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.loading;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _pressCtrl.forward(),
      onTapCancel: disabled ? null : () => _pressCtrl.reverse(),
      onTapUp: disabled ? null : (_) => _pressCtrl.reverse(),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, __) {
          final scale = 1 - (_pressCtrl.value * 0.02);

          return Transform.scale(
            scale: scale,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),
              opacity: disabled ? 0.75 : 1,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                      color: AppColor.primary.withOpacity(0.28),
                    ),
                    BoxShadow(
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ],
                ),
                child: widget.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}


// ===============================================================
// AuthBloodDropdown
// ---------------------------------------------------------------
// A dropdown widget used to select blood groups during
// user profile creation. It follows the same styling used
// for authentication input fields.
// ===============================================================

class AuthBloodDropdown extends StatelessWidget {
  const AuthBloodDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AuthTokens.inputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuthTokens.borderStrong),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        iconEnabledColor: AuthTokens.textMuted,
        dropdownColor: Colors.white,
        items: items
            .map(
              (g) => DropdownMenuItem(
                value: g,
                child: Text(
                  g,
                  style: const TextStyle(
                    color: AuthTokens.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}