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
    // widget.filter == 'tournament'
         Future.microtask(() {
            Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamMembers(widget.tournament.id);
          });
        // : null;
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
          'qarterFinals'.tr,
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

          // Group teams by quartturnir
          // Group teams by quartturnir name
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
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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

                      if (widget.filter == 'final')
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            // final teams = ['B1', 'B2'];
                            // final groupName = teams[index];

                            return QuarterGroupCard(filter: widget.filter, groupName: 'F1', teamCount: 25, 
                            tournament: widget.tournament, members: provider.teamMembers[index]);
                          },
                        ),
                      if (widget.filter == 'yarym_final')
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final teams = ['B1', 'B2'];
                            final groupName = teams[index];

                            return QuarterGroupCard(filter: widget.filter, groupName: groupName, 
                            teamCount: 25, tournament: widget.tournament,
                             members: provider.teamMembers[index]);
                          },
                        ),

                      // Groups Grid
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
                              final teams = groupedTeams[groupName]!;

                              return QuarterGroupCard(filter: widget.filter, 
                              groupName: groupName, teamCount: teams.length,
                               tournament: widget.tournament,
                                members: provider.teamMembers[index]);
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

// ============ QUARTER GROUP CARD ============
class QuarterGroupCard extends StatelessWidget {
  final String? filter;
  final String groupName;
  final int teamCount;
  final Tournament tournament;
  final TeamMember members;

  const QuarterGroupCard({
    required this.filter,
    required this.groupName,
    required this.teamCount,
    required this.tournament,
    required this.members,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Different colors for different groups
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

    final colorIndex = int.tryParse(groupName.replaceAll('A', '')) ?? 0;
    final color = colors[colorIndex % colors.length];

    // Format dates
    final startDateFormat = DateFormat('dd MMM yyyy');
    final startTimeFormat = DateFormat('HH:mm');
    final endDateFormat = DateFormat('dd MMM yyyy');
    final endTimeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () {
        Get.to(
          () => TournamentDetailPage(
            filter: filter,
            tournament: tournament,
            groupName: groupName,
            members: members
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
            // Group Icon/Badge
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

            // Group Info
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
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Start Date & Time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        members.quartturnir?.startDate != null ? startDateFormat.format(members.quartturnir!.startDate!) : '—',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        members.quartturnir?.startDate != null ? startTimeFormat.format(members.quartturnir!.startDate!) : '—',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // End Date & Time
                  Row(
                    children: [
                      Icon(Icons.event_available, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        members.quartturnir?.finishDate != null ? endDateFormat.format(members.quartturnir!.finishDate!) : '—',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        members.quartturnir?.finishDate != null ? endTimeFormat.format(members.quartturnir!.finishDate!) : '—',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

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
              child: Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
