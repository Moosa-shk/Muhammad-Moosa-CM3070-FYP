// lib/screens/settingss/notifications_screen.dart

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../models/app_notification.dart';
import '../../services/local_notification_center.dart';
import '../../widgets/text_widget.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final LocalNotificationCenter center = LocalNotificationCenter.to;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      appBarActions: [
        Obx(
          () => center.items.isEmpty
              ? const SizedBox.shrink()
              : _clearButton(),
        ),
      ],

      child: Obx(() {
        final all = center.items;

        if (all.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 34),
              _emptyNotifications(),
              const SizedBox(height: 30),
            ],
          );
        }

        final urgent = all
            .where((item) => item.type == AppNotifType.alert)
            .toList();

        final sos = all
            .where((item) => item.type == AppNotifType.sos)
            .toList();

        final nearby = all
            .where((item) => item.type == AppNotifType.nearby)
            .toList();

        final system = all
            .where((item) => item.type == AppNotifType.system)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            _pageHeader(),

            const SizedBox(height: 24),

            // =====================================================
            // SUMMARY
            // =====================================================
            _summaryCard(
              total: all.length,
              urgent: urgent.length,
              sos: sos.length,
              nearby: nearby.length,
            ),

            const SizedBox(height: 28),

            // =====================================================
            // URGENT
            // =====================================================
            if (urgent.isNotEmpty) ...[
              _sectionTitle(
                title: "Urgent",
                count: urgent.length,
                icon: Icons.warning_amber_rounded,
                color: AppColor.danger,
              ),

              const SizedBox(height: 10),

              ...urgent.map(_notificationTile),

              const SizedBox(height: 22),
            ],

            // =====================================================
            // SOS
            // =====================================================
            if (sos.isNotEmpty) ...[
              _sectionTitle(
                title: "SOS",
                count: sos.length,
                icon: Icons.sos_rounded,
                color: AppColor.warning,
              ),

              const SizedBox(height: 10),

              ...sos.map(_notificationTile),

              const SizedBox(height: 22),
            ],

            // =====================================================
            // NEARBY
            // =====================================================
            if (nearby.isNotEmpty) ...[
              _sectionTitle(
                title: "Nearby",
                count: nearby.length,
                icon: Icons.near_me_outlined,
                color: AppColor.safeGreen,
              ),

              const SizedBox(height: 10),

              ...nearby.map(_notificationTile),

              const SizedBox(height: 22),
            ],

            // =====================================================
            // SYSTEM
            // =====================================================
            if (system.isNotEmpty) ...[
              _sectionTitle(
                title: "System",
                count: system.length,
                icon: Icons.info_outline_rounded,
                color: AppColor.info,
              ),

              const SizedBox(height: 10),

              ...system.map(_notificationTile),
            ],

            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  // ===============================================================
  // PAGE HEADER
  // ===============================================================

  Widget _pageHeader() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TextWidget(
            "Notifications",
            size: 27,
            weight: FontWeight.w800,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          SizedBox(height: 5),

          TextWidget(
            "Alerts and updates",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CLEAR BUTTON
  // ===============================================================

  Widget _clearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () async {
          final result = await Get.dialog<bool>(
            AlertDialog(
              title: const Text(
                "Clear notifications?",
              ),

              content: const Text(
                "Your notification history will be removed.",
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Get.back(result: true);
                  },
                  child: const Text(
                    "Clear",
                  ),
                ),
              ],
            ),
          );

          if (result == true) {
            await center.clearAll();
          }
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

          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColor.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // SUMMARY
  // ===============================================================

  Widget _summaryCard({
    required int total,
    required int urgent,
    required int sos,
    required int nearby,
  }) {
    return Container(
      width: double.infinity,

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

      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              value: total.toString(),
              label: "All",
              color: AppColor.primary,
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _summaryItem(
              value: urgent.toString(),
              label: "Urgent",
              color: AppColor.danger,
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _summaryItem(
              value: sos.toString(),
              label: "SOS",
              color: AppColor.warning,
            ),
          ),

          _summaryDivider(),

          Expanded(
            child: _summaryItem(
              value: nearby.toString(),
              label: "Nearby",
              color: AppColor.safeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        TextWidget(
          value,
          size: 18,
          weight: FontWeight.w800,
          color: color,
        ),

        const SizedBox(height: 3),

        TextWidget(
          label,
          size: 10,
          weight: FontWeight.w600,
          color: AppColor.textMuted,
          align: TextAlign.center,
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColor.border,
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(11),
          ),

          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: TextWidget(
            title,
            size: 14,
            weight: FontWeight.w700,
            color: AppColor.text,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),

          decoration: BoxDecoration(
            color: AppColor.inputFill,
            borderRadius: BorderRadius.circular(99),
          ),

          child: TextWidget(
            count.toString(),
            size: 10.5,
            weight: FontWeight.w700,
            color: AppColor.textMuted,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // NOTIFICATION TILE
  // ===============================================================

  Widget _notificationTile(
    AppNotificationModel notification,
  ) {
    final accent = Color(notification.iconColor);

    final hasLink = notification.link != null &&
        notification.link!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: hasLink
              ? () {
                  _openLink(
                    notification.link!,
                  );
                }
              : null,

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColor.border,
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // TOP ROW
                // =================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        notification.icon,
                        color: accent,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            notification.title,
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColor.text,
                          ),

                          const SizedBox(height: 3),

                          TextWidget(
                            _timeAgo(notification.createdAt),
                            size: 10.5,
                            color: AppColor.textMuted,
                          ),
                        ],
                      ),
                    ),

                    if (hasLink)
                      const Icon(
                        Icons.north_east_rounded,
                        size: 17,
                        color: AppColor.textMuted,
                      ),
                  ],
                ),

                const SizedBox(height: 11),

                // =================================================
                // MESSAGE
                // =================================================
                TextWidget(
                  notification.message,
                  size: 12.5,
                  color: AppColor.textMuted,
                ),

                if (_hasMeta(notification)) ...[
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      if ((notification.source ?? "")
                          .trim()
                          .isNotEmpty)
                        Flexible(
                          child: _metaItem(
                            text: notification.source!,
                            color: AppColor.textMuted,
                          ),
                        ),

                      if ((notification.source ?? "")
                              .trim()
                              .isNotEmpty &&
                          (notification.severity ?? "")
                              .trim()
                              .isNotEmpty)
                        const SizedBox(width: 7),

                      if ((notification.severity ?? "")
                          .trim()
                          .isNotEmpty)
                        Flexible(
                          child: _metaItem(
                            text: notification.severity!,
                            color: accent,
                          ),
                        ),

                      if (hasLink) ...[
                        const Spacer(),

                        _metaItem(
                          text: "Open",
                          color: AppColor.primary,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // META
  // ===============================================================

  Widget _metaItem({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(99),
      ),

      child: TextWidget(
        text,
        size: 9.5,
        weight: FontWeight.w600,
        color: color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  bool _hasMeta(
    AppNotificationModel notification,
  ) {
    return (notification.source ?? "").trim().isNotEmpty ||
        (notification.severity ?? "").trim().isNotEmpty ||
        (notification.link ?? "").trim().isNotEmpty;
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _emptyNotifications() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(22),
            ),

            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColor.primary,
              size: 29,
            ),
          ),

          const SizedBox(height: 15),

          const TextWidget(
            "No notifications",
            size: 17,
            weight: FontWeight.w700,
            color: AppColor.text,
          ),

          const SizedBox(height: 5),

          const TextWidget(
            "New alerts will appear here.",
            size: 12,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // LINK
  // ===============================================================

  Future<void> _openLink(
    String url,
  ) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  // ===============================================================
  // TIME
  // ===============================================================

  String _timeAgo(
    DateTime time,
  ) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return "Now";
    }

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    }

    if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    }

    if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    }

    return "${time.day}/${time.month}";
  }
}