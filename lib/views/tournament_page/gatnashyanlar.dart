import 'package:game_app/models/accouts_for_sale_model.dart';

import '../../models/tournament_model.dart';
import '../cards/empty_users_card.dart';
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

  Gatnashyanlatr({
    required this.teams,
    required this.usersCount,
    required this.teamID,
    required this.turnirType,
    required this.turnirID,
    super.key,
  });

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kPrimaryColorBlack,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(25)), side: BorderSide(width: showButton ? 3 : 1, color: showButton ? kPrimaryColor : kPrimaryColor.withOpacity(0.4))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, left: showButton ? 20 : 0, right: showButton ? 20 : 0),
            child: teamText(),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  for (var i = 0; i < widget.usersCount; i++)
                    widget.teams.teamUsers!.length >= i + 1
                        ? GatnashyanlarCard(
                            teamUsers: widget.teams.teamUsers![i],
                            teamID: widget.teamID,
                            showButton: showButton,
                            turnirID: widget.turnirID,
                          )
                        : const EmptyUsersCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row teamText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Team: ',
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: gilroyBold),
        ),
        Text(
          widget.teams.number.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
