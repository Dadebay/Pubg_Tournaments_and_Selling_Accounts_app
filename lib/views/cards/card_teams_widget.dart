import 'package:game_app/views/cards/empty_users_card.dart';
import 'package:game_app/views/cards/team_user_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../models/tournament_model.dart';

/// One team of the "choose a team" page: number badge, "filled/total" counter, a status chip
/// (free places or full) and the player rows. A tap selects it (a full team can not be picked).
class CardTeamsAll extends StatelessWidget {
  final Teams teams;
  final int selectedTeam;
  final Function(int id) selectTeam;
  final int usersCount;

  const CardTeamsAll({
    required this.teams,
    required this.selectedTeam,
    required this.selectTeam,
    required this.usersCount,
    super.key,
  });

  static const _gold = Color(0xFFFFC83D);
  static const _green = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    final selected = selectedTeam == teams.id;
    final users = teams.teamUsers ?? const <TeamUsers>[];
    final filled = users.length;
    final full = usersCount > 0 && filled >= usersCount;
    final statusColor = full ? Colors.white38 : _green;

    return GestureDetector(
      onTap: full
          ? null
          : () {
              selectTeam(teams.id!);
              HapticFeedback.selectionClick();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected
              ? Color.alphaBlend(
                  _gold.withValues(alpha: 0.07),
                  const Color(0xFF131315),
                )
              : const Color(0xFF1B1B1F),
          border: Border.all(
            color: selected ? _gold : Colors.white.withValues(alpha: 0.07),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Opacity(
          opacity: full ? 0.55 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: selected ? 1 : 0.14),
                    ),
                    child: Text(
                      '${teams.number ?? ''}',
                      style: TextStyle(
                        color: selected ? Colors.black : _gold,
                        fontFamily: gilroyBold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'Team'.tr} ${teams.number ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: gilroyBold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedUserMultiple,
                              color: Colors.white54,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$filled/$usersCount',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontFamily: gilroySemiBold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: statusColor.withValues(alpha: 0.14),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: full
                              ? HugeIcons.strokeRoundedLockKey
                              : HugeIcons.strokeRoundedCheckmarkCircle02,
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          full ? 'teamFull'.tr : 'teamOpen'.tr,
                          style: TextStyle(
                            color: statusColor,
                            fontFamily: gilroySemiBold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < usersCount; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                i < users.length
                    ? TeamUserCard(teamUsers: users[i])
                    : const EmptyUsersCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
