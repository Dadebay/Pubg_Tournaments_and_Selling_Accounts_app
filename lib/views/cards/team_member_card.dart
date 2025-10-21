import 'package:game_app/models/team_member.dart';
import 'package:game_app/views/constants/index.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final int index;

  const TeamMemberCard({
    required this.member,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
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
                      member.name ?? '${'Team'.tr} ${member.id}',
                      style: const TextStyle(
                        fontFamily: josefinSansSemiBold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    if (member.user1.isEmpty || member.user2.isEmpty || member.user3.isEmpty)
                      Text(
                        'Bos'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[400],
                        ),
                      ),
                    if (member.account.isNotEmpty)
                      Text(
                        member.account,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: member.quartturnir == 'A1' ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  member.quartturnir,
                  style: TextStyle(
                    color: member.quartturnir == 'A1' ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (member.user1.isNotEmpty || member.user2.isNotEmpty || member.user3.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  if (member.account.isNotEmpty) _buildUserRow(Icons.person, member.account),
                  if (member.user1.isNotEmpty) _buildUserRow(Icons.person, member.user1),
                  if (member.user2.isNotEmpty) _buildUserRow(Icons.person, member.user2),
                  if (member.user3.isNotEmpty) _buildUserRow(Icons.person, member.user3),
                ],
              ),
            ),
          // if (member.halfturnir != null || member.finalturnir != null)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 8),
          //     child: Row(
          //       children: [
          //         if (member.halfturnir != null) _buildStageChip('Half', member.halfturnir!),
          //         if (member.halfturnir != null && member.finalturnir != null) const SizedBox(width: 8),
          //         if (member.finalturnir != null) _buildStageChip('Final', member.finalturnir!),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildUserRow(IconData icon, String username) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            username,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
