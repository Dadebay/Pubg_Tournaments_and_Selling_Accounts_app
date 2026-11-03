import 'dart:developer';

import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/cards/team_member_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/tournament_page/register_show_page.dart';
import 'package:game_app/views/tournament_page/team_registration_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TournamentDetailPage extends StatefulWidget {
  final String? filter;
  final String groupName;
  final Tournament tournament;
  final TeamMember members;
  final String static_g;

  const TournamentDetailPage({required this.filter, required this.groupName, required this.tournament, required this.members, required this.static_g, super.key});

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
        Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamHalf(widget.static_g == 'B2' ? 'ikinji' : 'birinji', widget.tournament.id);
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

  String _range(QuartTurnir? stage) => '${formatTime(stage?.startDate)} - ${formatTime(stage?.finishDate)}';

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '$serverURL${widget.tournament.image}';
    final stage = widget.filter == 'yarym_final'
        ? widget.members.halfturnir
        : widget.filter == 'final'
        ? widget.members.finalturnir
        : widget.members.quartturnir;
    final title = widget.filter == 'yarym_final'
        ? 'Pol Final Team Members'.tr
        : widget.filter == 'final'
        ? 'Final Team Members'.tr
        : 'Team Members'.tr;

    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: widget.tournament.nameTm.isNotEmpty ? widget.tournament.nameTm : widget.tournament.nameRu, onBack: Get.back, trailing: const BalanceChip()),
            Expanded(
              child: Consumer<TeamMembersProvider>(
                builder: (context, provider, child) {
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    children: [
                      // The poster has its own lettering, so only the price badge sits on it.
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: AspectRatio(
                          aspectRatio: 1.9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const ColoredBox(color: Color(0xFF1B1B1E)),
                                errorWidget: (context, url, error) => const ColoredBox(color: Color(0xFF1B1B1E)),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                                  ),
                                  child: Text('${widget.tournament.price} TMT', style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 14, height: 1.1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFC83D).withValues(alpha: 0.28)),
                          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2416), Color(0xFF141416)]),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), color: const Color(0xFFFFC83D).withValues(alpha: 0.16)),
                                  child: Text(widget.groupName, style: const TextStyle(fontFamily: gilroyBold, fontSize: 21, color: Color(0xFFFFC83D))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.tournament.nameTm.isNotEmpty ? widget.tournament.nameTm : widget.tournament.nameRu, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: gilroyBold, fontSize: 18, color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(title, style: const TextStyle(fontFamily: gilroyMedium, fontSize: 13, color: Color(0xFFB8B8C0))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _info(HugeIcons.strokeRoundedCalendar03, formatDate(stage?.startDate))),
                                const SizedBox(width: 8),
                                Expanded(child: _info(HugeIcons.strokeRoundedClock01, _range(stage))),
                                const SizedBox(width: 8),
                                Expanded(child: _info(HugeIcons.strokeRoundedMapsLocation01, widget.tournament.map.isEmpty ? '-' : widget.tournament.map)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: Text(title, style: const TextStyle(fontFamily: gilroyBold, fontSize: 20, color: Colors.white))),
                          if (!provider.isLoading && provider.teamMembers.isNotEmpty) _slots(provider.teamMembers),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (provider.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                        )
                      else if (provider.errorMessage != null)
                        CatalogEmptyState(icon: Icons.cloud_off_rounded, title: provider.errorMessage!, description: '')
                      else if (provider.teamMembers.isEmpty)
                        CatalogEmptyState(icon: Icons.groups_outlined, title: 'No team members found'.tr, description: '')
                      else
                        for (var index = 0; index < provider.teamMembers.length; index++)
                          GestureDetector(
                            onTap: () {
                              final member = provider.teamMembers[index];
                              if (member.user1.isEmpty && member.user2.isEmpty && member.user3.isEmpty) {
                                Get.to(() => TeamRegistrationScreen(tournamentId: widget.tournament.id, teamMember: member));
                              } else {
                                Get.to(() => TeamRegistrationScreenDetail(tournamentId: widget.tournament.id, teamMember: member));
                              }
                            },
                            child: TeamMemberCard(member: provider.teamMembers[index], index: index),
                          ),
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

  /// "3 / 25": the teams that are already filled out of all.
  Widget _slots(List<TeamMember> teams) {
    final taken = teams.where((m) => m.user1.isNotEmpty || m.user2.isNotEmpty || m.user3.isNotEmpty).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFFC83D).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
      child: Text('$taken / ${teams.length}', style: const TextStyle(color: Color(0xFFFFC83D), fontFamily: gilroyBold, fontSize: 14, height: 1.1)),
    );
  }

  Widget _info(List<List<dynamic>> icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: const Color(0xFFFFC83D), size: 18, strokeWidth: 1.8),
          const SizedBox(height: 6),
          Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 12.5)),
        ],
      ),
    );
  }
}
