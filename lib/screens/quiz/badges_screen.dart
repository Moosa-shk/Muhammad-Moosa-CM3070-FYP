// lib/screens/badges/badges_screen.dart
import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:disaster_app_ui/widgets/app_scaffold.dart'; // ✅ NEW global design
import 'package:flutter/material.dart';

import '../../widgets/badge_chip.dart';
import '../../widgets/text_widget.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'name': 'Bronze Responder', 'icon': Icons.military_tech, 'color': Colors.brown},
      {'name': 'Silver Responder', 'icon': Icons.military_tech, 'color': Colors.grey},
      {'name': 'Gold Responder', 'icon': Icons.military_tech, 'color': Colors.amber},
    ];

    return AppScaffold(
      title: "My Badges",
      subtitle: "Your earned achievements",
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      child: badges.isEmpty
          ? const Center(child: TextWidget("No badges earned yet."))
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: badges
                  .map(
                    (b) => BadgeChip(
                      label: b['name'] as String,
                      icon: b['icon'] as IconData,
                      color: b['color'] as Color,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}