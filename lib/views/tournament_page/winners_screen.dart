import 'package:game_app/models/team_winers.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

const _gold = Color(0xFFFFC83D);
const _medals = [Color(0xFFFFC83D), Color(0xFFD5D9E0), Color(0xFFE0955A)];

class WinnersScreen extends StatefulWidget {
  final String? filter;
  final Tournament tournament;

  const WinnersScreen({required this.filter, required this.tournament, super.key});

  @override
  State<WinnersScreen> createState() => _WinnersScreenState();
}

class _WinnersScreenState extends State<WinnersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamWinner(widget.tournament.id);
    });
  }

  Future<void> _reload() => Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamWinner(widget.tournament.id);

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamMembersProvider>(context);
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'prizeWinners'.tr, onBack: Get.back, trailing: const BalanceChip()),
            Expanded(child: _body(teamProvider.isLoading, teamProvider.errorMessage, teamProvider.teamMembersWin)),
          ],
        ),
      ),
    );
  }

  Widget _body(bool isLoading, String? errorMessage, List<TeamMemberWin> winners) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: _gold));
    }
    if (errorMessage != null) {
      return Center(
        child: CatalogEmptyState(icon: Icons.cloud_off_rounded, title: errorMessage, description: '', actionLabel: 'Retry', actionIcon: Icons.refresh_rounded, onAction: _reload),
      );
    }
    if (winners.isEmpty && widget.tournament.bayrak == null) {
      return Center(
        child: CatalogEmptyState(icon: Icons.emoji_events_outlined, title: 'No Winners Yet'.tr, description: 'Winners will be announced soon'.tr),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      color: _gold,
      backgroundColor: const Color(0xFF1C1C20),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [_tournamentCard(widget.tournament), const SizedBox(height: 20), for (var i = 0; i < winners.length; i++) _winnerRow(winners[i], i)],
      ),
    );
  }

  Widget _tournamentCard(Tournament tournament) {
    final given = tournament.bayrak != null;
    final prize = tournament.bayrak ?? tournament.price;
    final color = given ? const Color(0xFF34D399) : _gold;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(alpha: 0.16),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: const Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 26, strokeWidth: 1.8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.nameTm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21, height: 1.1),
                    ),
                    if (tournament.map.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tournament.map,
                        style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(given ? Icons.check_circle_rounded : Icons.schedule_rounded, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$prize TMT',
                    style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _winnerRow(TeamMemberWin team, int index) {
    final medal = index < 3 ? _medals[index] : null;
    final color = medal ?? Colors.white70;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (medal ?? Colors.white).withValues(alpha: medal == null ? 0.07 : 0.35)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [medal == null ? const Color(0xFF232327) : medal.withValues(alpha: 0.16), const Color(0xFF161618)]),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: index == 0
                ? HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: color, size: 20, strokeWidth: 1.8)
                : Text(
                    '${index + 1}',
                    style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 17),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              team.name ?? 'Unnamed Team',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
