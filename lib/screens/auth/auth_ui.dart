// lib/screens/auth/auth_ui.dart

import 'package:disaster_app_ui/config/colors.dart';
import 'package:flutter/material.dart';

// =================================================================
// AUTH TOKENS
// =================================================================

class AuthTokens {
  static const bool isLight = true;

  static const Color text = AppColor.text;
  static const Color textMuted = AppColor.textMuted;

  static const Color cardFill = AppColor.surface;
  static const Color inputFill = AppColor.inputFill;

  static const Color border = AppColor.border;
  static const Color borderStrong = AppColor.borderStrong;

  static Color shadow = AppColor.shadow;
  static Color hint = AppColor.textMuted.withOpacity(0.72);
}

// =================================================================
// AUTH CARD
// =================================================================

class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: padding ??
          const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            20,
          ),

      decoration: BoxDecoration(
        color: AppColor.surface,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: AppColor.border,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: child,
    );
  }
}

// =================================================================
// AUTH FIELD
// =================================================================

class AuthField extends StatefulWidget {
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
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscure;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _obscure = widget.obscureText;

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),

      decoration: BoxDecoration(
        color: AppColor.surface,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(
          color: focused
              ? AppColor.primary.withOpacity(0.55)
              : AppColor.borderStrong,
          width: focused ? 1.4 : 1,
        ),

        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),

      child: TextField(
        controller: widget.controller,

        focusNode: _focusNode,

        keyboardType: widget.keyboardType,

        obscureText: _obscure,

        textInputAction: widget.textInputAction,

        onSubmitted: widget.onSubmitted,

        cursorColor: AppColor.primary,

        style: const TextStyle(
          color: AppColor.text,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),

        decoration: InputDecoration(
          labelText: widget.label,

          labelStyle: TextStyle(
            color: focused
                ? AppColor.primary
                : AppColor.textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),

          floatingLabelStyle: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.w800,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.all(11),

            child: Container(
              width: 36,
              height: 36,

              decoration: BoxDecoration(
                color: focused
                    ? AppColor.primarySoft
                    : AppColor.inputFill,

                borderRadius: BorderRadius.circular(11),
              ),

              child: Icon(
                widget.icon,
                size: 19,
                color: focused
                    ? AppColor.primary
                    : AppColor.textMuted,
              ),
            ),
          ),

          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },

                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,

                    color: AppColor.textMuted,

                    size: 20,
                  ),
                )
              : null,

          filled: true,

          fillColor: Colors.transparent,

          border: InputBorder.none,

          enabledBorder: InputBorder.none,

          focusedBorder: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// PRIMARY AUTH BUTTON
// =================================================================

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
  State<AuthPrimaryButton> createState() =>
      _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState
    extends State<AuthPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.onTap == null || widget.loading;

    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              setState(() {
                _pressed = true;
              });
            },

      onTapCancel: disabled
          ? null
          : () {
              setState(() {
                _pressed = false;
              });
            },

      onTapUp: disabled
          ? null
          : (_) {
              setState(() {
                _pressed = false;
              });
            },

      onTap: disabled ? null : widget.onTap,

      child: AnimatedScale(
        duration: const Duration(
          milliseconds: 110,
        ),

        scale: _pressed ? 0.975 : 1,

        child: AnimatedOpacity(
          duration: const Duration(
            milliseconds: 140,
          ),

          opacity: disabled ? 0.58 : 1,

          child: Container(
            width: double.infinity,
            height: 56,

            decoration: BoxDecoration(
              color: AppColor.secondary,

              borderRadius: BorderRadius.circular(17),

              boxShadow: disabled
                  ? []
                  : [
                      BoxShadow(
                        color:
                            AppColor.secondary.withOpacity(
                          0.16,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),

            child: Stack(
              alignment: Alignment.center,
              children: [
                // -------------------------------------------------
                // SMALL PRIMARY ACCENT
                // -------------------------------------------------

                Positioned(
                  left: 7,
                  top: 7,
                  bottom: 7,

                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),

                    width: _pressed ? 5 : 7,

                    decoration: BoxDecoration(
                      color: AppColor.primary,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                // -------------------------------------------------
                // CONTENT
                // -------------------------------------------------

                if (widget.loading)
                  const SizedBox(
                    width: 22,
                    height: 22,

                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,

                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Text(
                        widget.title,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.15,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Container(
                        width: 27,
                        height: 27,

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.10),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// BLOOD GROUP SELECTOR
// =================================================================

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
    const items = [
      "A+",
      "A-",
      "B+",
      "B-",
      "O+",
      "O-",
      "AB+",
      "AB-",
    ];

    return Container(
      width: double.infinity,

      height: 58,

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),

      decoration: BoxDecoration(
        color: AppColor.surface,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(
          color: AppColor.borderStrong,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: AppColor.dangerSoft,

              borderRadius: BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.bloodtype_outlined,
              size: 19,
              color: AppColor.danger,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,

                isExpanded: true,

                dropdownColor: AppColor.surface,

                borderRadius: BorderRadius.circular(16),

                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColor.textMuted,
                ),

                style: const TextStyle(
                  color: AppColor.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),

                items: items
                    .map(
                      (group) => DropdownMenuItem<String>(
                        value: group,

                        child: Row(
                          children: [
                            Text(
                              group,
                              style: const TextStyle(
                                color: AppColor.text,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (selected) {
                  if (selected != null) {
                    onChanged(selected);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}