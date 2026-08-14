// lib/screens/quiz/leaderboard_screen.dart

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';

/// Leaderboard screen shows the top users based on total XP.
/// Data is fetched from Firestore and displayed with a podium
/// for the top 3 users and a ranked list for the rest.

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Leaderboard",
      subtitle: "Top responders worldwide",
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('totalXP', descending: true)
            .limit(50)
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            );
          }

          final users = snap.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No leaderboard data"));
          }

          final top3 = users.take(3).toList();
          final rest = users.skip(3).toList();

          return Column(
            children: [
              _TopPodium(users: top3),
              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Global Rankings",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColor.text,
                      ),
                ),
              ),

              const SizedBox(height: 14),

              ...rest.asMap().entries.map((entry) {
                final rank = entry.key + 4;
                final data = entry.value.data() as Map<String, dynamic>;

                return _LeaderboardTile(
                  rank: rank,
                  name: data['name'] ?? 'User',
                  xp: data['totalXP'] ?? 0,
                  image: data['profileImage'],
                );
              }),

              const SizedBox(height: 26),
            ],
          );
        },
      ),
    );
  }
}

/// Widget displaying the top 3 ranked users in podium style
class _TopPodium extends StatelessWidget {
  final List<QueryDocumentSnapshot> users;

  const _TopPodium({required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withOpacity(0.16),
            AppColor.safeGreen.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColor.primary.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(users.length, (i) {
          final data = users[i].data() as Map<String, dynamic>;
          final rank = i + 1;

          return Column(
            children: [
              Text(
                "#$rank",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  color: rank == 1 ? AppColor.primary : AppColor.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              CircleAvatar(
                radius: rank == 1 ? 48 : 32,
                backgroundColor: AppColor.primary.withOpacity(0.20),
                backgroundImage: data['profileImage'] != null
                    ? NetworkImage(data['profileImage'])
                    : null,
                child: data['profileImage'] == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),

              const SizedBox(height: 10),

              Text(
                data['name'] ?? 'User',
                style: const TextStyle(
                  color: AppColor.text,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${data['totalXP'] ?? 0} XP",
                style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Individual leaderboard list tile for ranks below top 3
class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final String? image;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.xp,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "#$rank",
            style: const TextStyle(
              color: AppColor.textMuted,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(width: 14),

          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: image != null ? NetworkImage(image!) : null,
            child: image == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColor.text,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$xp XP",
                style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: 74,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.safeGreen.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}