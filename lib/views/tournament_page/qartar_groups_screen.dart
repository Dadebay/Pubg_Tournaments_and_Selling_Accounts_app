import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '$serverURL${widget.tournament.image}';

    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.filter == 'final'
              ? 'final_tournament'.tr
              : widget.filter == 'yarym_final'
                  ? 'pol_final'.tr
                  : 'qarterFinals'.tr,
          style: const TextStyle(
            fontFamily: josefinSansSemiBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<TeamMembersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Group members by quartturnir name
          final Map<String, List<TeamMember>> groupedTeams = {};
          for (var member in provider.teamMembers) {
            final groupName = member.quartturnir?.name ?? '';
            if (groupName.isNotEmpty) {
              groupedTeams.putIfAbsent(groupName, () => []);
              groupedTeams[groupName]!.add(member);
            }
          }

          final sortedGroups = groupedTeams.keys.toList()..sort();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament Header
                Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tournament.nameTm,
                        style: const TextStyle(
                          fontFamily: josefinSansSemiBold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Filters
                      if (widget.filter == 'final')
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            final groupName = sortedGroups[index];
                            final members = groupedTeams[groupName]!;
                            return QuarterGroupCard(
                              filter: widget.filter,
                              groupName: groupName,
                              teamCount: 25,
                              tournament: widget.tournament,
                              member: members.first,
                              static_g: '',
                            );
                          },
                        ),

                      if (widget.filter == 'yarym_final')
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final groupName = sortedGroups[index];
                            final members = groupedTeams[groupName]!;
                            // final teams = ['B1', 'B2'];
                            // final groupName = teams[index];
                            // final member = provider.teamMembers[index];

                            return QuarterGroupCard(
                              filter: widget.filter,
                              groupName: groupName,
                              teamCount: 25,
                              tournament: widget.tournament,
                              member: members.first,
                              static_g: index == 0 ? '' : 'B2',
                            );
                          },
                        ),

                      if (widget.filter == 'tournament')
                        if (sortedGroups.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'noGroupsFound'.tr,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedGroups.length,
                            itemBuilder: (context, index) {
                              final groupName = sortedGroups[index];
                              final members = groupedTeams[groupName]!;

                              return QuarterGroupCard(
                                filter: widget.filter,
                                groupName: groupName,
                                teamCount: members.length,
                                tournament: widget.tournament,
                                member: members.first,
                                static_g: '', // take first member
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

  const QuarterGroupCard({
    required this.filter,
    required this.groupName,
    required this.teamCount,
    required this.tournament,
    required this.member,
    required this.static_g,
    super.key,
  });

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
    final colors = [
      filter == 'final' ? Colors.green : Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    final colorIndex = int.tryParse(groupName.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final color = colors[colorIndex % colors.length];
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
        Get.to(
          () => TournamentDetailPage(
            filter: filter,
            tournament: tournament,
            groupName: groupName,
            members: member,
            static_g: static_g,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.25),
              color.withOpacity(0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            // Group Circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(
                  groupName,
                  style: TextStyle(
                    fontFamily: josefinSansSemiBold,
                    fontSize: 26,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'group'.tr}$groupName',
                    style: const TextStyle(
                      fontFamily: josefinSansSemiBold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.groups, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        '$teamCount ${teamCount == 1 ? 'Team'.tr : 'Team'.tr}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Start Time
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        dataDay,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.play_arrow, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Açyldy: $start',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Finish Time
                  Row(
                    children: [
                      Icon(Icons.flag, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Başlanýar: $finish',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stage Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      filter == 'yarym_final'
                          ? 'pol_final'.tr
                          : filter == 'final'
                              ? 'final_tournament'.tr
                              : 'qarterFinals'.tr,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
