import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _green = Color(0xFF34D399);

/// The registered team of a slot: its players, and, for the team's owner, the
/// lobby id and the room code.
class TeamRegistrationScreenDetail extends StatefulWidget {
  final TeamMember teamMember;
  final int tournamentId;

  const TeamRegistrationScreenDetail({required this.teamMember, required this.tournamentId, super.key});

  @override
  State<TeamRegistrationScreenDetail> createState() => _TeamRegistrationScreenDetailState();
}

class _TeamRegistrationScreenDetailState extends State<TeamRegistrationScreenDetail> {
  bool _isVisible = false;

  /// The signed-in user owns this team when the team they registered has the same players.
  bool _isOwner(GetMeModel user) {
    final team = (user.teams != null && user.teams!.isNotEmpty) ? user.teams!.first : null;
    final member = widget.teamMember;
    if (team == null) {
      return false;
    }
    final filled =
        (team.account?.isNotEmpty ?? false) &&
        (team.user1?.isNotEmpty ?? false) &&
        (team.user2?.isNotEmpty ?? false) &&
        (team.user3?.isNotEmpty ?? false) &&
        member.account.isNotEmpty &&
        member.user1.isNotEmpty &&
        member.user2.isNotEmpty &&
        member.user3.isNotEmpty;
    return filled && team.account == member.account && team.user1 == member.user1 && team.user2 == member.user2 && team.user3 == member.user3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: widget.teamMember.name ?? '', onBack: Get.back),
            Expanded(
              child: FutureBuilder<GetMeModel>(
                future: GetMeModel().getMe(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _gold));
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.cloud_off_rounded, title: 'errorLoadData'.tr, description: ''),
                    );
                  }
                  final owner = _isOwner(snapshot.data!);
                  final member = widget.teamMember;
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    children: [
                      _headerCard(owner),
                      const SizedBox(height: 22),
                      Text(
                        'Team Players'.tr,
                        style: const TextStyle(fontFamily: gilroyBold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _player('Player 1'.tr, member.account),
                      _player('Player 2'.tr, member.user1),
                      _player('Player 3'.tr, member.user2),
                      _player('Player 4'.tr, member.user3),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: _green, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Team successfully registered for tournament'.tr,
                                style: const TextStyle(color: _green, fontFamily: gilroyMedium, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(bool owner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2416), Color(0xFF141416)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(alpha: 0.16),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: const Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: _gold, size: 24, strokeWidth: 1.8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registered Team'.tr,
                      style: const TextStyle(fontFamily: gilroyBold, fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View your team information'.tr,
                      style: const TextStyle(fontFamily: gilroyRegular, fontSize: 14, color: Color(0xFFB8B8C0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (owner) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'LobbiID: ',
                  style: TextStyle(fontFamily: gilroyBold, fontSize: 16, color: _green),
                ),
                CopyableText(lobbiId: widget.teamMember.quartturnir?.lobbiId),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isVisible = !_isVisible),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: _gold),
                    child: Text(
                      _isVisible ? 'Hide Code'.tr : 'Show Code'.tr,
                      style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 13, height: 1.1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isVisible)
                  Flexible(
                    child: Text(
                      '${widget.teamMember.quartturnir?.code ?? 'Unknown Code'}',
                      style: const TextStyle(color: Color(0xFFFF5A5F), fontFamily: gilroyBold, fontSize: 15),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _player(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
      ),
      child: Row(
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: _gold, size: 20, strokeWidth: 1.8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CopyableText extends StatelessWidget {
  final String? lobbiId;

  const CopyableText({super.key, this.lobbiId});

  @override
  Widget build(BuildContext context) {
    final textToCopy = lobbiId?.toString() ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          textToCopy,
          style: const TextStyle(fontSize: 16, color: _green, fontFamily: gilroyBold),
        ),
        const SizedBox(width: 6),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white54),
          onPressed: () {
            if (textToCopy.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: textToCopy));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)));
            }
          },
        ),
      ],
    );
  }
}
