import 'package:game_app/models/accouts_for_sale_model.dart';

import '../../models/tournament_model.dart';
import '../cards/gatnashyanlar_card.dart';
import '../constants/index.dart';

// ignore: must_be_immutable
class Gatnashyanlatr extends StatefulWidget {
  late Teams teams;
  late Awards awards;

  late Teams teamUsers;
  late int usersCount;
  final String teamID;
  final String turnirID;
  final String turnirType;

  Gatnashyanlatr({required this.teams, required this.usersCount, required this.teamID, required this.turnirType, required this.turnirID, super.key});

  @override
  State<Gatnashyanlatr> createState() => _GatnashyanlatrState();
}

class _GatnashyanlatrState extends State<Gatnashyanlatr> {
  @override
  void initState() {
    super.initState();
    findUser();
  }

  String userID = '';
  bool showButton = false;
  dynamic findUser() async {
    await PostByIdModel().getMe().then((value) {
      userID = value.pubgId.toString();
    });
    for (var element in widget.teams.teamUsers!) {
      if (element.user!.pubgId == userID) {
        showButton = true;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.teams.teamUsers!;
    return TeamShell(
      number: widget.teams.number,
      filled: users.length,
      total: widget.usersCount,
      mine: showButton,
      children: [
        for (var i = 0; i < widget.usersCount; i++)
          users.length >= i + 1 ? GatnashyanlarCard(teamUsers: users[i], teamID: widget.teamID, showButton: showButton, turnirID: widget.turnirID) : const TeamEmptySlot(),
      ],
    );
  }
}
