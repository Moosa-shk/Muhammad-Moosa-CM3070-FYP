// lib/widgets/custom_button.dart

import 'package:flutter/material.dart';

import '../config/colors.dart';
import 'text_widget.dart';

typedef AsyncVoidCallback = Future<void> Function();

/// Reusable application button.
///
/// Same existing API:
/// - title
/// - onTap
/// - filled
/// - loading
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.filled = true,
    this.loading = false,
  });

  final String title;

  final AsyncVoidCallback? onTap;

  final bool filled;

  final bool loading;

  @override
  State<CustomButton> createState() =>
      _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();

    _press = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 120,
      ),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.onTap == null || widget.loading;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: disabled
          ? null
          : (_) {
              _press.forward();
            },

      onTapCancel: disabled
          ? null
          : () {
              _press.reverse();
            },

      onTapUp: disabled
          ? null
          : (_) {
              _press.reverse();
            },

      onTap: disabled
          ? null
          : () async {
              await widget.onTap!.call();
            },

      child: AnimatedBuilder(
        animation: _press,

        builder: (_, child) {
          final scale =
              1 - (_press.value * 0.025);

          return Transform.scale(
            scale: scale,
            child: child,
          );
        },

        child: AnimatedOpacity(
          duration: const Duration(
            milliseconds: 140,
          ),

          opacity: disabled ? 0.55 : 1,

          child: Container(
            width: double.infinity,
            height: 56,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: widget.filled
                  ? AppColor.primary
                  : AppColor.surface,

              borderRadius: BorderRadius.circular(
                16,
              ),

              border: Border.all(
                color: widget.filled
                    ? AppColor.primary
                    : AppColor.borderStrong,
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: widget.filled
                      ? AppColor.primary.withOpacity(
                          0.18,
                        )
                      : AppColor.shadow,
                  blurRadius: widget.filled
                      ? 18
                      : 12,
                  offset: const Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),

            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.4,

                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        widget.filled
                            ? Colors.white
                            : AppColor.primary,
                      ),
                    ),
                  )
                : TextWidget(
                    widget.title,

                    color: widget.filled
                        ? Colors.white
                        : AppColor.primary,

                    weight:
                        FontWeight.w800,
                  ),
          ),
        ),
      ),
    );
  }
}