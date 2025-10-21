import 'package:flutter/material.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class TeamRegistrationScreen extends StatefulWidget {
  final int tournamentId;
  final TeamMember? teamMember;

  const TeamRegistrationScreen({
    required this.tournamentId,
    this.teamMember,
    super.key,
  });

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _user1Controller = TextEditingController();
  final _user2Controller = TextEditingController();
  final _user3Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing existing team member
    if (widget.teamMember != null) {
      _accountController.text = widget.teamMember!.account;
      _user1Controller.text = widget.teamMember!.user1;
      _user2Controller.text = widget.teamMember!.user2;
      _user3Controller.text = widget.teamMember!.user3;
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _user1Controller.dispose();
    _user2Controller.dispose();
    _user3Controller.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TeamMembersProvider>(context, listen: false);

      final success = await provider.registerTeam(
        tournamentId: widget.teamMember?.id ?? 0,
        account: _accountController.text.trim(),
        user1: _user1Controller.text.trim(),
        user2: _user2Controller.text.trim(),
        user3: _user3Controller.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Get.back(); // Go back to detail page
        Get.snackbar(
          'Success'.tr,
          'Team registered successfully!'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      } else {
        // Show backend error message if available
        final errorMsg = provider.errorMessage ?? 'Failed to register team';
        Get.snackbar(
          'Error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    }
  }

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
        title:  Text(
          'Register Team'.tr,
          style:const TextStyle(
            fontFamily: josefinSansSemiBold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                        Icons.group_add,
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
                            'Topar hasaba alyş'.tr,
                            style:const TextStyle(
                              fontFamily: josefinSansSemiBold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Topary bir gezek hasaba alyp bolýar, dostlaryňyzy ýa-da tanyşlaryňyzy çagyryň'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account field
              _buildTextField(
                controller: _accountController,
                label: 'Account Name'.tr,
                hint: 'Your account name'.tr,
                icon: Icons.account_circle,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account name'.tr;
                  }
                  return null;
                },
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
                    style: TextStyle(
                      fontFamily: josefinSansSemiBold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // User 1
              _buildTextField(
                controller: _user1Controller,
                label: 'Player 1'.tr,
                hint: 'First player username'.tr,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player 1 username'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // User 2
              _buildTextField(
                controller: _user2Controller,
                label: 'Player 2'.tr,
                hint: 'Second player username'.tr,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player 2 username'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // User 3
              _buildTextField(
                controller: _user3Controller,
                label: 'Player 3'.tr,
                hint: 'Third player username'.tr,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player 3 username'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<TeamMembersProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isRegistering ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        disabledBackgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isRegistering
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.teamMember != null ? Icons.edit : Icons.check_circle,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                 Text(
                                  'Register Team'.tr,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: josefinSansSemiBold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All team members must have valid accounts'.tr,
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, color: kPrimaryColor, size: 22),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
