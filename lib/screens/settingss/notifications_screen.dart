// lib/screens/settingss/notifications_screen.dart

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../models/app_notification.dart';
import '../../services/local_notification_center.dart';
import '../../widgets/text_widget.dart';

/// Notifications screen for DisasterAid
/// This page shows all alerts, SOS updates, nearby safety notices,
/// and system notifications received by the user.
class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  /// Access the local notification manager
  final center = LocalNotificationCenter.to;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Notifications",
      subtitle: "Real-time alerts, SOS, and updates",
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      /// Bottom navigation used across the application
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),

      /// Action button to clear stored notifications
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColor.primary),
          onPressed: () async {

            /// Confirmation dialog before deleting notification history
            final ok = await Get.dialog<bool>(
              AlertDialog(
                title: const Text("Clear notifications?"),
                content: const Text("This will remove your local notification history."),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
                  ElevatedButton(onPressed: () => Get.back(result: true), child: const Text("Clear")),
                ],
              ),
            );

            if (ok == true) await center.clearAll();
          },
        ),
      ],

      /// Reactive UI which updates automatically when notifications change
      child: Obx(() {
        final all = center.items;

        /// If there are no notifications, show a simple message
        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: TextWidget(
                "No notifications yet",
                color: AppColor.textMuted,
                size: 15,
              ),
            ),
          );
        }

        /// Categorize notifications based on their type
        final urgent = all.where((n) => n.type == AppNotifType.alert).toList();
        final sos = all.where((n) => n.type == AppNotifType.sos).toList();
        final nearby = all.where((n) => n.type == AppNotifType.nearby).toList();
        final system = all.where((n) => n.type == AppNotifType.system).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            _section("Urgent Alerts", urgent),
            const SizedBox(height: 18),

            _section("SOS Activity", sos),
            const SizedBox(height: 18),

            _section("Nearby Safety", nearby),
            const SizedBox(height: 18),

            _section("System", system),
            const SizedBox(height: 28),
          ],
        );
      }),
    );
  }

  /// Builds a notification section with a title and list of notifications
  Widget _section(String title, List<AppNotificationModel> list) {

    /// If there are no notifications in this category
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.verified_rounded, color: AppColor.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(title, weight: FontWeight.w900),
                  const SizedBox(height: 4),
                  const TextWidget("No updates right now", size: 12, color: AppColor.textMuted),
                ],
              ),
            )
          ],
        ),
      );
    }

    /// Show list of notifications inside the section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(title, weight: FontWeight.w900, size: 16),
        const SizedBox(height: 12),
        ...list.map(_tile),
      ],
    );
  }

  /// Individual notification card
  Widget _tile(AppNotificationModel n) {
    final iconColor = Color(n.iconColor);

    return GestureDetector(
      /// If a notification contains a link, open it when tapped
      onTap: n.link == null ? null : () => _openLink(n.link!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Notification icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: iconColor.withOpacity(0.18)),
              ),
              child: Icon(n.icon, color: iconColor, size: 26),
            ),

            const SizedBox(width: 14),

            /// Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(n.title, size: 15, weight: FontWeight.w900),
                  const SizedBox(height: 6),
                  TextWidget(n.message, size: 13, color: AppColor.textMuted),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(_timeAgo(n.createdAt), AppColor.textMuted),
                      if ((n.source ?? "").isNotEmpty) _chip(n.source!, AppColor.secondary),
                      if ((n.severity ?? "").isNotEmpty) _chip(n.severity!, iconColor),
                      if (n.link != null) _chip("Open", AppColor.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small info chip used to show metadata like time, severity, or source
  Widget _chip(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.18)),
      ),
      child: TextWidget(text, size: 11, weight: FontWeight.w800, color: c),
    );
  }

  /// Opens an external link related to a notification
  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Converts a timestamp into a readable relative time (e.g., 5 min ago)
  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return "Just now";
    if (d.inMinutes < 60) return "${d.inMinutes} min ago";
    if (d.inHours < 24) return "${d.inHours} hr ago";
    return "${d.inDays} days ago";
  }
}