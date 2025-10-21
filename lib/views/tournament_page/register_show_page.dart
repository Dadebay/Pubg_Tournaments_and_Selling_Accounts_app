import 'package:flutter/material.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';

class TeamRegistrationScreenDetail extends StatelessWidget {
  final TeamMember teamMember;
  final int tournamentId;

  const TeamRegistrationScreenDetail({
    required this.teamMember,
    required this.tournamentId,
    super.key,
  });

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
          teamMember.name ?? '',
          style: const TextStyle(
            fontFamily: josefinSansSemiBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<GetMeModel>(
        future: GetMeModel().getMe(), // call your API here
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [

                                Text(
                              'LobbiID: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold
                              ),
                            ),
if(user.teams?.first.account == teamMember.account && user.teams?.first.user1 == teamMember.user1 &&
                               user.teams?.first.user2 == teamMember.user2 && user.teams?.first.user3 == teamMember.user3)
                            Text(
                              teamMember.quartturnir?.lobbiId.toString() ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                
                                  color: Colors.green,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                              ],
                            )
                            
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
                  value: teamMember.account,
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

                // Player 1
                _buildInfoCard(
                  label: 'Player 1'.tr,
                  value: teamMember.user1,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                // Player 2
                _buildInfoCard(
                  label: 'Player 2'.tr,
                  value: teamMember.user2,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Player 3
                _buildInfoCard(
                  label: 'Player 3'.tr,
                  value: teamMember.user3,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 32),

                // Info Card
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
