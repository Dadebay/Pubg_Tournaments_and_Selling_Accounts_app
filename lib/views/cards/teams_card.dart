import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/constants/index.dart';

// ignore: must_be_immutable
class TeamsCard extends StatefulWidget {
  late Teams team;
  late String turnirType;
  TeamsCard({required this.team, required this.turnirType, super.key});

  @override
  State<TeamsCard> createState() => _TeamsCardState();
}

class _TeamsCardState extends State<TeamsCard> {
  List myList = [0, 1, 2, 3];
  late int usersCount = 3;

  @override
  void initState() {
    setState(() {
      usersCount = widget.turnirType == 'SOLO'
          ? 1
          : widget.turnirType == 'DUO'
          ? 2
          : widget.turnirType == 'SQUAD'
          ? 4
          : 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [for (TeamUsers i in widget.team.teamUsers!) Text(i.id.toString()), for (var i in myList.sublist(0, usersCount - widget.team.teamUsers!.length)) Text(i.toString())]);
  }
}
