// lib/screens/auth/splash_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/colors.dart';
import '../dashboard/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ===============================================================
  // ANIMATION CONTROLLERS
  // ===============================================================

  late final AnimationController _introCtrl;
  late final AnimationController _ambientCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  late final Animation<double> _footerFade;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------
    // INTRO ANIMATION
    // -------------------------------------------------------------

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1450,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(
        0.00,
        0.42,
        curve: Curves.easeOut,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(
          0.00,
          0.55,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(
        0.30,
        0.68,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.28,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(
          0.30,
          0.72,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(
        0.48,
        0.82,
        curve: Curves.easeOut,
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.30,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(
          0.48,
          0.86,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _footerFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(
        0.68,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    // -------------------------------------------------------------
    // AMBIENT / CONTINUOUS ANIMATION
    // -------------------------------------------------------------

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3600,
      ),
    )..repeat();

    _introCtrl.forward();

    // -------------------------------------------------------------
    // AUTH CHECK
    // PRESERVED
    // -------------------------------------------------------------

    _checkAuth();
  }

  // ===============================================================
  // AUTH CHECK
  // EXISTING LOGIC PRESERVED
  // ===============================================================

  Future<void> _checkAuth() async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) {
      return;
    }

    if (user == null) {
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(
          milliseconds: 420,
        ),
      );
    } else {
      Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(
          milliseconds: 420,
        ),
      );
    }
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _introCtrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
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
          // AMBIENT BACKGROUND
          // =======================================================

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (_, __) {
                return CustomPaint(
                  painter: _SplashAmbientPainter(
                    t: _ambientCtrl.value,
                  ),
                );
              },
            ),
          ),

          // =======================================================
          // TOP SOFT GRADIENT
          // =======================================================

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(
                        0.82,
                      ),
                      Colors.white.withOpacity(
                        0.38,
                      ),
                      Colors.transparent,
                      AppColor.primarySoft.withOpacity(
                        0.12,
                      ),
                    ],
                    stops: const [
                      0,
                      0.25,
                      0.62,
                      1,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =======================================================
          // DECORATIVE PARTICLES
          // =======================================================

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambientCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      t: _ambientCtrl.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // =======================================================
          // MAIN CONTENT
          // =======================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: Column(
                children: [
                  const Spacer(
                    flex: 4,
                  ),

                  // =================================================
                  // LOGO / RADAR
                  // =================================================

                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _animatedLogo(),
                    ),
                  ),

                  const SizedBox(
                    height: 34,
                  ),

                  // =================================================
                  // APP NAME
                  // =================================================

                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const Text(
                        "RescueAid",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.text,
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  // =================================================
                  // TAGLINE
                  // =================================================

                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: const Text(
                        "Prepared. Aware. Protected.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(
                    flex: 4,
                  ),

                  // =================================================
                  // BOTTOM STATUS
                  // =================================================

                  FadeTransition(
                    opacity: _footerFade,
                    child: _bottomStatus(),
                  ),

                  const SizedBox(
                    height: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ANIMATED LOGO
  // ===============================================================

  Widget _animatedLogo() {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        final t = _ambientCtrl.value;

        final pulse =
            1 +
            ((sin(t * pi * 2) + 1) / 2) *
                0.025;

        return SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // -----------------------------------------------------
              // OUTER RADAR RING
              // -----------------------------------------------------

              _RadarRing(
                progress: t,
                size: 182,
                opacity: 0.08,
              ),

              // -----------------------------------------------------
              // SECOND RADAR RING
              // -----------------------------------------------------

              _RadarRing(
                progress: (t + 0.34) % 1,
                size: 158,
                opacity: 0.11,
              ),

              // -----------------------------------------------------
              // STATIC SOFT RING
              // -----------------------------------------------------

              Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primary.withOpacity(
                    0.035,
                  ),
                  border: Border.all(
                    color: AppColor.primary.withOpacity(
                      0.09,
                    ),
                  ),
                ),
              ),

              // -----------------------------------------------------
              // INNER SOFT BACKGROUND
              // -----------------------------------------------------

              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primarySoft.withOpacity(
                    0.90,
                  ),
                ),
              ),

              // -----------------------------------------------------
              // LOGO CARD
              // -----------------------------------------------------

              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                    border: Border.all(
                      color: AppColor.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(
                          0.10,
                        ),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(
                          0,
                          12,
                        ),
                      ),
                      BoxShadow(
                        color: AppColor.shadow,
                        blurRadius: 18,
                        offset: const Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // -----------------------------------------------------
              // LIVE STATUS DOT
              // -----------------------------------------------------

              Positioned(
                right: 47,
                bottom: 49,
                child: _LivePulseDot(
                  progress: t,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================================================
  // BOTTOM STATUS
  // ===============================================================

  Widget _bottomStatus() {
    return Column(
      children: [
        // ---------------------------------------------------------
        // LOADING DOTS
        // ---------------------------------------------------------

        AnimatedBuilder(
          animation: _ambientCtrl,
          builder: (_, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) {
                  final phase =
                      (_ambientCtrl.value +
                              (index * 0.16)) %
                          1.0;

                  final wave =
                      (sin(
                                phase *
                                    pi *
                                    2,
                              ) +
                              1) /
                          2;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 100,
                    ),
                    width: index == 1
                        ? 18
                        : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(
                        0.30 + (wave * 0.70),
                      ),
                      borderRadius: BorderRadius.circular(
                        99,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(
          height: 13,
        ),

        const Text(
          "Preparing your safety hub",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.05,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        const Text(
          "Stay ready. Stay safe.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// RADAR RING
// =================================================================

class _RadarRing extends StatelessWidget {
  const _RadarRing({
    required this.progress,
    required this.size,
    required this.opacity,
  });

  final double progress;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final scale =
        0.76 +
        (progress * 0.24);

    final ringOpacity =
        (1 - progress).clamp(
          0.0,
          1.0,
        ) *
        opacity;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.primary.withOpacity(
              ringOpacity,
            ),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// LIVE PULSE DOT
// =================================================================

class _LivePulseDot extends StatelessWidget {
  const _LivePulseDot({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pulse =
        (sin(progress * pi * 2) + 1) /
            2;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 22 + (pulse * 7),
          height: 22 + (pulse * 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.safeGreen.withOpacity(
              0.08 + (pulse * 0.04),
            ),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColor.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.safeGreen.withOpacity(
                  0.16,
                ),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColor.safeGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// AMBIENT BACKGROUND PAINTER
// =================================================================

class _SplashAmbientPainter extends CustomPainter {
  _SplashAmbientPainter({
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
      final value =
          (sin(
                    (t * pi * 2) +
                        phase,
                  ) +
                  1) /
              2;

      return start +
          ((end - start) * value);
    }

    // -------------------------------------------------------------
    // PRIMARY AMBIENT LIGHT
    // -------------------------------------------------------------

    final primaryCenter = Offset(
      size.width *
          wave(
            0.08,
            0.26,
            0,
          ),
      size.height *
          wave(
            0.08,
            0.18,
            0.5,
          ),
    );

    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.primary.withOpacity(
            0.075,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: primaryCenter,
          radius: short * 0.76,
        ),
      );

    canvas.drawCircle(
      primaryCenter,
      short * 0.76,
      primaryPaint,
    );

    // -------------------------------------------------------------
    // COOL AMBIENT LIGHT
    // -------------------------------------------------------------

    final coolCenter = Offset(
      size.width *
          wave(
            0.76,
            0.94,
            1.3,
          ),
      size.height *
          wave(
            0.42,
            0.60,
            0.8,
          ),
    );

    final coolPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.info.withOpacity(
            0.045,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: coolCenter,
          radius: short * 0.66,
        ),
      );

    canvas.drawCircle(
      coolCenter,
      short * 0.66,
      coolPaint,
    );

    // -------------------------------------------------------------
    // LOWER SAFE-GREEN AMBIENT LIGHT
    // -------------------------------------------------------------

    final safeCenter = Offset(
      size.width * 0.18,
      size.height *
          wave(
            0.76,
            0.88,
            2.1,
          ),
    );

    final safePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.safeGreen.withOpacity(
            0.025,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: safeCenter,
          radius: short * 0.52,
        ),
      );

    canvas.drawCircle(
      safeCenter,
      short * 0.52,
      safePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _SplashAmbientPainter oldDelegate,
  ) {
    return oldDelegate.t != t;
  }
}

// =================================================================
// PARTICLE PAINTER
// =================================================================

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.t,
  });

  final double t;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final particles = <_Particle>[
      const _Particle(
        0.12,
        0.24,
        2.0,
        0.0,
      ),
      const _Particle(
        0.83,
        0.18,
        1.6,
        1.2,
      ),
      const _Particle(
        0.91,
        0.62,
        2.1,
        2.4,
      ),
      const _Particle(
        0.09,
        0.69,
        1.5,
        3.0,
      ),
      const _Particle(
        0.76,
        0.82,
        1.8,
        4.1,
      ),
      const _Particle(
        0.23,
        0.88,
        1.4,
        5.0,
      ),
    ];

    for (final particle in particles) {
      final movement = sin(
            (t * pi * 2) +
                particle.phase,
          ) *
          7;

      final opacity =
          0.08 +
          (((sin(
                            (t * pi * 2) +
                                particle.phase,
                          ) +
                          1) /
                      2) *
                  0.10);

      paint.color = AppColor.primary.withOpacity(
        opacity,
      );

      canvas.drawCircle(
        Offset(
          size.width * particle.x,
          (size.height * particle.y) +
              movement,
        ),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ParticlePainter oldDelegate,
  ) {
    return oldDelegate.t != t;
  }
}

// =================================================================
// PARTICLE MODEL
// =================================================================

class _Particle {
  const _Particle(
    this.x,
    this.y,
    this.radius,
    this.phase,
  );

  final double x;
  final double y;
  final double radius;
  final double phase;
}