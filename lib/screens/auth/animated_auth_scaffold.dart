import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:disaster_app_ui/config/colors.dart';
import 'package:disaster_app_ui/screens/auth/auth_ui.dart';


/// Scaffold used for authentication screens.
/// Provides animated background, header layout and optional scrolling.
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
  State<AnimatedAuthScaffold> createState() => _AnimatedAuthScaffoldState();
}

class _AnimatedAuthScaffoldState extends State<AnimatedAuthScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _enterCtrl;

  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();

    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat(reverse: true);

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();

    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);

    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColor.bg;
    final primary = AppColor.primary;

    final body = SafeArea(
      child: Padding(
        padding: widget.padding,
        child: SlideTransition(
          position: _enterSlide,
          child: FadeTransition(
            opacity: _enterFade,
            child: DefaultTextStyle(
              style: const TextStyle(color: AuthTokens.text),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showBack) const SizedBox(height: 8),
                  if (widget.showBack)
                    _BackButton(primary: primary, onBack: widget.onBack),
                  if (widget.title != null) const SizedBox(height: 14),
                  if (widget.title != null)
                    _Header(title: widget.title!, subtitle: widget.subtitle),
                  if (widget.title != null) const SizedBox(height: 18),
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => _AnimatedBlobs(
              t: _bgCtrl.value,
              bg: bg,
              primary: primary,
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withOpacity(0.82),
                      Colors.white.withOpacity(0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (widget.scroll)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: body,
            )
          else
            body,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.primary, required this.onBack});

  final Color primary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onBack ?? () => Navigator.of(context).maybePop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AuthTokens.border),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.10),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, color: primary),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AuthTokens.text,
          letterSpacing: 0.2,
        );

    final subStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AuthTokens.textMuted,
          fontWeight: FontWeight.w600,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 42,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.55),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        if (subtitle != null) const SizedBox(height: 10),
        if (subtitle != null) Text(subtitle!, style: subStyle),
      ],
    );
  }
}

class _AnimatedBlobs extends StatelessWidget {
  const _AnimatedBlobs({
    required this.t,
    required this.bg,
    required this.primary,
  });

  final double t;
  final Color bg;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    double wobble(double a, double b) =>
        a + (b - a) * (0.5 + 0.5 * sin(t * pi));

    final p1 = Offset(w * wobble(0.12, 0.30), h * wobble(0.10, 0.20));
    final p2 = Offset(w * wobble(0.82, 0.64), h * wobble(0.24, 0.12));
    final p3 = Offset(w * wobble(0.50, 0.72), h * wobble(0.90, 0.72));

    final c2 = Color.lerp(primary, Colors.white, 0.55) ?? primary;

    return Stack(
      children: [
        Container(color: bg),
        Positioned.fill(
          child: CustomPaint(
            painter: _BlobPainter(
              p1: p1,
              p2: p2,
              p3: p3,
              c1: primary.withOpacity(0.22),
              c2: c2.withOpacity(0.16),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.c1,
    required this.c2,
  });

  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Color c1;
  final Color c2;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide;

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [c1, Colors.transparent],
      ).createShader(Rect.fromCircle(center: p1, radius: r * 0.65));

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [c2, Colors.transparent],
      ).createShader(Rect.fromCircle(center: p2, radius: r * 0.70));

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [c1.withOpacity(0.12), Colors.transparent],
      ).createShader(Rect.fromCircle(center: p3, radius: r * 0.85));

    canvas.drawRect(Offset.zero & size, paint3);
    canvas.drawRect(Offset.zero & size, paint2);
    canvas.drawRect(Offset.zero & size, paint1);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.p1 != p1 ||
        oldDelegate.p2 != p2 ||
        oldDelegate.p3 != p3;
  }
}