// lib/widgets/app_scaffold.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/colors.dart';

/// AppScaffold is a reusable layout widget used across the application.
/// It provides a consistent screen structure including:
/// - animated background
/// - optional page title and subtitle
/// - back navigation button
/// - scroll support
/// - bottom navigation bar
/// - floating action button support
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.scroll = false,
    this.appBarActions,
    this.bottomNavigationBar,

    // Floating widgets such as chatbot button
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final EdgeInsets padding;
  final bool scroll;
  final List<Widget>? appBarActions;
  final Widget? bottomNavigationBar;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

/// Handles screen animations and background effects
class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {

  late final AnimationController _bgCtrl;
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    /// Background animation controller
    /// used for moving abstract shapes
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    /// Entry animation controller
    /// used when screen first appears
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fade = CurvedAnimation(
      parent: _enterCtrl,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
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
    _bgCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// Main content layout
    final content = SafeArea(
      child: Padding(
        padding: widget.padding,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                /// Top row with optional back button and actions
                Row(
                  children: [
                    if (widget.showBack)
                      _BackButton(onBack: widget.onBack),

                    const Spacer(),

                    if (widget.appBarActions != null)
                      ...widget.appBarActions!,
                  ],
                ),

                if (widget.title != null)
                  const SizedBox(height: 14),

                /// Page title and subtitle
                if (widget.title != null)
                  _Header(
                    title: widget.title!,
                    subtitle: widget.subtitle,
                  ),

                if (widget.title != null)
                  const SizedBox(height: 18),

                /// Main page content
                if (widget.scroll)
                  widget.child
                else
                  Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bg,

      /// Bottom navigation bar
      bottomNavigationBar: widget.bottomNavigationBar,

      /// Floating widgets such as chatbot button
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          widget.floatingActionButtonLocation ??
          FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [

          /// Animated abstract background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => _Bg(t: _bgCtrl.value),
          ),

          /// Soft white overlay gradient
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

          /// Scrollable or fixed content
          if (widget.scroll)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: content,
            )
          else
            content,
        ],
      ),
    );
  }
}

/// Header widget used for page titles
class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),

        const SizedBox(height: 8),

        /// Decorative underline
        Container(
          height: 4,
          width: 42,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.55),
            borderRadius: BorderRadius.circular(99),
          ),
        ),

        if (subtitle != null)
          const SizedBox(height: 10),

        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

/// Custom back button used across screens
class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});

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
          border: Border.all(color: AppColor.border),

          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.10),
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Icon(
          Icons.arrow_back_rounded,
          color: AppColor.primary,
        ),
      ),
    );
  }
}

/// Background widget responsible for animated shapes
class _Bg extends StatelessWidget {
  const _Bg({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    /// Creates smooth animated movement
    double wobble(double a, double b) =>
        a + (b - a) * (0.5 + 0.5 * sin(t * pi));

    final p1 = Offset(w * wobble(0.12, 0.30), h * wobble(0.10, 0.20));
    final p2 = Offset(w * wobble(0.82, 0.64), h * wobble(0.24, 0.12));
    final p3 = Offset(w * wobble(0.50, 0.72), h * wobble(0.90, 0.72));

    final c2 = Color.lerp(
      AppColor.primary,
      Colors.white,
      0.55,
    ) ?? AppColor.primary;

    return Stack(
      children: [
        Container(color: AppColor.bg),

        /// Custom painted shapes
        Positioned.fill(
          child: CustomPaint(
            painter: _BlobPainter(
              p1: p1,
              p2: p2,
              p3: p3,
              c1: AppColor.primary.withOpacity(0.22),
              c2: c2.withOpacity(0.16),
            ),
          ),
        ),

        /// Blur effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: Container(color: Colors.transparent),
          ),
        ),

        /// Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter used to draw animated background blobs
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
      ).createShader(
        Rect.fromCircle(center: p1, radius: r * 0.65),
      );

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [c2, Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: p2, radius: r * 0.70),
      );

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [c1.withOpacity(0.12), Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: p3, radius: r * 0.85),
      );

    canvas.drawRect(Offset.zero & size, paint3);
    canvas.drawRect(Offset.zero & size, paint2);
    canvas.drawRect(Offset.zero & size, paint1);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) =>
      old.p1 != p1 || old.p2 != p2 || old.p3 != p3;
}