import 'dart:async';

import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/cards/card_teams_widget.dart';
import 'package:game_app/views/constants/index.dart';

// ignore: must_be_immutable
class SellctTeam extends StatefulWidget {
  SellctTeam({required this.turnir, super.key});

  TournamentModel turnir;

  @override
  State<SellctTeam> createState() => _SellctTeamState();
}

class _SellctTeamState extends State<SellctTeam> {
  int id = 1;
  int selectedTeam = 0;

  Function selectTeam(int id) {
    setState(() {
      selectedTeam = id;
    });
    return selectTeam(id);
  }

  void backTurnir() {
    setState(() {
      Timer(
        const Duration(seconds: 3),
        () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BottomNavBar(
                showPages: false,
              ),
            ),
            (route) => false,
          );
        },
      );
    });
  }

  dynamic enterSQUADIDS() {
    final List<TextEditingController> controllers = [
      TextEditingController(), // controller
      TextEditingController(), // controller1
      TextEditingController(), // controller3
    ];

    final List<FocusNode> focusNode = [
      FocusNode(), // focusNode
      FocusNode(), // focusNode1
      FocusNode(), // focusNode2
      FocusNode(), // focusNode3
    ];

    Get.defaultDialog(
      title: 'buySQUAD3'.tr,
      titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: List.generate(widget.turnir.type == 'squad' ? 3 : 1, (index) {
              return CustomTextField(labelName: '${index + 2} - ${'buySQUAD4'.tr}', borderRadius: true, controller: controllers[index], focusNode: focusNode[index], requestfocusNode: focusNode[index + 1], isNumber: false);
            }),
          ),
          const SizedBox(
            height: 15,
          ),
          AgreeButton(
            onTap: () async {
              if (widget.turnir.type == 'squad') {
                await TournamentModel()
                    .participateTournamentSQUAD(
                  teamId: selectedTeam,
                  pubgID1: controllers[0].text.toString(),
                  pubgID2: controllers[1].text.toString(),
                  pubgID3: controllers[2].text.toString(),
                )
                    .then((value) {
                  if (value == 200) {
                    backTurnir();
                  }
                });
              } else {
                await TournamentModel().participateTournamentDUAL(teamId: selectedTeam, pubgID1: controllers[0].text.toString()).then((value) {
                  if (value == 200) {
                    backTurnir();
                  }
                });
              }
            },
            name: 'agree',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(fontSize: 18, backArrow: true, iconRemove: false, name: 'Teams', elevationWhite: true),
      floatingActionButton: GestureDetector(
        onTap: () {
          selectedTeam == 0 ? showSnackBar('Üns beriň!', 'Team Saýlaň!', Colors.red) : enterSQUADIDS();

          // Get.defaultDialog(
          //   backgroundColor: kPrimaryColorBlack,
          //   title: 'buySQUAD'.tr,
          //   titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 23),
          //   content: Column(
          //     children: [
          //       // AgreeButton(
          //       //   onTap: () {
          //       //     // Uri.parse('$serverURL/api/turnirs/participate/'),
          //       //     TournamentModel().participateTournamentPost(teamId: selectedTeam).then((value) {
          //       //       // ignore: unnecessary_statements
          //       //       value == 200 ? backTurnir() : null;
          //       //     });
          //       //   },
          //       //   name: 'buySQUAD1',
          //       // ),
          //       AgreeButton(
          //         onTap: () {
          //           enterSQUADIDS();
          //         },
          //         name: widget.turnir.type == 'squad' ? 'buySQUAD2' : 'buySQUAD22',
          //       ),
          //     ],
          //   ),
          // );
        },
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
            alignment: Alignment.center,
            child: Text(
              'agree'.tr,
              style: TextStyle(fontSize: 20, fontFamily: josefinSansBold, color: Colors.amber[800]),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView.builder(
        itemCount: widget.turnir.teams!.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: CardTeamsAll(
              teams: widget.turnir.teams![index],
              selectedTeam: selectedTeam,
              selectTeam: (int id) {
                setState(() {
                  selectedTeam = id;
                });
              },
              usersCount: widget.turnir.type! == 'solo'
                  ? 1
                  : widget.turnir.type! == 'duo'
                      ? 2
                      : widget.turnir.type! == 'squad'
                          ? 4
                          : 0,
            ),
          );
        },
      ),
    );
  }
}
