// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';

import '../config/colors.dart';

/// Main reusable screen shell.
///
/// Public API is unchanged.
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 24),
    this.scroll = false,
    this.appBarActions,
    this.bottomNavigationBar,
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

  final FloatingActionButtonLocation?
      floatingActionButtonLocation;

  @override
  State<AppScaffold> createState() =>
      _AppScaffoldState();
}

class _AppScaffoldState
    extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  late final Animation<double> _fade;

  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _enter = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 460),
    )..forward();

    _fade = CurvedAnimation(
      parent: _enter,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(
        0,
        0.025,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enter,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SafeArea(
      child: Padding(
        padding: widget.padding,

        child: SlideTransition(
          position: _slide,

          child: FadeTransition(
            opacity: _fade,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 10),

                // =================================================
                // TOP ACTION ROW
                // =================================================

                if (widget.showBack ||
                    (widget.appBarActions
                            ?.isNotEmpty ??
                        false))
                  Row(
                    children: [
                      if (widget.showBack)
                        _BackButton(
                          onBack:
                              widget.onBack,
                        ),

                      const Spacer(),

                      if (widget
                              .appBarActions !=
                          null)
                        ...widget
                            .appBarActions!,
                    ],
                  ),

                if (widget.title != null)
                  SizedBox(
                    height:
                        widget.showBack
                            ? 20
                            : 12,
                  ),

                // =================================================
                // HEADER
                // =================================================

                if (widget.title != null)
                  _Header(
                    title:
                        widget.title!,
                    subtitle:
                        widget.subtitle,
                  ),

                if (widget.title != null)
                  const SizedBox(
                    height: 22,
                  ),

                // =================================================
                // BODY
                // =================================================

                if (widget.scroll)
                  widget.child
                else
                  Expanded(
                    child:
                        widget.child,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.bg,

      bottomNavigationBar:
          widget.bottomNavigationBar,

      floatingActionButton:
          widget.floatingActionButton,

      floatingActionButtonLocation:
          widget
                  .floatingActionButtonLocation ??
              FloatingActionButtonLocation
                  .endFloat,

      body: Stack(
        children: [
          // =======================================================
          // CLEAN LIGHT BACKGROUND
          // =======================================================

          const Positioned.fill(
            child: ColoredBox(
              color: AppColor.bg,
            ),
          ),

          // =======================================================
          // VERY SUBTLE TOP SHADE
          // =======================================================

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,

                    colors: [
                      AppColor
                          .primarySoft
                          .withOpacity(
                        0.45,
                      ),

                      AppColor.bg
                          .withOpacity(
                        0.18,
                      ),

                      AppColor.bg,
                    ],

                    stops: const [
                      0,
                      0.24,
                      0.52,
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
              physics:
                  const BouncingScrollPhysics(),

              child: bodyContent,
            )
          else
            bodyContent,
        ],
      ),
    );
  }
}

/// ===============================================================
/// HEADER
/// ===============================================================
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.subtitle,
  });

  final String title;

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontSize: 28,
                height: 1.1,
                color: AppColor.text,
                fontWeight:
                    FontWeight.w800,
                letterSpacing:
                    -0.75,
              ),
        ),

        const SizedBox(height: 10),

        // =========================================================
        // BRAND INDICATOR
        // =========================================================

        Row(
          children: [
            Container(
              width: 34,
              height: 4,

              decoration:
                  BoxDecoration(
                color:
                    AppColor.primary,

                borderRadius:
                    BorderRadius
                        .circular(
                  99,
                ),
              ),
            ),

            const SizedBox(
              width: 5,
            ),

            Container(
              width: 8,
              height: 4,

              decoration:
                  BoxDecoration(
                color: AppColor
                    .borderStrong,

                borderRadius:
                    BorderRadius
                        .circular(
                  99,
                ),
              ),
            ),
          ],
        ),

        if (subtitle != null)
          const SizedBox(
            height: 10,
          ),

        if (subtitle != null)
          Text(
            subtitle!,

            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColor.textMuted,

                  fontSize: 14,

                  fontWeight:
                      FontWeight.w500,

                  height: 1.45,
                ),
          ),
      ],
    );
  }
}

/// ===============================================================
/// BACK BUTTON
/// ===============================================================
class _BackButton extends StatefulWidget {
  const _BackButton({
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState
    extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(
          () => _pressed = true,
        );
      },

      onTapCancel: () {
        setState(
          () => _pressed = false,
        );
      },

      onTapUp: (_) {
        setState(
          () => _pressed = false,
        );
      },

      onTap: widget.onBack ??
          () {
            Navigator.of(context)
                .maybePop();
          },

      child: AnimatedScale(
        scale:
            _pressed ? 0.95 : 1,

        duration:
            const Duration(
          milliseconds: 120,
        ),

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 130,
          ),

          width: 46,
          height: 46,

          decoration:
              BoxDecoration(
            color: _pressed
                ? AppColor.primarySoft
                : AppColor.surface,

            borderRadius:
                BorderRadius.circular(
              15,
            ),

            border: Border.all(
              color:
                  AppColor.border,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    AppColor.shadow,

                blurRadius: 14,

                offset:
                    const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),

          child: const Icon(
            Icons.arrow_back_rounded,

            color:
                AppColor.secondary,

            size: 21,
          ),
        ),
      ),
    );
  }
}