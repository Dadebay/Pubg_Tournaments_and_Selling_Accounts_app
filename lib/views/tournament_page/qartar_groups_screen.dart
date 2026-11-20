import 'dart:async';

import 'package:material_ui/material_ui.dart';
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
                      cards.add(QuarterGroupCard(filter: widget.filter, groupName: sortedGroups[0], teamCount: 25, tournament: widget.tournament, member: groupedTeams[sortedGroups[0]]!.first, static_g: ''));
                    }
                  } else if (widget.filter == 'yarym_final') {
                    for (var i = 0; i < 2 && i < sortedGroups.length; i++) {
                      cards.add(QuarterGroupCard(filter: widget.filter, groupName: sortedGroups[i], teamCount: 25, tournament: widget.tournament, member: groupedTeams[sortedGroups[i]]!.first, static_g: i == 0 ? '' : 'B2'));
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
    final QuartTurnir? stageData = filter == 'yarym_final'
        ? member.halfturnir
        : filter == 'final'
        ? member.finalturnir
        : member.quartturnir;

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

    final stage = filter == 'yarym_final'
        ? 'pol_final'.tr
        : filter == 'final'
        ? 'final_tournament'.tr
        : 'qarterFinals'.tr;

    return GestureDetector(
      onTap: () {
        Get.to(() => TournamentDetailPage(filter: filter, tournament: tournament, groupName: groupName, members: member, static_g: static_g));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        // Clipped to the rounded corners, so the colored edge follows the border.
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: const Color(0xFF1B1B1E),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), color: color.withValues(alpha: 0.18)),
                            child: Text(
                              groupName,
                              style: TextStyle(fontFamily: gilroyBold, fontSize: 21, color: color),
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
                                  style: const TextStyle(fontFamily: gilroyBold, fontSize: 19, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: gilroyMedium, fontSize: 13, color: Color(0xFFB8B8C0)),
                                ),
                              ],
                            ),
                          ),
                          const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white38, size: 20, strokeWidth: 2),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _info(color, HugeIcons.strokeRoundedCalendar03, dataDay)),
                          const SizedBox(width: 8),
                          Expanded(child: _info(color, HugeIcons.strokeRoundedClock01, '$start - $finish')),
                          const SizedBox(width: 8),
                          Expanded(child: _info(color, HugeIcons.strokeRoundedUserGroup, '$teamCount ${'Team'.tr}')),
                        ],
                      ),
                      _StartCountdown(color: color, start: DateTime.tryParse(stageData?.startDate ?? ''), finish: DateTime.tryParse(stageData?.finishDate ?? '')),
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

  /// A small tile of the card: a tinted icon over its value.
  Widget _info(Color color, List<List<dynamic>> icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: color, size: 18, strokeWidth: 1.8),
          const SizedBox(height: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// How long is left until the stage starts, ticking every second. While it runs it says
/// so, and once it is over it says it ended. Nothing is shown when the start is unknown.
class _StartCountdown extends StatefulWidget {
  const _StartCountdown({required this.color, required this.start, required this.finish});

  final Color color;
  final DateTime? start;
  final DateTime? finish;

  @override
  State<_StartCountdown> createState() => _StartCountdownState();
}

class _StartCountdownState extends State<_StartCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final start = widget.start?.toLocal();
    if (start == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final finish = widget.finish?.toLocal();
    final left = start.difference(now);
    final String label;
    final String value;
    Color tone = widget.color;
    if (left > Duration.zero) {
      label = 'startsIn'.tr;
      final days = left.inDays;
      final clock = '${_two(left.inHours % 24)}:${_two(left.inMinutes % 60)}:${_two(left.inSeconds % 60)}';
      value = days > 0 ? '$days ${'premiumDays'.tr}  $clock' : clock;
    } else if (finish != null && now.isAfter(finish)) {
      // A finished stage has nothing left to count, so nothing is shown.
      return const SizedBox.shrink();
    } else {
      label = '';
      value = 'stageLive'.tr;
      tone = const Color(0xFF34D399);
    }
    return Container(
      // The gap above lives here, so a hidden strip leaves no empty space.
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: tone.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedTimer02, color: tone, size: 18, strokeWidth: 1.8),
          const SizedBox(width: 8),
          if (label.isNotEmpty)
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFD0D0D6), fontFamily: gilroyMedium, fontSize: 13),
              ),
            )
          else
            const Spacer(),
          Text(
            value,
            style: TextStyle(color: tone, fontFamily: gilroyBold, fontSize: 15, height: 1.1, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
