// lib/screens/dashboard/home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:disaster_app_ui/screens/EmergencyContacts.dart';
import 'package:disaster_app_ui/screens/Learning/learning_screen.dart';
import 'package:disaster_app_ui/screens/auth/auth_controller.dart';
import 'package:disaster_app_ui/screens/settingss/notifications_screen.dart';
import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';

import '../auth/info_screen.dart';
import '../maps/map_screen.dart';
import '../alerts/alerts_screen.dart';
import '../quiz/quiz_list_screen.dart';
import '../settingss/settings_screen.dart';
import '../../widgets/sos_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthController.to;

  void _openSosSheet({
    required String userName,
    required String emergency,
  }) {
    if (emergency.trim().isEmpty) {
      Get.snackbar(
        'Emergency contact required',
        'Add an emergency number to use SOS.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.danger,
        colorText: Colors.white,
      );

      Get.to(() => const InfoScreen());
      return;
    }

    Get.bottomSheet(
      SosBottomSheet(
        userName: userName,
        emergencyContact: emergency,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = auth.currentUser.value;

      final userName =
          (user?.name != null && user!.name.isNotEmpty) ? user.name : "there";

      final emergency = user?.emergencyContact ?? "";

      return AppScaffold(
        title: null,
        subtitle: null,
        scroll: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        bottomNavigationBar: const BottomNavBar(
          currentIndex: 0,
        ),
        appBarActions: const [],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // =====================================================
            // TOP BAR
            // =====================================================

            _topBar(
              user: user,
              userName: userName,
            ),

            const SizedBox(height: 20),

            // =====================================================
            // SAFETY STATUS
            // =====================================================

            _safetyBanner(),

            const SizedBox(height: 14),

            // =====================================================
            // SOS
            // =====================================================

            _sosSection(
              onTap: () {
                _openSosSheet(
                  userName: userName,
                  emergency: emergency,
                );
              },
            ),

            const SizedBox(height: 28),

            // =====================================================
            // SAFETY
            // =====================================================

            _sectionHeading(
              "Safety",
            ),

            const SizedBox(height: 12),

            _alertsFeature(),

            const SizedBox(height: 14),

            // =====================================================
            // MAP + LEARNING
            // =====================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _mediumFeature(
                    icon: FontAwesomeIcons.locationDot,
                    title: "Shelters",
                    subtitle: "Nearby safe places",
                    accent: AppColor.info,
                    onTap: () {
                      Get.to(
                        () => const MapsScreen(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _mediumFeature(
                    icon: FontAwesomeIcons.bookOpen,
                    title: "Preparedness",
                    subtitle: "Guides & learning",
                    accent: AppColor.safeGreen,
                    onTap: () {
                      Get.to(
                        () => const LearningScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =====================================================
            // TOOLS
            // =====================================================

            _sectionHeading(
              "Tools",
            ),

            const SizedBox(height: 10),

            _utilityRow(
              icon: FontAwesomeIcons.circleQuestion,
              title: "Safety Quiz",
              accent: AppColor.warning,
              onTap: () {
                Get.to(
                  () => const QuizListScreen(),
                );
              },
            ),

            const SizedBox(height: 10),

            _utilityRow(
              icon: FontAwesomeIcons.phone,
              title: "Emergency Directory",
              accent: AppColor.danger,
              onTap: () {
                Get.to(
                  () => const EmergencyDirectoryScreen(),
                );
              },
            ),

            const SizedBox(height: 10),

            _utilityRow(
              icon: FontAwesomeIcons.sliders,
              title: "Settings",
              accent: AppColor.primary,
              onTap: () {
                Get.to(
                  () => const SettingsScreen(),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  // ===============================================================
  // TOP BAR
  // ===============================================================

  Widget _topBar({
    required dynamic user,
    required String userName,
  }) {
    final hasImage = user?.profileImage != null &&
        user.profileImage.toString().trim().isNotEmpty;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(
              () => const InfoScreen(),
            );
          },
          child: Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColor.border,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: user.profileImage,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColor.primarySoft,
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: AppColor.primary,
                          size: 18,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                "Hi, $userName",
                size: 17,
                weight: FontWeight.w800,
                color: AppColor.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const TextWidget(
                "RescueAid",
                size: 11.5,
                weight: FontWeight.w600,
                color: AppColor.textMuted,
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Get.to(
                () => NotificationsScreen(),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColor.border,
                ),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  color: AppColor.primary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SAFETY BANNER
  // ===============================================================

  Widget _safetyBanner() {
    const bool hasAlert = false;

    final color = hasAlert ? AppColor.danger : AppColor.safeGreen;

    final IconData icon = hasAlert
        ? FontAwesomeIcons.triangleExclamation
        : FontAwesomeIcons.shield;

    final text = hasAlert ? "Alert detected nearby" : "No nearby alerts";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => const AlertScreen(),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 14,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextWidget(
                  text,
                  size: 12.5,
                  weight: FontWeight.w700,
                  color: AppColor.text,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.arrowUpRightFromSquare,
                size: 12,
                color: AppColor.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // SOS
  // ===============================================================

  Widget _sosSection({
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            14,
            16,
          ),
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColor.secondary.withOpacity(0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColor.danger,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.lifeRing,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Emergency SOS",
                      size: 16,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    SizedBox(height: 3),
                    TextWidget(
                      "Call or share your location",
                      size: 11.5,
                      color: Color(0xCCFFFFFF),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.arrowRight,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // SECTION HEADING
  // ===============================================================

  Widget _sectionHeading(
    String title,
  ) {
    return TextWidget(
      title,
      size: 15,
      weight: FontWeight.w800,
      color: AppColor.text,
    );
  }

  // ===============================================================
  // ALERT FEATURE
  // ===============================================================

  Widget _alertsFeature() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Get.to(
            () => const AlertScreen(),
            transition: Transition.rightToLeft,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColor.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColor.dangerSoft,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.satelliteDish,
                    color: AppColor.danger,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Live Alerts",
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColor.text,
                    ),
                    SizedBox(height: 4),
                    TextWidget(
                      "Warnings and active events",
                      size: 11.5,
                      color: AppColor.textMuted,
                    ),
                  ],
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColor.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.arrowRight,
                    color: AppColor.primary,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // MEDIUM FEATURE
  // ===============================================================

  Widget _mediumFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 142,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColor.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: FaIcon(
                        icon,
                        color: accent,
                        size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const FaIcon(
                    FontAwesomeIcons.arrowUpRightFromSquare,
                    size: 12,
                    color: AppColor.textMuted,
                  ),
                ],
              ),
              const Spacer(),
              TextWidget(
                title,
                size: 13.5,
                weight: FontWeight.w800,
                color: AppColor.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              TextWidget(
                subtitle,
                size: 10.5,
                color: AppColor.textMuted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // UTILITY ROW
  // ===============================================================

  Widget _utilityRow({
    required IconData icon,
    required String title,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  title,
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: AppColor.text,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: AppColor.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
