// ===============================================================
// home_screen.dart
// ---------------------------------------------------------------
// This screen represents the main dashboard of the DisasterAid
// mobile application.
//
// The dashboard acts as the central navigation hub where users
// can access the primary features of the system, including:
//
// • Live disaster alerts
// • Nearby shelters and safe zones
// • Emergency SOS functionality
// • Disaster preparedness learning material
// • Safety quizzes
// • Emergency service directory
// • User settings and profile
//
// The screen also integrates a floating chatbot assistant that
// helps users quickly retrieve emergency information.
// ===============================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:disaster_app_ui/screens/EmergencyContacts.dart';
import 'package:disaster_app_ui/screens/Learning/learning_screen.dart';
import 'package:disaster_app_ui/screens/auth/auth_controller.dart';
import 'package:disaster_app_ui/screens/chatbot/chatbot_screen.dart';
import 'package:disaster_app_ui/screens/settingss/notifications_screen.dart';
import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/info_card.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  /// Access the authentication controller
  final auth = AuthController.to;

  /// Animation controller for chatbot floating button
  late final AnimationController _botCtrl;

  // ===============================================================
  // INIT STATE
  // ---------------------------------------------------------------
  // Initializes the animation controller for the chatbot FAB.
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _botCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  // ===============================================================
  // DISPOSE
  // ---------------------------------------------------------------
  // Dispose animation controller to avoid memory leaks.
  // ===============================================================

  @override
  void dispose() {
    _botCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // OPEN SOS SHEET
  // ---------------------------------------------------------------
  // Opens the SOS emergency bottom sheet which allows the user
  // to quickly send location or call an emergency contact.
  // ===============================================================

  void _openSosSheet({
    required String userName,
    required String emergency,
  }) {

    /// Check if the user has an emergency contact
    if (emergency.trim().isEmpty) {

      Get.snackbar(
        'Missing Emergency Contact',
        'Please add an emergency number in Profile to use SOS.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      /// Navigate to profile screen to update contact
      Get.to(() => const InfoScreen());
      return;
    }

    /// Open SOS emergency interface
    Get.bottomSheet(
      SosBottomSheet(
        userName: userName,
        emergencyContact: emergency,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ===============================================================
  // BUILD METHOD
  // ---------------------------------------------------------------
  // The main UI of the dashboard showing different emergency
  // features and quick-access navigation cards.
  // ===============================================================

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      /// Get current logged-in user
      final user = auth.currentUser.value;

      /// Display user name if available
      final userName =
          (user?.name != null && user!.name.isNotEmpty)
              ? user.name
              : "there";

      /// Emergency contact number
      final emergency = user?.emergencyContact ?? "";

      return AppScaffold(
        title: null,
        subtitle: null,
        scroll: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),

        /// Bottom navigation bar
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),

        appBarActions: const [],

        // ==========================================================
        // FLOATING CHATBOT BUTTON
        // ==========================================================

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        floatingActionButton: _AnimatedBotFab(
          ctrl: _botCtrl,
          onTap: () => Get.to(() => const ChatbotScreen()),
        ),

        // ==========================================================
        // MAIN DASHBOARD CONTENT
        // ==========================================================

        child: Column(
          children: [

            const SizedBox(height: 6),

            /// Top profile bar
            _topBar(user),

            const SizedBox(height: 16),

            /// Safety status message
            _headlineStrip(userName),

            const SizedBox(height: 14),

            /// SOS emergency button
            _sosButton(
              onTap: () => _openSosSheet(
                userName: userName,
                emergency: emergency,
              ),
            ),

            const SizedBox(height: 22),

            /// Disaster alerts section
            InfoCard(
              title: "Live Alerts",
              subtitle: "View ongoing disasters & warnings",
              icon: Icons.warning_amber_rounded,
              onTap: () => Get.to(
                () => const AlertScreen(),
                transition: Transition.rightToLeft,
              ),
            ),

            const SizedBox(height: 16),

            /// Map and shelter locator
            InfoCard(
              title: "Map & Shelters",
              subtitle: "Find safe zones near you",
              icon: Icons.map_rounded,
              onTap: () => Get.to(() => const MapsScreen()),
            ),

            const SizedBox(height: 16),

            /// Safety quiz feature
            InfoCard(
              title: "Take Quiz",
              subtitle: "Test your safety knowledge",
              icon: Icons.quiz_rounded,
              onTap: () => Get.to(() => const QuizListScreen()),
            ),

            const SizedBox(height: 16),

            /// Learning and preparedness resources
            InfoCard(
              title: "Learning & Knowledge",
              subtitle: "Understand disasters & stay prepared",
              icon: Icons.menu_book_rounded,
              onTap: () => Get.to(
                () => const LearningScreen(),
                transition: Transition.rightToLeft,
              ),
            ),

            const SizedBox(height: 16),

            /// Emergency service directory
            InfoCard(
              title: "Emergency Directory",
              subtitle: "Police, fire, rescue & helplines",
              icon: Icons.phone_in_talk_rounded,
              onTap: () => Get.to(() => const EmergencyDirectoryScreen()),
            ),

            const SizedBox(height: 16),

            /// Application settings
            InfoCard(
              title: "Settings",
              subtitle: "Profile, language & preferences",
              icon: Icons.settings_rounded,
              onTap: () => Get.to(() => const SettingsScreen()),
            ),

            /// Space for floating button
            const SizedBox(height: 70),
          ],
        ),
      );
    });
  }

  // ===============================================================
  // TOP BAR
  // ---------------------------------------------------------------
  // Displays the user's profile image, dashboard title, and
  // notification icon.
  // ===============================================================

  Widget _topBar(user) {
    return Row(
      children: [

        /// Profile image
        GestureDetector(
          onTap: () => Get.to(() => const InfoScreen()),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColor.border),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withOpacity(0.10),
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,

              /// Load profile image if available
              backgroundImage:
                  (user?.profileImage != null &&
                          user!.profileImage!.isNotEmpty)
                      ? CachedNetworkImageProvider(user.profileImage!)
                      : null,

              child:
                  (user?.profileImage == null ||
                          user!.profileImage!.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        )
                      : null,
            ),
          ),
        ),

        /// Dashboard title
        const Expanded(
          child: Center(
            child: TextWidget(
              "DisasterAid Dashboard",
              size: 17,
              weight: FontWeight.w900,
              color: AppColor.secondary,
            ),
          ),
        ),

        /// Notifications button
        Container(
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

          child: IconButton(
            onPressed: () => Get.to(() => NotificationsScreen()),
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColor.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SOS BUTTON
  // ---------------------------------------------------------------
  // Emergency quick-action button allowing the user to send
  // location or call emergency contact immediately.
  // ===============================================================

  Widget _sosButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),

        child: Row(
          children: [

            /// SOS icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos_rounded, color: Colors.white),
            ),

            const SizedBox(width: 12),

            /// SOS text description
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextWidget(
                    "SOS Emergency",
                    size: 16,
                    weight: FontWeight.w900,
                    color: Colors.white,
                  ),

                  SizedBox(height: 2),

                  TextWidget(
                    "Send SMS with live location or call contact",
                    size: 12,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADLINE STRIP
  // ---------------------------------------------------------------
  // Displays a status message indicating whether the user is
  // currently safe or if there is a nearby disaster alert.
  // ===============================================================

  Widget _headlineStrip(String userName) {

    const bool hasAlert = false;

    final Color bgColor =
        hasAlert
            ? Colors.red.withOpacity(0.12)
            : Colors.green.withOpacity(0.12);

    final Color dotColor =
        hasAlert ? Colors.redAccent : Colors.green;

    final String message =
        hasAlert
            ? "⚠️ $userName, stay alert! Disaster detected nearby."
            : "Hello, $userName 👋 You are safe right now ✅ ";

    return GestureDetector(
      onTap: () => Get.to(() => const AlertScreen()),

      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),

        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.border),
        ),

        child: Row(
          children: [

            /// Status indicator dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 14),

            /// Status message
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColor.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ANIMATED CHATBOT FLOATING BUTTON
// ---------------------------------------------------------------
// Displays an animated floating button that opens the chatbot
// assistant when pressed.
// ===============================================================

class _AnimatedBotFab extends StatelessWidget {

  const _AnimatedBotFab({
    required this.ctrl,
    required this.onTap,
  });

  final AnimationController ctrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: ctrl,

      builder: (_, __) {

        final t = ctrl.value;

        final scale = 1.0 + (t * 0.06);
        final glow = 0.18 + (t * 0.10);

        return Transform.scale(
          scale: scale,

          child: GestureDetector(
            onTap: onTap,

            child: Container(
              width: 56,
              height: 56,

              decoration: BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(glow),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.robot,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}