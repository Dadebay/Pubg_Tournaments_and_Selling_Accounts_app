import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// A free place in a team: a muted row with an "add player" icon.
class EmptyUsersCard extends StatelessWidget {
  const EmptyUsersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.04),
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedUserAdd01,
              color: Colors.white30,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'teamFreeSlot'.tr,
            style: const TextStyle(
              color: Colors.white30,
              fontFamily: gilroyMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
