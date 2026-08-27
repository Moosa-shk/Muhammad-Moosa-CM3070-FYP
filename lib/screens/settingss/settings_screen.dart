// lib/screens/settingss/settings_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:disaster_app_ui/screens/auth/login_screen.dart';
import 'package:disaster_app_ui/screens/settingss/notifications_screen.dart';
import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';
import '../auth/auth_controller.dart';
import '../auth/info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;

    return AppScaffold(
      title: "Settings",
      subtitle: "Your RescueAid control center",
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      bottomNavigationBar: const BottomNavBar(
        currentIndex: 4,
      ),

      child: Obx(() {
        final user = auth.currentUser.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _identityStrip(user),

            const SizedBox(height: 26),

            Row(
              children: [
                const Expanded(
                  child: TextWidget(
                    "Control Center",
                    size: 18,
                    weight: FontWeight.w800,
                    color: AppColor.text,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const TextWidget(
                    "4 OPTIONS",
                    size: 10,
                    weight: FontWeight.w800,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _compactBentoCard(
                    icon: Icons.language_rounded,
                    title: "Language",
                    value: "English",
                    hint: "Default",
                    accent: AppColor.info,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Language change UI only",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _compactBentoCard(
                    icon: Icons.shield_outlined,
                    title: "Privacy",
                    value: "Protected",
                    hint: "View policy",
                    accent: AppColor.safeGreen,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Privacy policy UI only",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _aboutCard(
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "RescueAid",
                );
              },
            ),

            const SizedBox(height: 14),

            _featuredNotificationsCard(
              onTap: () {
                Get.to(
                  () => NotificationsScreen(),
                );
              },
            ),

            const SizedBox(height: 26),

            const TextWidget(
              "Account",
              size: 15,
              weight: FontWeight.w800,
              color: AppColor.text,
            ),

            const SizedBox(height: 10),

            _logoutAction(
              onTap: () async {
                await auth.logout();

                Get.offAll(
                  () => const LoginScreen(),
                  transition: Transition.fadeIn,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  Widget _identityStrip(dynamic user) {
    final hasImage = user?.profileImage != null &&
        user.profileImage.toString().trim().isNotEmpty;

    final phone = (user?.phone ?? "").toString();
    final blood = (user?.bloodGroup ?? "").toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        14,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: user.profileImage,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColor.primarySoft,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: AppColor.primary,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  user?.name ?? "User",
                  size: 17,
                  weight: FontWeight.w800,
                  color: AppColor.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                if (user?.email != null)
                  TextWidget(
                    user.email,
                    size: 12,
                    color: AppColor.textMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (phone.isNotEmpty || blood.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (phone.isNotEmpty)
                        _profileChip(
                          Icons.phone_outlined,
                          phone,
                        ),
                      if (blood.isNotEmpty)
                        _profileChip(
                          Icons.bloodtype_outlined,
                          blood,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Get.to(
                () => const InfoScreen(),
                transition: Transition.rightToLeft,
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColor.inputFill,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColor.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColor.primary,
          ),
          const SizedBox(width: 5),
          TextWidget(
            text,
            size: 10,
            weight: FontWeight.w700,
            color: AppColor.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _featuredNotificationsCard({
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColor.secondary.withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "Notifications",
                      size: 16,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    SizedBox(height: 4),
                    TextWidget(
                      "Manage emergency alerts and updates",
                      size: 12,
                      color: Color(0xD8FFFFFF),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactBentoCard({
    required IconData icon,
    required String title,
    required String value,
    required String hint,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 162,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: accent,
                      size: 21,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.north_east_rounded,
                    color: AppColor.textMuted,
                    size: 18,
                  ),
                ],
              ),

              const Spacer(),

              TextWidget(
                title,
                size: 13,
                weight: FontWeight.w700,
                color: AppColor.textMuted,
              ),

              const SizedBox(height: 3),

              TextWidget(
                value,
                size: 17,
                weight: FontWeight.w800,
                color: AppColor.text,
              ),

              const SizedBox(height: 3),

              TextWidget(
                hint,
                size: 10.5,
                color: AppColor.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutCard({
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColor.primarySoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColor.primary.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      "About RescueAid",
                      size: 14.5,
                      weight: FontWeight.w800,
                      color: AppColor.text,
                    ),
                    SizedBox(height: 3),
                    TextWidget(
                      "Application information • v1.0.0",
                      size: 11.5,
                      color: AppColor.textMuted,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutAction({
    required Future<void> Function() onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await onTap();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: AppColor.dangerSoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColor.danger.withOpacity(0.18),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColor.danger,
                size: 21,
              ),

              SizedBox(width: 12),

              Expanded(
                child: TextWidget(
                  "Log out",
                  size: 14,
                  weight: FontWeight.w800,
                  color: AppColor.danger,
                ),
              ),

              Icon(
                Icons.arrow_forward_rounded,
                color: AppColor.danger,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}