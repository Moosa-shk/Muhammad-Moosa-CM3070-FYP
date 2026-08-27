// lib/screens/badges/badges_screen.dart

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'name': 'Bronze Responder',
        'icon': Icons.military_tech_outlined,
        'color': Colors.brown,
        'subtitle': 'Responder Level 1',
      },
      {
        'name': 'Silver Responder',
        'icon': Icons.workspace_premium_outlined,
        'color': Colors.grey,
        'subtitle': 'Responder Level 2',
      },
      {
        'name': 'Gold Responder',
        'icon': Icons.emoji_events_outlined,
        'color': Colors.amber,
        'subtitle': 'Responder Level 3',
      },
    ];

    return AppScaffold(
      title: null,
      subtitle: null,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // =======================================================
          // CUSTOM PAGE HEADER
          // =======================================================

          _pageHeader(),

          const SizedBox(height: 24),

          if (badges.isEmpty)
            _emptyState()
          else ...[
            // =====================================================
            // ACHIEVEMENT SUMMARY
            // =====================================================

            _achievementSummary(
              total: badges.length,
            ),

            const SizedBox(height: 22),

            // =====================================================
            // FEATURED BADGE
            // =====================================================

            _featuredBadge(
              name: badges[2]['name'] as String,
              subtitle:
                  badges[2]['subtitle'] as String,
              icon: badges[2]['icon'] as IconData,
              color: badges[2]['color'] as Color,
            ),

            const SizedBox(height: 22),

            const TextWidget(
              "Achievement Collection",
              size: 17,
              weight: FontWeight.w900,
              color: AppColor.text,
            ),

            const SizedBox(height: 4),

            const TextWidget(
              "Your responder milestones",
              size: 11.5,
              color: AppColor.textMuted,
            ),

            const SizedBox(height: 14),

            // =====================================================
            // OTHER BADGES
            // =====================================================

            Row(
              children: [
                Expanded(
                  child: _badgeCard(
                    name: badges[0]['name'] as String,
                    subtitle:
                        badges[0]['subtitle'] as String,
                    icon: badges[0]['icon'] as IconData,
                    color: badges[0]['color'] as Color,
                    index: 1,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _badgeCard(
                    name: badges[1]['name'] as String,
                    subtitle:
                        badges[1]['subtitle'] as String,
                    icon: badges[1]['icon'] as IconData,
                    color: badges[1]['color'] as Color,
                    index: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
          ],
        ],
      ),
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
          Icon(
            Icons.workspace_premium_outlined,
            size: 31,
            color: AppColor.primary,
          ),

          SizedBox(height: 9),

          TextWidget(
            "My Badges",
            size: 27,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          SizedBox(height: 5),

          TextWidget(
            "Your earned achievements",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUMMARY
  // ===============================================================

  Widget _achievementSummary({
    required int total,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(17),
            ),

            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColor.warning,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  "Responder Achievements",
                  size: 15.5,
                  weight: FontWeight.w900,
                  color: Colors.white,
                ),

                SizedBox(height: 3),

                TextWidget(
                  "Progress through emergency readiness levels",
                  size: 11.5,
                  color: Color(0xCFFFFFFF),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),

            child: TextWidget(
              "$total",
              size: 13,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FEATURED BADGE
  // ===============================================================

  Widget _featuredBadge({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),

                child: TextWidget(
                  "TOP BADGE",
                  size: 10,
                  weight: FontWeight.w900,
                  color: color,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.verified_rounded,
                color: color,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: 92,
            height: 92,

            decoration: BoxDecoration(
              color: AppColor.surface,
              shape: BoxShape.circle,

              border: Border.all(
                color: color.withOpacity(0.24),
                width: 2,
              ),

              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Icon(
              icon,
              color: color,
              size: 46,
            ),
          ),

          const SizedBox(height: 16),

          TextWidget(
            name,
            size: 18,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          const SizedBox(height: 4),

          TextWidget(
            subtitle,
            size: 11.5,
            weight: FontWeight.w600,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // COMPACT BADGE CARD
  // ===============================================================

  Widget _badgeCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(15),

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
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const Spacer(),

              TextWidget(
                "0$index",
                size: 11,
                weight: FontWeight.w900,
                color: AppColor.textMuted,
              ),
            ],
          ),

          const Spacer(),

          TextWidget(
            name,
            size: 13.5,
            weight: FontWeight.w900,
            color: AppColor.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 5),

          TextWidget(
            subtitle,
            size: 10.5,
            color: AppColor.textMuted,
          ),

          const SizedBox(height: 9),

          Container(
            height: 4,
            width: 38,

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 70,
      ),

      child: Center(
        child: Column(
          children: [
            Container(
              width: 82,
              height: 82,

              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.military_tech_outlined,
                color: AppColor.primary,
                size: 36,
              ),
            ),

            const SizedBox(height: 18),

            const TextWidget(
              "No badges earned yet",
              size: 17,
              weight: FontWeight.w900,
              color: AppColor.text,
            ),
          ],
        ),
      ),
    );
  }
}