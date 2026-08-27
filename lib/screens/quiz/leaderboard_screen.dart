// lib/screens/quiz/leaderboard_screen.dart

import 'package:disaster_app_ui/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/text_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: null,
      subtitle: null,
      showBack: true,
      scroll: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),

          // =======================================================
          // CUSTOM PAGE HEADER
          // =======================================================

          _pageHeader(),

          const SizedBox(height: 24),

          // =======================================================
          // FIRESTORE LEADERBOARD
          // BACKEND QUERY PRESERVED
          // =======================================================

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy(
                  'totalXP',
                  descending: true,
                )
                .limit(50)
                .snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(
                    top: 90,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primary,
                    ),
                  ),
                );
              }

              final users = snap.data!.docs;

              if (users.isEmpty) {
                return _emptyState();
              }

              final first =
                  users.isNotEmpty ? users[0] : null;

              final second =
                  users.length > 1 ? users[1] : null;

              final third =
                  users.length > 2 ? users[2] : null;

              final rest =
                  users.skip(3).toList();

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CHAMPION
                  // =================================================

                  if (first != null)
                    _ChampionCard(
                      user: first,
                    ),

                  const SizedBox(height: 14),

                  // =================================================
                  // SECOND + THIRD
                  // =================================================

                  if (second != null ||
                      third != null)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (second != null)
                          Expanded(
                            child:
                                _RunnerCard(
                              rank: 2,
                              user: second,
                            ),
                          ),

                        if (second != null &&
                            third != null)
                          const SizedBox(
                            width: 12,
                          ),

                        if (third != null)
                          Expanded(
                            child:
                                _RunnerCard(
                              rank: 3,
                              user: third,
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  // =================================================
                  // RANKINGS HEADER
                  // =================================================

                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            TextWidget(
                              "Global Rankings",
                              size: 18,
                              weight:
                                  FontWeight.w900,
                              color:
                                  AppColor.text,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            TextWidget(
                              "Top responders by earned XP",
                              size: 11.5,
                              color: AppColor
                                  .textMuted,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColor
                              .primarySoft,
                          borderRadius:
                              BorderRadius.circular(
                            999,
                          ),
                        ),
                        child: TextWidget(
                          "${users.length}",
                          size: 11,
                          weight:
                              FontWeight.w900,
                          color:
                              AppColor.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // =================================================
                  // REST OF USERS
                  // =================================================

                  if (rest.isEmpty)
                    _topThreeOnly()
                  else
                    ...rest
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        final rank =
                            entry.key + 4;

                        final data =
                            entry.value.data()
                                as Map<String,
                                    dynamic>;

                        return _RankingRow(
                          rank: rank,
                          name: data['name'] ??
                              'User',
                          xp:
                              data['totalXP'] ??
                                  0,
                          image: data[
                              'profileImage'],
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              );
            },
          ),
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
            "Leaderboard",
            size: 27,
            weight: FontWeight.w900,
            color: AppColor.text,
            align: TextAlign.center,
          ),

          SizedBox(height: 5),

          TextWidget(
            "Top responders worldwide",
            size: 12.5,
            color: AppColor.textMuted,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // EMPTY LEADERBOARD
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.leaderboard_outlined,
                color: AppColor.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const TextWidget(
              "No leaderboard data",
              size: 17,
              weight: FontWeight.w900,
              color: AppColor.text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _topThreeOnly() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.border,
        ),
      ),
      child: const TextWidget(
        "No additional rankings yet",
        size: 12,
        color: AppColor.textMuted,
        align: TextAlign.center,
      ),
    );
  }
}

// =================================================================
// #1 CHAMPION CARD
// =================================================================

class _ChampionCard extends StatelessWidget {
  const _ChampionCard({
    required this.user,
  });

  final QueryDocumentSnapshot user;

  @override
  Widget build(BuildContext context) {
    final data =
        user.data() as Map<String, dynamic>;

    final name =
        data['name'] ?? 'User';

    final xp =
        data['totalXP'] ?? 0;

    final image =
        data['profileImage'];

    final hasImage =
        image != null &&
        image.toString().trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary
                .withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),

      child: Row(
        children: [
          // =======================================================
          // AVATAR
          // =======================================================

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(3),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.28),
                    width: 2,
                  ),
                ),

                child: CircleAvatar(
                  backgroundColor:
                      Colors.white.withOpacity(0.12),
                  backgroundImage: hasImage
                      ? NetworkImage(
                          image.toString(),
                        )
                      : null,
                  child: !hasImage
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 31,
                        )
                      : null,
                ),
              ),

              Positioned(
                right: -3,
                bottom: -2,
                child: Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.warning,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.secondary,
                      width: 3,
                    ),
                  ),
                  child: const Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          // =======================================================
          // DETAILS
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextWidget(
                  name.toString(),
                  size: 18,
                  weight: FontWeight.w900,
                  color: Colors.white,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                TextWidget(
                  "Current leader",
                  size: 11.5,
                  color: Colors.white
                      .withOpacity(0.65),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 17,
                            color:
                                AppColor.warning,
                          ),
                          const SizedBox(width: 5),
                          TextWidget(
                            "$xp XP",
                            size: 12,
                            weight:
                                FontWeight.w900,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.09),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: AppColor.warning,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// #2 + #3 CARDS
// =================================================================

class _RunnerCard extends StatelessWidget {
  const _RunnerCard({
    required this.rank,
    required this.user,
  });

  final int rank;
  final QueryDocumentSnapshot user;

  @override
  Widget build(BuildContext context) {
    final data =
        user.data() as Map<String, dynamic>;

    final name =
        data['name'] ?? 'User';

    final xp =
        data['totalXP'] ?? 0;

    final image =
        data['profileImage'];

    final hasImage =
        image != null &&
        image.toString().trim().isNotEmpty;

    final accent = rank == 2
        ? AppColor.info
        : AppColor.warning;

    return Container(
      height: 176,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color:
                      accent.withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Text(
                  "#$rank",
                  style: TextStyle(
                    color: accent,
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                rank == 2
                    ? Icons
                        .military_tech_outlined
                    : Icons
                        .workspace_premium_outlined,
                size: 20,
                color: accent,
              ),
            ],
          ),

          const Spacer(),

          CircleAvatar(
            radius: 26,
            backgroundColor:
                accent.withOpacity(0.10),
            backgroundImage: hasImage
                ? NetworkImage(
                    image.toString(),
                  )
                : null,
            child: !hasImage
                ? Icon(
                    Icons.person_rounded,
                    color: accent,
                    size: 24,
                  )
                : null,
          ),

          const SizedBox(height: 10),

          TextWidget(
            name.toString(),
            size: 13.5,
            weight: FontWeight.w900,
            color: AppColor.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 3),

          TextWidget(
            "$xp XP",
            size: 11,
            weight: FontWeight.w800,
            color: accent,
          ),
        ],
      ),
    );
  }
}

// =================================================================
// NORMAL RANKING ROW
// =================================================================

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.name,
    required this.xp,
    this.image,
  });

  final int rank;
  final String name;
  final int xp;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        image != null &&
        image!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColor.border,
        ),
      ),

      child: Row(
        children: [
          // =======================================================
          // RANK
          // =======================================================

          SizedBox(
            width: 34,
            child: TextWidget(
              rank.toString().padLeft(2, '0'),
              size: 12,
              weight: FontWeight.w900,
              color: AppColor.textMuted,
            ),
          ),

          // =======================================================
          // AVATAR
          // =======================================================

          CircleAvatar(
            radius: 21,
            backgroundColor:
                AppColor.primarySoft,
            backgroundImage: hasImage
                ? NetworkImage(image!)
                : null,
            child: !hasImage
                ? const Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.primary,
                    size: 20,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // =======================================================
          // NAME
          // =======================================================

          Expanded(
            child: TextWidget(
              name,
              size: 13.5,
              weight: FontWeight.w800,
              color: AppColor.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // =======================================================
          // XP
          // =======================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: AppColor.inputFill,
              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColor.primary,
                  size: 15,
                ),

                const SizedBox(width: 4),

                TextWidget(
                  "$xp",
                  size: 11,
                  weight:
                      FontWeight.w900,
                  color: AppColor.text,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}