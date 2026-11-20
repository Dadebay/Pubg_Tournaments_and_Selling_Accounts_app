// ignore_for_file: file_names

import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/tournament_page/gatnashyanlar.dart';
import 'package:game_app/views/tournament_page/winners_all.dart';

import '../constants/catalog_empty_state.dart';
import '../constants/index.dart';

class TabPage3 extends StatefulWidget {
  final TournamentModel model;
  final int tournamentType;
  final bool finised;
  final TeamUsers teams;
  final int tournamentId;

  const TabPage3({
    required this.model,
    required this.finised,
    required this.tournamentType,
    required this.teams,
    required this.tournamentId,
    super.key,
  });

  @override
  State<TabPage3> createState() => _TabPage3State();
}

class _TabPage3State extends State<TabPage3> {
  final List<Teams> teamUsers = [];

  @override
  void initState() {
    super.initState();
    for (var e in widget.model.teams!) {
      if (e.teamUsers!.isNotEmpty) {
        teamUsers.add(e);
      }
    }
  }

  int getUsersCount(String type) {
    switch (type) {
      case 'solo':
        return 1;
      case 'duo':
        return 2;
      case 'squad':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final winners = widget.model.winners ?? const <Winners>[];
    // The winners once they are known, otherwise the teams that have players. This does not depend
    // on the date: a finished tournament with no winners yet still shows who took part.
    final showWinners = winners.isNotEmpty;
    final itemCount = showWinners ? winners.length : teamUsers.length;
    if (itemCount == 0) {
      return Center(
        child: CatalogEmptyState(
          icon: Icons.groups_outlined,
          title: 'tournamentInfo13'.tr,
          description: '',
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: showWinners
              ? WinnersAll(
                  winners: winners[index],
                  team_users: widget.teams,
                  usersCount: getUsersCount(widget.model.type!),
                )
              : Gatnashyanlatr(
                  teams: teamUsers[index],
                  usersCount: getUsersCount(widget.model.type!),
                  teamID: teamUsers[index].id.toString(),
                  turnirType: widget.model.type!,
                  turnirID: widget.tournamentId.toString(),
                ),
        );
      },
    );
  }
}
