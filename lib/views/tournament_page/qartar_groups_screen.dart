import 'package:flutter/material.dart';
import 'package:game_app/views/cards/tournament_image.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/tournament_page/tournament_detail_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class QuarterGroupsScreen extends StatefulWidget {
  final Tournament tournament;
  final String? filter;

  const QuarterGroupsScreen({required this.filter, required this.tournament, super.key});

  @override
  State<QuarterGroupsScreen> createState() => _QuarterGroupsScreenState();
}

class _QuarterGroupsScreenState extends State<QuarterGroupsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamMembers(widget.tournament.id);
    });
  }

  String get _title => widget.filter == 'final'
      ? 'final_tournament'.tr
      : widget.filter == 'yarym_final'
      ? 'pol_final'.tr
      : 'qarterFinals'.tr;

  @override
  Widget build(BuildContext context) {
    final imageUrl = tournamentImageUrl(widget.tournament.image);

    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: _title, onBack: Get.back, trailing: const BalanceChip()),
            Expanded(
              child: Consumer<TeamMembersProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                  }
                  if (provider.errorMessage != null) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.cloud_off_rounded, title: provider.errorMessage!, description: ''),
                    );
                  }

                  // Group members by quartturnir name
                  final Map<String, List<TeamMember>> groupedTeams = {};
                  for (final member in provider.teamMembers) {
                    final groupName = member.quartturnir?.name ?? '';
                    if (groupName.isNotEmpty) {
                      groupedTeams.putIfAbsent(groupName, () => []);
                      groupedTeams[groupName]!.add(member);
                    }
                  }
                  final sortedGroups = groupedTeams.keys.toList()..sort();

                  final cards = <Widget>[];
                  if (widget.filter == 'final') {
                    if (sortedGroups.isNotEmpty) {
                      cards.add(
                        QuarterGroupCard(filter: widget.filter, groupName: sortedGroups[0], teamCount: 25, tournament: widget.tournament, member: groupedTeams[sortedGroups[0]]!.first, static_g: ''),
                      );
                    }
                  } else if (widget.filter == 'yarym_final') {
                    for (var i = 0; i < 2 && i < sortedGroups.length; i++) {
                      cards.add(
                        QuarterGroupCard(
                          filter: widget.filter,
                          groupName: sortedGroups[i],
                          teamCount: 25,
                          tournament: widget.tournament,
                          member: groupedTeams[sortedGroups[i]]!.first,
                          static_g: i == 0 ? '' : 'B2',
                        ),
                      );
                    }
                  } else {
                    for (final groupName in sortedGroups) {
                      final members = groupedTeams[groupName]!;
                      cards.add(QuarterGroupCard(filter: widget.filter, groupName: groupName, teamCount: members.length, tournament: widget.tournament, member: members.first, static_g: ''));
                    }
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    children: [
                      _hero(imageUrl),
                      const SizedBox(height: 18),
                      if (cards.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: CatalogEmptyState(icon: Icons.groups_outlined, title: 'noGroupsFound'.tr, description: ''),
                          ),
                        )
                      else
                        ...cards,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The poster has its own lettering, so it is shown clean and the name goes below it.
  Widget _hero(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: AspectRatio(
            aspectRatio: 1.9,
            child: TournamentImage(
              imageUrl: imageUrl,
              fallbackAsset: tournamentFallbackAsset(finished: false, id: widget.tournament.id),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            widget.tournament.nameTm,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22, height: 1.1),
          ),
        ),
      ],
    );
  }
}

class QuarterGroupCard extends StatelessWidget {
  final String? filter;
  final String groupName;
  final int teamCount;
  final Tournament tournament;
  final TeamMember member;
  final String static_g;

  const QuarterGroupCard({required this.filter, required this.groupName, required this.teamCount, required this.tournament, required this.member, required this.static_g, super.key});

  // Only show HH:mm
  String formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '—';
    try {
      final dt = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dt.toLocal());
    } catch (_) {
      return '—';
    }
  }

  String formatDate(String? dateTimeString) {
    if (dateTimeString == null) return '—';
    try {
      final dt = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFFFFC83D), Color(0xFF60A5FA), Color(0xFF34D399), Color(0xFFA78BFA), Color(0xFFFF5A5F), Color(0xFF2DD4BF), Color(0xFFF472B6), Color(0xFFFF9800)];
    final colorIndex = int.tryParse(groupName.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final color = filter == 'final' ? const Color(0xFF34D399) : colors[colorIndex % colors.length];
    final String start;
    final String finish;
    final String dataDay;

    if (filter == 'yarym_final') {
      start = formatTime(member.halfturnir?.startDate);
      finish = formatTime(member.halfturnir?.finishDate);
      dataDay = formatDate(member.halfturnir?.startDate);
    } else if (filter == 'final') {
      start = formatTime(member.finalturnir?.startDate);
      finish = formatTime(member.finalturnir?.finishDate);
      dataDay = formatDate(member.finalturnir?.startDate);
    } else {
      start = formatTime(member.quartturnir?.startDate);
      finish = formatTime(member.quartturnir?.finishDate);
      dataDay = formatDate(member.quartturnir?.startDate);
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => TournamentDetailPage(filter: filter, tournament: tournament, groupName: groupName, members: member, static_g: static_g));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF151517)]),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A colored edge tells the groups apart without coloring the whole card.
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), color: color.withValues(alpha: 0.15)),
                        child: Text(
                          groupName,
                          style: TextStyle(fontFamily: gilroyBold, fontSize: 22, color: color),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'group'.tr}$groupName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: gilroyBold, fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, color: Color(0xFF8E8E98), size: 14, strokeWidth: 1.8),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '$dataDay · $start-$finish',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$teamCount',
                            style: TextStyle(fontFamily: gilroyBold, fontSize: 20, color: color, height: 1),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Team'.tr,
                            style: const TextStyle(fontFamily: gilroyMedium, fontSize: 11, color: Color(0xFF8E8E98), height: 1),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white38, size: 20, strokeWidth: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
