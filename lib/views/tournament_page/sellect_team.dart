import 'dart:async';

import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/cards/card_teams_widget.dart';
import 'package:game_app/views/constants/centered_header.dart';
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
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(showPages: false),
          ),
          (route) => false,
        );
      });
    });
  }

  /// After joining, renames the player's own slot when they typed another name than the account's
  /// (`POST /turnirs/turnir/{id}/`). The join call itself does not take the own name.
  Future<void> _renameOwnSlot({
    required String account,
    required String name,
  }) async {
    if (name.isEmpty || name == account) {
      return;
    }
    final detail = await TournamentModel().getTournamentID(
      widget.turnir.id ?? 0,
    );
    for (final team in detail.teams ?? <Teams>[]) {
      if (team.id != selectedTeam) {
        continue;
      }
      for (final slot in team.teamUsers ?? <TeamUsers>[]) {
        if (slot.user?.pubgId == account && slot.id != null) {
          await TournamentModel().editSQUAD(
            turnirID: widget.turnir.id!,
            id: slot.id!,
            pubgID1: name,
          );
          return;
        }
      }
    }
  }

  /// The names dialog: the player's own name first (ready with the account's name, can be changed),
  /// then the teammates. Scrolls when the keyboard takes the room, so it can not overflow.
  Future<void> enterSQUADIDS() async {
    String account = '';
    try {
      account = '${(await GetMeModel().getMe()).pubgId ?? ''}';
    } catch (_) {}
    final squad = widget.turnir.type == 'squad';
    final mates = squad ? 3 : 1;
    final controllers = [
      TextEditingController(text: account), // own name
      for (var i = 0; i < mates; i++) TextEditingController(),
    ];
    final focusNodes = [for (var i = 0; i < mates + 1; i++) FocusNode()];
    var busy = false;
    const gold = Color(0xFFFFC83D);

    Widget field(int index, StateSetter setLocal) {
      final own = index == 0;
      final last = index == controllers.length - 1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: own ? 1 : 0.14),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: own ? Colors.black : gold,
                  fontFamily: gilroyBold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textInputAction: last
                    ? TextInputAction.done
                    : TextInputAction.next,
                onSubmitted: (_) => last
                    ? focusNodes[index].unfocus()
                    : focusNodes[index + 1].requestFocus(),
                cursorColor: gold,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: gilroySemiBold,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'buySQUAD4'.tr,
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                    fontFamily: gilroyMedium,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  suffixIcon: own
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Center(
                            widthFactor: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'youLabel'.tr,
                                style: const TextStyle(
                                  color: gold,
                                  fontFamily: gilroyBold,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: gold, width: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setLocal) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1F),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: gold.withValues(alpha: 0.14),
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedUserMultiple,
                          color: gold,
                          size: 22,
                          strokeWidth: 1.8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'buySQUAD3'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: gilroyBold,
                            fontSize: 19,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: Get.back,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'teamNamesHint'.tr,
                      style: const TextStyle(
                        color: Color(0xFF9A9AA3),
                        fontFamily: gilroyMedium,
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < controllers.length; i++)
                    field(i, setLocal),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: busy
                        ? null
                        : () async {
                            final own = controllers[0].text.trim();
                            if (own.isEmpty) {
                              showSnackBar(
                                'Üns beriň!',
                                'renameEmpty',
                                Colors.red,
                              );
                              return;
                            }
                            setLocal(() => busy = true);
                            final int value;
                            if (squad) {
                              value =
                                  await TournamentModel()
                                          .participateTournamentSQUAD(
                                            teamId: selectedTeam,
                                            pubgID1: controllers[1].text.trim(),
                                            pubgID2: controllers[2].text.trim(),
                                            pubgID3: controllers[3].text.trim(),
                                          )
                                      as int;
                            } else {
                              value =
                                  await TournamentModel()
                                          .participateTournamentDUAL(
                                            teamId: selectedTeam,
                                            pubgID1: controllers[1].text.trim(),
                                          )
                                      as int;
                            }
                            if (value == 200) {
                              await _renameOwnSlot(account: account, name: own);
                              backTurnir();
                            } else {
                              setLocal(() => busy = false);
                            }
                          },
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: busy ? gold.withValues(alpha: 0.5) : gold,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              'agree'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: gilroyBold,
                                fontSize: 17,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = widget.turnir.teams ?? <Teams>[];
    final usersCount = widget.turnir.type == 'solo'
        ? 1
        : widget.turnir.type == 'duo'
        ? 2
        : widget.turnir.type == 'squad'
        ? 4
        : 0;
    final chosen = selectedTeam != 0;
    const gold = Color(0xFFFFC83D);
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'Team'.tr, onBack: Get.back),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                itemCount: teams.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) => CardTeamsAll(
                  teams: teams[index],
                  selectedTeam: selectedTeam,
                  selectTeam: (int id) => setState(() => selectedTeam = id),
                  usersCount: usersCount,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: kPrimaryColorBlack,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
        child: GestureDetector(
          onTap: () => chosen
              ? enterSQUADIDS()
              : showSnackBar('Üns beriň!', 'selectTeamHint', Colors.red),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: chosen ? gold : Colors.white.withValues(alpha: 0.08),
            ),
            child: Text(
              chosen ? 'agree'.tr : 'selectTeamHint'.tr,
              style: TextStyle(
                color: chosen ? Colors.black : Colors.white54,
                fontFamily: gilroyBold,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
