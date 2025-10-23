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

class TournamentDetailPage extends StatefulWidget {
  final String? filter;
  final String groupName;
  final Tournament tournament;
  final TeamMember members;

  const TournamentDetailPage({required this.filter, required this.groupName, required this.tournament, required this.members, super.key});

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  @override
  void initState() {
    super.initState();
    log('Fetching team members for tournament ID: ${widget.filter}');

    widget.filter == 'yarym_final'
        ? Future.microtask(() {
            Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamHalf(widget.groupName == 'B2' ? 'ikinji' : 'birinji');
          })
        : widget.filter == 'final'
            ? Future.microtask(() {
                Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamFinal();
              })
            : Future.microtask(() {
                Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamGroup(widget.groupName);
              });
  }

  // void _showRegisterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => TeamRegistrationDialog(
  //       tournamentId: widget.tournament.id,
  //     ),
  //   );
  // }

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
                // Tournament Header
                Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),

                // Tournament Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today, // 📅 Date icon
                            size: 18,
                            color: kAccentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('dd.MM.yyyy').format(DateTime.parse(widget.members.quartturnir!.startDate.toString()))} - ${DateFormat('dd.MM.yyyy').format(DateTime.parse(widget.members.quartturnir!.finishDate.toString()))}',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time, // ⏰ Clock icon
                            size: 18,
                            color: kAccentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('HH:mm').format(DateTime.parse(widget.members.quartturnir!.startDate.toString()))} - ${DateFormat('HH:mm').format(DateTime.parse(widget.members.quartturnir!.finishDate.toString()))}',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                      // Team Members Section
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

                      // Loading / Error / Data
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
                              child: TeamMemberCard(member: member, index: index),
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
