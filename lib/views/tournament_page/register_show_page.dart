import 'package:flutter/material.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';

class TeamRegistrationScreenDetail extends StatefulWidget {
  final TeamMember teamMember;
  final int tournamentId;

  const TeamRegistrationScreenDetail({
    required this.teamMember,
    required this.tournamentId,
    super.key,
  });

  @override
  State<TeamRegistrationScreenDetail> createState() => _TeamRegistrationScreenDetailState();
}

class _TeamRegistrationScreenDetailState extends State<TeamRegistrationScreenDetail> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.teamMember.name ?? '',
          style: const TextStyle(
            fontFamily: josefinSansSemiBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<GetMeModel>(
        future: GetMeModel().getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While loading, show a loader
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // If API call failed
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            // If data is null
            return const Center(child: Text('No user data available'));
          }

          final user = snapshot.data!; // now safe to use
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.2),
                        kPrimaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group,
                          color: kPrimaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered Team'.tr,
                              style: const TextStyle(
                                fontFamily: josefinSansSemiBold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View your team information'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  'LobbiID: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (user.teams != null &&
                                    user.teams!.isNotEmpty &&
                                    user.teams!.first.account?.isNotEmpty == true &&
                                    user.teams!.first.user1?.isNotEmpty == true &&
                                    user.teams!.first.user2?.isNotEmpty == true &&
                                    user.teams!.first.user3?.isNotEmpty == true &&
                                    widget.teamMember.account.isNotEmpty == true &&
                                    widget.teamMember.user1.isNotEmpty == true &&
                                    widget.teamMember.user2.isNotEmpty == true &&
                                    widget.teamMember.user3.isNotEmpty == true &&
                                    user.teams!.first.account == widget.teamMember.account &&
                                    user.teams!.first.user1 == widget.teamMember.user1 &&
                                    user.teams!.first.user2 == widget.teamMember.user2 &&
                                    user.teams!.first.user3 == widget.teamMember.user3)
                                  Text(
                                    widget.teamMember.quartturnir?.lobbiId?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kAccentColor, // button color
                                    foregroundColor: Colors.black, // text color
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isVisible = !_isVisible;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(_isVisible ? 'Hide Code'.tr : 'Show Code'.tr),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (_isVisible)
                                  Text(
                                    widget.teamMember.quartturnir?.code ?? 'Unknown Code',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Info
                _buildInfoCard(
                  label: 'Account Name'.tr,
                  value: widget.teamMember.name ?? '',
                  icon: Icons.account_circle,
                ),
                const SizedBox(height: 20),

                // Players Section Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Team Players'.tr,
                      style: const TextStyle(
                        fontFamily: josefinSansSemiBold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Player 3
                _buildInfoCard(
                   label: 'Player 1'.tr,
                  value: widget.teamMember.account,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Player 1
                _buildInfoCard(
                  label: 'Player 2'.tr,
                  value: widget.teamMember.user1,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                // Player 2
                _buildInfoCard(
                   label: 'Player 3'.tr,
                  value: widget.teamMember.user2,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Player 3
                _buildInfoCard(
                  label: 'Player 4'.tr,
                  value: widget.teamMember.user3,
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green[300], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Team successfully registered for tournament'.tr,
                          style: TextStyle(
                            color: Colors.green[300],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: josefinSansMedium,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
