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

/// Settings screen of the DisasterAid application.
/// This screen allows users to manage their profile information,
/// access notification settings, view privacy information,
/// and log out from the application.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;

    return AppScaffold(
      title: "Settings",
      subtitle: "Profile and preferences",
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      /// Bottom navigation used throughout the app
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),

      /// Reactive UI that updates automatically when user data changes
      child: Obx(() {
        final user = auth.currentUser.value;

        return Column(
          children: [
            _profileCard(user),
            const SizedBox(height: 18),

            /// Language preference tile (UI only in current version)
            _tile(
              Icons.language_rounded,
              "Language",
              "English (default)",
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language change UI only")),
              ),
            ),

            /// Navigate to notification management screen
            _tile(
              Icons.notifications_rounded,
              "Notifications",
              "Manage alert preferences",
              () => Get.to(() => NotificationsScreen()),
            ),

            /// Privacy policy section
            _tile(
              Icons.shield_rounded,
              "Privacy Policy",
              "Read our privacy policy",
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Privacy policy UI only")),
              ),
            ),

            /// Application information dialog
            _tile(
              Icons.info_outline_rounded,
              "About App",
              "Version 1.0.0",
              () => showAboutDialog(
                context: context,
                applicationName: "DisasterAid",
              ),
            ),

            const SizedBox(height: 18),

            /// Logout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  elevation: 10,
                  shadowColor: AppColor.primary.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  await auth.logout();
                  Get.offAll(() => const LoginScreen(),
                      transition: Transition.fadeIn);
                },
                child: const TextWidget(
                  "Log Out",
                  color: Colors.white,
                  weight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 26),
          ],
        );
      }),
    );
  }

  /// Displays the user profile information card
  /// including profile image, name, email, phone, and blood group.
  Widget _profileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// User profile avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: (user?.profileImage != null &&
                    user.profileImage.toString().isNotEmpty)
                ? CachedNetworkImageProvider(user.profileImage)
                : null,
            child: (user?.profileImage == null ||
                    user.profileImage.toString().isEmpty)
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 14),

          /// User information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  user?.name ?? "User",
                  size: 16,
                  weight: FontWeight.w900,
                  color: AppColor.text,
                ),

                if (user?.email != null)
                  TextWidget(
                    user.email,
                    size: 13,
                    color: AppColor.textMuted,
                  ),

                if ((user?.phone ?? "").toString().isNotEmpty)
                  TextWidget(
                    "Phone: ${user.phone}",
                    size: 12,
                    color: AppColor.textMuted,
                  ),

                if ((user?.bloodGroup ?? "").toString().isNotEmpty)
                  TextWidget(
                    "Blood group: ${user.bloodGroup}",
                    size: 12,
                    color: AppColor.textMuted,
                  ),
              ],
            ),
          ),

          /// Edit profile button
          IconButton(
            icon: Icon(Icons.edit, color: AppColor.primary),
            onPressed: () => Get.to(() => const InfoScreen(),
                transition: Transition.rightToLeft),
          ),
        ],
      ),
    );
  }

  /// Reusable tile widget used for different settings options
  /// such as notifications, language, privacy policy, etc.
  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [

            /// Icon representing the settings option
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.primary.withOpacity(0.18)),
              ),
              child: Icon(icon, color: AppColor.primary),
            ),

            const SizedBox(width: 14),

            /// Title and description of the setting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(title,
                      size: 15, weight: FontWeight.w900, color: AppColor.text),
                  const SizedBox(height: 6),
                  TextWidget(subtitle, size: 13, color: AppColor.textMuted),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColor.textMuted),
          ],
        ),
      ),
    );
  }
}