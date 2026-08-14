import 'package:flutter/material.dart';
import '../config/colors.dart';
import 'text_widget.dart';

/// A typedef for asynchronous button callbacks.
/// It allows the button to execute async operations such as
/// API calls, database updates, or navigation.
typedef AsyncVoidCallback = Future<void> Function();

/// CustomButton is a reusable button widget used throughout the application.
/// It supports loading state, filled or outlined styles, and a small press
/// animation to improve user interaction feedback.
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.filled = true,
    this.loading = false,
  });

  /// Text displayed inside the button
  final String title;

  /// Async callback executed when the button is pressed
  final AsyncVoidCallback? onTap;

  /// Determines whether the button appears filled or outlined
  final bool filled;

  /// Indicates if the button should show a loading indicator
  final bool loading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {

  /// Animation controller used to create the press scale effect
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();

    /// Initialize animation controller for press feedback
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void dispose() {

    /// Dispose animation controller to prevent memory leaks
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// Button is disabled when there is no callback
    /// or when loading is active
    final disabled = widget.onTap == null || widget.loading;

    return GestureDetector(

      /// Trigger press animation when finger touches button
      onTapDown: disabled ? null : (_) => _press.forward(),

      /// Reverse animation if gesture is cancelled
      onTapCancel: disabled ? null : () => _press.reverse(),

      /// Reverse animation after tap
      onTapUp: disabled ? null : (_) => _press.reverse(),

      /// Execute async callback when tapped
      onTap: disabled ? null : () async => await widget.onTap!.call(),

      child: AnimatedBuilder(
        animation: _press,
        builder: (_, __) {

          /// Calculate small scale effect during press
          final s = 1 - (_press.value * 0.02);

          return Transform.scale(
            scale: s,

            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),

              /// Reduce opacity when disabled
              opacity: disabled ? 0.72 : 1,

              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,

                /// Button styling
                decoration: BoxDecoration(
                  color: widget.filled ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),

                  /// Border appears only for outline style
                  border: Border.all(
                    color: widget.filled ? Colors.transparent : AppColor.primary,
                    width: 1.6,
                  ),

                  /// Shadow effect applied only for filled buttons
                  boxShadow: widget.filled
                      ? [
                          BoxShadow(
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                            color: AppColor.primary.withOpacity(0.22),
                          ),
                          BoxShadow(
                            blurRadius: 26,
                            offset: const Offset(0, 16),
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ]
                      : [],
                ),

                /// Display loading indicator if action is in progress
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

                    /// Otherwise display button text
                    : TextWidget(
                        widget.title,
                        color: widget.filled ? Colors.white : AppColor.primary,
                        weight: FontWeight.w900,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}