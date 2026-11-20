import 'package:material_ui/material_ui.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);

/// A team slot of a group: its number, name, group badge and the players.
/// An empty slot is marked "free" and invites the user to take it.
class TeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final int index;

  const TeamMemberCard({required this.member, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final players = [member.account, member.user1, member.user2, member.user3].where((e) => e.isNotEmpty).toList();
    final free = member.user1.isEmpty && member.user2.isEmpty && member.user3.isEmpty;
    final color = free ? const Color(0xFF34D399) : _gold;
    final group = member.quartturnir?.name ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: free ? const Color(0xFF34D399).withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.07)),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${member.name ?? ''} Team',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: gilroyBold, fontSize: 17, color: Colors.white),
                ),
              ),
              if (free) _pill('Bos'.tr, const Color(0xFF34D399)) else if (group.isNotEmpty) _pill(group, _gold),
              const SizedBox(width: 8),
              HugeIcon(icon: free ? HugeIcons.strokeRoundedAdd01 : HugeIcons.strokeRoundedArrowRight01, color: free ? const Color(0xFF34D399) : Colors.white38, size: 20, strokeWidth: 2),
            ],
          ),
          if (players.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final name in players) _player(name)]),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 12, height: 1.1),
      ),
    );
  }

  Widget _player(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Color(0xFFB8B8C0), size: 13, strokeWidth: 1.8),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(color: Color(0xFFE0E0E6), fontFamily: gilroySemiBold, fontSize: 13, height: 1.1),
          ),
        ],
      ),
    );
  }
}
