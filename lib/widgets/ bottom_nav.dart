import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';

// Screens
import 'package:disaster_app_ui/screens/alerts/alerts_screen.dart';
import 'package:disaster_app_ui/screens/dashboard/home_screen.dart';
import 'package:disaster_app_ui/screens/maps/map_screen.dart';
import 'package:disaster_app_ui/screens/quiz/quiz_list_screen.dart';
import 'package:disaster_app_ui/screens/settingss/settings_screen.dart';

/// This widget implements the main bottom navigation bar
/// used across the application. It allows users to quickly
/// navigate between the main modules such as Home, Map,
/// Alerts, Quiz, and Settings.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

  /// Handles navigation when a navigation item is tapped.
  /// GetX navigation is used to replace the current screen.
  void _navigate(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.offAll(() => const HomeScreen());
        break;
      case 1:
        Get.offAll(() => const MapsScreen());
        break;
      case 2:
        Get.offAll(() => const AlertScreen());
        break;
      case 3:
        Get.offAll(() => const QuizListScreen());
        break;
      case 4:
        Get.offAll(() => const SettingsScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Icons used in the navigation bar
    final icons = <IconData>[
      Icons.home_rounded,
      Icons.map_rounded,
      Icons.notifications_rounded,
      Icons.quiz_rounded,
      Icons.settings_rounded,
    ];

    /// Labels shown with the icons
    final labels = <String>["Home", "Map", "Alerts", "Quiz", "Settings"];

    /// Helps adjust the navbar position for devices
    /// that have bottom safe area padding.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 0, 18, 18 + (bottomInset > 0 ? 2 : 0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),

          /// Backdrop blur effect to create a glass-like appearance
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              /// Main container styling of the navbar
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.86),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              /// LayoutBuilder helps adjust the layout
              /// for smaller screen sizes.
              child: LayoutBuilder(
                builder: (context, c) {

                  /// If device width is small, label text may scale down
                  final isTight = c.maxWidth < 360;

                  return Row(
                    children: List.generate(icons.length, (index) {

                      final isActive = currentIndex == index;

                      /// Active tab gets more space so label can appear
                      final flex = isActive ? 3 : 1;

                      return Expanded(
                        flex: flex,
                        child: _NavPill(
                          icon: icons[index],
                          label: labels[index],
                          active: isActive,
                          tight: isTight,
                          onTap: () => _navigate(index),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation button widget
/// used inside the BottomNavBar.
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.tight,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool tight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,

      /// Animated container used to smoothly
      /// transition between active and inactive states
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 0,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.92) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),

          /// Shadow applied when item is active
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),

        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Icon container
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: active
                      ? AppColor.primary.withOpacity(0.12)
                      : Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: active
                      ? AppColor.primary
                      : Colors.white.withOpacity(0.95),
                ),
              ),

              /// Label appears only for active item
              if (active) ...[
                const SizedBox(width: 10),

                /// FittedBox ensures text scales down
                /// instead of overflowing on small screens
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: tight ? 13 : 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}