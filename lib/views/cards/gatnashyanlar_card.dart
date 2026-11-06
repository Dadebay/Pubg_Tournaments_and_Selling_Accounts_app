import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../models/tournament_model.dart';

/// One player row inside a team card: avatar, nickname, PUBG id and (for the user's own team) an edit button.
// ignore: must_be_immutable
class GatnashyanlarCard extends StatefulWidget {
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
          const SizedBox(height: 15),
          AgreeButton(
            onTap: () async {
              await TournamentModel().editSQUAD(turnirID: int.parse(widget.turnirID.toString()), pubgID1: controllers.text.toString(), id: int.parse(widget.teamUsers.id.toString())).then((value) {
                if (value == 200) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const BottomNavBar(showPages: false)), (route) => false);
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
    final user = widget.teamUsers.user;
    final pubgId = user?.pubgId ?? '';
    final image = user?.image;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 46,
              height: 46,
              color: const Color(0xFF2B2B30),
              child: image == null || image.isEmpty
                  ? const Center(
                      child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white38, size: 22),
                    )
                  : Image.network(
                      '$serverURL/$image',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white38, size: 22),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user?.nickname ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: gilroySemiBold),
                ),
                if (pubgId.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID  $pubgId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: gilroyMedium),
                  ),
                ],
              ],
            ),
          ),
          if (widget.showButton)
            GestureDetector(
              onTap: enterSQUADIDS,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFC83D).withValues(alpha: 0.14)),
                child: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: Color(0xFFFFC83D), size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

/// Placeholder for a free slot in a team.
class TeamEmptySlot extends StatelessWidget {
  const TeamEmptySlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.03)),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, color: Colors.white24, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            '—',
            style: TextStyle(color: Colors.white24, fontSize: 18, fontFamily: gilroyMedium),
          ),
        ],
      ),
    );
  }
}

/// Team container: numbered badge, "Team N", filled/total counter, then the player rows.
class TeamShell extends StatelessWidget {
  final int? number;
  final int filled;
  final int total;
  final bool mine;
  final bool winner;
  final List<Widget> children;

  const TeamShell({required this.number, required this.filled, required this.total, required this.children, this.mine = false, this.winner = false, super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC83D);
    final highlight = mine || winner;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: highlight ? gold.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.07), width: highlight ? 1.5 : 1),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [highlight ? gold.withValues(alpha: 0.12) : const Color(0xFF232327), const Color(0xFF161618)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withValues(alpha: 0.16),
                  border: Border.all(color: gold.withValues(alpha: 0.5)),
                ),
                child: winner
                    ? const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: gold, size: 18, strokeWidth: 1.8)
                    : Text(
                        '${number ?? ''}',
                        style: const TextStyle(color: gold, fontFamily: gilroyBold, fontSize: 15),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Team ${number ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: gilroyBold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withValues(alpha: 0.07)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(icon: HugeIcons.strokeRoundedUserMultiple, color: Colors.white54, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '$filled/$total',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: gilroySemiBold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}
