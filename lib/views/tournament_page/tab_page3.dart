// ignore_for_file: file_names

import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/tournament_page/gatnashyanlar.dart';
import 'package:game_app/views/tournament_page/winners_all.dart';
import 'package:intl/intl.dart';

import '../constants/index.dart';

class TabPage3 extends StatefulWidget {
  final TournamentModel model;
  final int tournamentType;
  final bool finised;
  final TeamUsers teams;
  final int tournamentId;

  const TabPage3({required this.model, required this.finised, required this.tournamentType, required this.teams, required this.tournamentId, super.key});

  @override
  State<TabPage3> createState() => _TabPage3State();
}

class _TabPage3State extends State<TabPage3> {
  final List<Teams> teamUsers = [];
  late final String dateNow;
  late final String dateTurnir;
  late final DateTime dt1;
  late final DateTime dt2;

  @override
  void initState() {
    super.initState();
    for (var e in widget.model.teams!) {
      if (e.teamUsers!.isNotEmpty) {
        teamUsers.add(e);
      }
    }
    final now = DateTime.now();
    final turnirF = widget.model.finish_date;

    final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    dateNow = formatter.format(now);

    final dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(turnirF!);
    dateTurnir = formatter.format(dateTime);
    dt1 = DateTime.parse(dateNow);
    dt2 = DateTime.parse(dateTurnir);
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
    final itemCount = widget.model.winners!.isEmpty ? teamUsers.length : widget.model.winners!.length;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        if (widget.model.winners!.isEmpty && dt1.isBefore(dt2)) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Gatnashyanlatr(
              teams: teamUsers[index],
              usersCount: getUsersCount(widget.model.type!),
              teamID: teamUsers[index].id.toString(),
              turnirType: widget.model.type!,
              turnirID: widget.tournamentId.toString(),
            ),
          );
        }
        if (widget.model.winners!.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: WinnersAll(winners: widget.model.winners![index], team_users: widget.teams, usersCount: getUsersCount(widget.model.type!)),
          );
        }
        return Container();
      },
    );
  }
}
