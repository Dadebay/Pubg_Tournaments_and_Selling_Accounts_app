import 'dart:developer';

import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/cards/team_member_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/tournament_page/register_show_page.dart';
import 'package:game_app/views/tournament_page/team_registration_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TournamentDetailPage extends StatefulWidget {
  final String? filter;
  final String groupName;
  final Tournament tournament;
  final TeamMember members;
  final String static_g;

  const TournamentDetailPage({
    required this.filter,
    required this.groupName,
    required this.tournament,
    required this.members,
    required this.static_g,
    super.key,
  });

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  @override
  void initState() {
    super.initState();

    log('Fetching team members for tournament ID: ${widget.tournament.id}');

    if (widget.filter == 'yarym_final') {
      Future.microtask(() {
        Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamHalf(
          widget.static_g == 'B2' ? 'ikinji' : 'birinji',
          widget.tournament.id,
        );
      });
    } else if (widget.filter == 'final') {
      Future.microtask(() {
        Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamFinal(widget.tournament.id);
      });
    } else {
      Future.microtask(() {
        Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamGroup(widget.groupName, widget.tournament.id);
      });
    }
  }

  // Helper to format date as dd.MM.yyyy
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null) return '—';
    try {
      final dt = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return '—';
    }
  }

  // Helper to format time as HH:mm
  String formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '—';
    try {
      final dt = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '—';
    }
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
          widget.tournament.nameTm ?? widget.tournament.nameRu ?? 'Tournament',
          style: const TextStyle(
            fontFamily: josefinSansSemiBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<TeamMembersProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament Image
                Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),

                // Tournament Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Time Row
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: kAccentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.filter == 'yarym_final'
                                ? formatDate(widget.members.halfturnir?.startDate)
                                : widget.filter == 'final'
                                    ? formatDate(widget.members.finalturnir?.startDate)
                                    : formatDate(widget.members.quartturnir?.startDate),
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: kAccentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.filter == 'yarym_final'
                                ? '${formatTime(widget.members.halfturnir?.startDate)} - ${formatTime(widget.members.halfturnir?.finishDate)}'
                                : widget.filter == 'final'
                                    ? '${formatTime(widget.members.finalturnir?.startDate)} - ${formatTime(widget.members.finalturnir?.finishDate)}'
                                    : '${formatTime(widget.members.quartturnir?.startDate)} - ${formatTime(widget.members.quartturnir?.finishDate)}',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Map & Price Row
                      Row(
                        children: [
                          const Icon(Icons.map, color: kPrimaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.tournament.map ?? 'Unknown',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.tournament.price} TMT',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Team Members Title
                      Text(
                        widget.filter == 'yarym_final'
                            ? 'Pol Final Team Members'.tr
                            : widget.filter == 'final'
                                ? 'Final Team Members'.tr
                                : 'Team Members'.tr,
                        style: const TextStyle(
                          fontFamily: josefinSansSemiBold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Team Members List
                      if (provider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(color: kPrimaryColor),
                          ),
                        )
                      else if (provider.errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else if (provider.teamMembers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No team members found'.tr,
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.teamMembers.length,
                          itemBuilder: (context, index) {
                            final member = provider.teamMembers[index];

                            return GestureDetector(
                              onTap: () {
                                if (member.user1.isEmpty && member.user2.isEmpty && member.user3.isEmpty) {
                                  Get.to(
                                    () => TeamRegistrationScreen(
                                      tournamentId: widget.tournament.id,
                                      teamMember: member,
                                    ),
                                  );
                                } else {
                                  Get.to(
                                    () => TeamRegistrationScreenDetail(
                                      tournamentId: widget.tournament.id,
                                      teamMember: member,
                                    ),
                                  );
                                }
                              },
                              child: TeamMemberCard(
                                member: member,
                                index: index,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 80), // Space for FAB
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
