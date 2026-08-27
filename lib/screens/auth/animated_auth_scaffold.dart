// lib/screens/auth/animated_auth_scaffold.dart

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/screens/auth/auth_ui.dart';

class AnimatedAuthScaffold extends StatefulWidget {
  const AnimatedAuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.scroll = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  final bool showBack;
  final VoidCallback? onBack;

  final EdgeInsets padding;
  final bool scroll;

  @override
  State<AnimatedAuthScaffold> createState() =>
      _AnimatedAuthScaffoldState();
}

class _AnimatedAuthScaffoldState extends State<AnimatedAuthScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final AnimationController _enterCtrl;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..forward();

    _fade = CurvedAnimation(
      parent: _enterCtrl,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: widget.padding,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: AuthTokens.text,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // =================================================
                  // TOP BAR
                  // =================================================

                  if (widget.showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _BackButton(
                        onBack: widget.onBack,
                      ),
                    ),

                  if (widget.title != null)
                    SizedBox(
                      height: widget.showBack ? 18 : 10,
                    ),

                  // =================================================
                  // CENTERED AUTH HEADER
                  // =================================================

                  if (widget.title != null)
                    _AuthHeader(
                      title: widget.title!,
                      subtitle: widget.subtitle,
                    ),

                  if (widget.title != null)
                    const SizedBox(height: 26),

                  // =================================================
                  // CONTENT
                  // =================================================

                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: Stack(
        children: [
          // =======================================================
          // BASE BACKGROUND
          // =======================================================

          const Positioned.fill(
            child: ColoredBox(
              color: AppColor.bg,
            ),
          ),

          // =======================================================
          // VERY SUBTLE AMBIENT LIGHT
          // =======================================================

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambientCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _AuthAmbientPainter(
                      t: _ambientCtrl.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // =======================================================
          // SOFT TOP WASH
          // =======================================================

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.52),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =======================================================
          // CONTENT
          // =======================================================

          if (widget.scroll)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: content,
            )
          else
            content,
        ],
      ),
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // -------------------------------------------------------
          // SMALL BRAND MARK
          // -------------------------------------------------------

          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------
          // TITLE
          // -------------------------------------------------------

          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AuthTokens.text,
                  fontSize: 28,
                  height: 1.15,
                  letterSpacing: -0.7,
                  fontWeight: FontWeight.w900,
                ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AuthTokens.textMuted,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// BACK BUTTON
// =================================================================

class _BackButton extends StatefulWidget {
  const _BackButton({
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTap: widget.onBack ??
          () {
            Navigator.of(context).maybePop();
          },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(
          milliseconds: 110,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadow,
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: AppColor.secondary,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// BACKGROUND PAINTER
// =================================================================

class _AuthAmbientPainter extends CustomPainter {
  _AuthAmbientPainter({
    required this.t,
  });

  final double t;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final short = size.shortestSide;

    double wave(
      double start,
      double end,
      double phase,
    ) {
      final p =
          (sin((t * pi * 2) + phase) + 1) / 2;

      return start + ((end - start) * p);
    }

    // =============================================================
    // PRIMARY LIGHT - TOP LEFT
    // =============================================================

    final primaryCenter = Offset(
      size.width * wave(0.08, 0.22, 0),
      size.height * wave(0.04, 0.12, 0.4),
    );

    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.primary.withOpacity(0.10),
          AppColor.primary.withOpacity(0.025),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: primaryCenter,
          radius: short * 0.62,
        ),
      );

    canvas.drawCircle(
      primaryCenter,
      short * 0.62,
      primaryPaint,
    );

    // =============================================================
    // COOL LIGHT - RIGHT SIDE
    // =============================================================

    final secondaryCenter = Offset(
      size.width * wave(0.78, 0.94, 1.3),
      size.height * wave(0.22, 0.34, 0.7),
    );

    final secondaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.info.withOpacity(0.07),
          AppColor.info.withOpacity(0.018),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: secondaryCenter,
          radius: short * 0.58,
        ),
      );

    canvas.drawCircle(
      secondaryCenter,
      short * 0.58,
      secondaryPaint,
    );

    // =============================================================
    // BOTTOM BALANCE LIGHT
    // =============================================================

    final bottomCenter = Offset(
      size.width * 0.48,
      size.height * wave(0.80, 0.92, 2.0),
    );

    final bottomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.safeGreen.withOpacity(0.045),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: bottomCenter,
          radius: short * 0.72,
        ),
      );

    canvas.drawCircle(
      bottomCenter,
      short * 0.72,
      bottomPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AuthAmbientPainter oldDelegate,
  ) {
    return oldDelegate.t != t;
  }
}