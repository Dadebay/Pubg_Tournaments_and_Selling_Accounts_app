import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/player_photo.dart';

import '../../models/tournament_model.dart';

/// A player of a team: photo, name and Pubg id on a flat row.
class TeamUserCard extends StatelessWidget {
  const TeamUserCard({required this.teamUsers, super.key});

  final TeamUsers teamUsers;

  @override
  Widget build(BuildContext context) {
    final user = teamUsers.user;
    final pubgId = '${user?.pubgId ?? ''}';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 46,
              height: 46,
              child: PlayerPhoto(image: user?.image),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded, so a long name is cut with dots instead of running off the card.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user?.nickname ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroySemiBold,
                    fontSize: 15,
                  ),
                ),
                if (pubgId.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID  $pubgId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontFamily: gilroyMedium,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
