// lib/widgets/ bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';

// Screens
import 'package:disaster_app_ui/screens/alerts/alerts_screen.dart';
import 'package:disaster_app_ui/screens/dashboard/home_screen.dart';
import 'package:disaster_app_ui/screens/maps/map_screen.dart';
import 'package:disaster_app_ui/screens/quiz/quiz_list_screen.dart';
import 'package:disaster_app_ui/screens/settingss/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          8,
          14,
          bottomInset > 0 ? bottomInset + 5 : 12,
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: _SideNavItem(
                  label: "Home",
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  active: currentIndex == 0,
                  onTap: () => _navigate(0),
                ),
              ),

              Expanded(
                child: _SideNavItem(
                  label: "Map",
                  icon: Icons.near_me_outlined,
                  activeIcon: Icons.near_me_rounded,
                  active: currentIndex == 1,
                  onTap: () => _navigate(1),
                ),
              ),

              SizedBox(
                width: 82,
                child: _CenterAlertButton(
                  active: currentIndex == 2,
                  onTap: () => _navigate(2),
                ),
              ),

              Expanded(
                child: _SideNavItem(
                  label: "Quiz",
                  icon: Icons.extension_outlined,
                  activeIcon: Icons.extension_rounded,
                  active: currentIndex == 3,
                  onTap: () => _navigate(3),
                ),
              ),

              Expanded(
                child: _SideNavItem(
                  label: "Settings",
                  icon: Icons.tune_rounded,
                  activeIcon: Icons.tune_rounded,
                  active: currentIndex == 4,
                  onTap: () => _navigate(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  const _SideNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() => _pressed = true);
      },

      onTapCancel: () {
        setState(() => _pressed = false);
      },

      onTapUp: (_) {
        setState(() => _pressed = false);
      },

      onTap: widget.onTap,

      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 110),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,

              transform: Matrix4.translationValues(
                0,
                widget.active ? -2 : 0,
                0,
              ),

              width: 40,
              height: 38,

              decoration: BoxDecoration(
                color: widget.active
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,

                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(
                widget.active
                    ? widget.activeIcon
                    : widget.icon,

                size: widget.active ? 23 : 21,

                color: widget.active
                    ? Colors.white
                    : Colors.white.withOpacity(0.48),
              ),
            ),

            const SizedBox(height: 4),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),

              style: TextStyle(
                fontSize: widget.active ? 10 : 9.5,

                fontWeight: widget.active
                    ? FontWeight.w800
                    : FontWeight.w600,

                color: widget.active
                    ? Colors.white
                    : Colors.white.withOpacity(0.45),
              ),

              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 5),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,

              width: widget.active ? 20 : 0,
              height: 3,

              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAlertButton extends StatefulWidget {
  const _CenterAlertButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  State<_CenterAlertButton> createState() => _CenterAlertButtonState();
}

class _CenterAlertButtonState extends State<_CenterAlertButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() => _pressed = true);
      },

      onTapCancel: () {
        setState(() => _pressed = false);
      },

      onTapUp: (_) {
        setState(() => _pressed = false);
      },

      onTap: widget.onTap,

      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 110),

        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -21,

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,

                width: widget.active ? 64 : 62,
                height: widget.active ? 64 : 62,

                decoration: BoxDecoration(
                  color: widget.active
                      ? AppColor.primary
                      : AppColor.primary.withOpacity(0.78),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: widget.active
                        ? Colors.white.withOpacity(0.30)
                        : Colors.white.withOpacity(0.14),
                    width: widget.active ? 2.5 : 2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(
                        widget.active ? 0.30 : 0.18,
                      ),
                      blurRadius: widget.active ? 22 : 16,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),

                child: Icon(
                  widget.active
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,

                  color: Colors.white.withOpacity(
                    widget.active ? 1 : 0.82,
                  ),

                  size: widget.active ? 29 : 27,
                ),
              ),
            ),

            Positioned(
              bottom: 4,

              child: Column(
                children: [
                  Text(
                    "Alerts",
                    style: TextStyle(
                      fontSize: widget.active ? 10 : 9.5,
                      fontWeight: widget.active
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: widget.active
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                    ),
                  ),

                  const SizedBox(height: 5),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),

                    width: widget.active ? 22 : 0,
                    height: 3,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}