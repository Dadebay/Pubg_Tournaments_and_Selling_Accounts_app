import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/views/constants/index.dart';

import '../../models/tournament_model.dart';

// ignore: must_be_immutable
class GatnashyanlarCard extends StatefulWidget {
  // late Teams team;
  late TeamUsers teamUsers;
  late String turnirType;
  final String teamID;
  final String turnirID;
  final bool showButton;
  GatnashyanlarCard({required this.teamUsers, required this.teamID, required this.showButton, required this.turnirID, super.key});

  @override
  State<GatnashyanlarCard> createState() => _GatnashyanlarCardState();
}

class _GatnashyanlarCardState extends State<GatnashyanlarCard> {
  dynamic enterSQUADIDS() {
    final TextEditingController controllers = TextEditingController();
    final FocusNode focusNode = FocusNode();

    Get.defaultDialog(
      title: 'buySQUAD3'.tr,
      titleStyle: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 22),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(labelName: '${1} - ${'buySQUAD4'.tr}', borderRadius: true, controller: controllers, focusNode: focusNode, requestfocusNode: focusNode, isNumber: false),
          const SizedBox(
            height: 15,
          ),
          AgreeButton(
            onTap: () async {
              await TournamentModel()
                  .editSQUAD(
                turnirID: int.parse(widget.turnirID.toString()),
                pubgID1: controllers.text.toString(),
                id: int.parse(widget.teamUsers.id.toString()),
              )
                  .then((value) {
                if (value == 200) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const BottomNavBar(
                        showPages: false,
                      ),
                    ),
                    (route) => false,
                  );
                }
              });
            },
            name: 'agree',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: borderRadius15,
        border: widget.showButton
            ? Border.all(
                color: kPrimaryColor.withOpacity(0.4),
              )
            : null,
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: widget.showButton == true
          ? Row(
              children: [
                userCard(),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    enterSQUADIDS();
                  },
                  child: const Icon(
                    IconlyLight.editSquare,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            )
          : userCard(),
    );
  }

  Row userCard() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: borderRadius15),
          margin: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10), // Image border
            child: SizedBox(
              width: 60,
              height: 60,
              child: widget.teamUsers.user!.image == null ? const Icon(IconlyLight.user3) : Image.network('$serverURL/${widget.teamUsers.user!.image}', fit: BoxFit.cover),
            ),
          ),
        ),
        Text(
          widget.teamUsers.user!.nickname.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: gilroySemiBold),
        ),
      ],
    );
  }
}
