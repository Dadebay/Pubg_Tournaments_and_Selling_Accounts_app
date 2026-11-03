import 'package:flutter/material.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

const _gold = Color(0xFFFFC83D);

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
  final _userController = TextEditingController();
  final _accountController = TextEditingController();
  final _user1Controller = TextEditingController();
  final _user2Controller = TextEditingController();
  final _user3Controller = TextEditingController();
  String? currentUserId;
  bool isUserLoading = true;
  String? userError;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing existing team member
    if (widget.teamMember != null) {
      _accountController.text = widget.teamMember!.account;
      // _userController.text = widget.teamMember!.extra_name;
      _user1Controller.text = widget.teamMember!.user1;
      _user2Controller.text = widget.teamMember!.user2;
      _user3Controller.text = widget.teamMember!.user3;
    }
    _initData();
  }

  Future<void> _initData() async {
    try {
      // 1️⃣ Fetch user info first
      final user = await GetMeModel().getMe();

      setState(() {
        currentUserId = user.nickname;
        isUserLoading = false;
      });
    } catch (e) {
      setState(() {
        userError = e.toString();
        isUserLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _user1Controller.dispose();
    _user2Controller.dispose();
    _user3Controller.dispose();
    _userController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TeamMembersProvider>(context, listen: false);

      final success = await provider.registerTeam(
        tournamentId: widget.teamMember?.id ?? 0,
        account: _accountController.text.trim(),
        extra_name: _userController.text.trim(),
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

  bool _isVisible = false;

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message.tr : null;

  @override
  Widget build(BuildContext context) {
    final slot = widget.teamMember;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'Register Team'.tr, onBack: Get.back),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _headerCard(),
                    const SizedBox(height: 20),
                    _section(
                      'Account Name'.tr,
                      HugeIcons.strokeRoundedUserCircle,
                    ),
                    _buildTextField(
                      controller: _accountController,
                      hint: 'Your account name'.tr,
                      icon: HugeIcons.strokeRoundedUserCircle,
                      validator: (value) =>
                          _required(value, 'Please enter account name'),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _section(
                            'Team Players'.tr,
                            HugeIcons.strokeRoundedUserGroup,
                          ),
                        ),
                        if (slot != null && (slot.name ?? '').isNotEmpty)
                          Text(
                            '${slot.name} Team',
                            style: const TextStyle(
                              color: _gold,
                              fontFamily: gilroyBold,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    _playerBox(
                      number: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentUserId ?? 'Owner name'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: gilroySemiBold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Player 1'.tr,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: gilroyBold,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _playerBox(
                      number: 2,
                      child: _buildTextField(
                        controller: _user1Controller,
                        hint: 'Second player username'.tr,
                        icon: HugeIcons.strokeRoundedUser,
                        validator: (value) =>
                            _required(value, 'Please enter player 1 username'),
                      ),
                    ),
                    _playerBox(
                      number: 3,
                      child: _buildTextField(
                        controller: _user2Controller,
                        hint: 'Third player username'.tr,
                        icon: HugeIcons.strokeRoundedUser,
                        validator: (value) =>
                            _required(value, 'Please enter player 2 username'),
                      ),
                    ),
                    _playerBox(
                      number: 4,
                      child: _buildTextField(
                        controller: _user3Controller,
                        hint: 'Foths player username'.tr,
                        icon: HugeIcons.strokeRoundedUser,
                        validator: (value) =>
                            _required(value, 'Please enter player 3 username'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF60A5FA),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All team members must have valid accounts'.tr,
                              style: const TextStyle(
                                color: Color(0xFF60A5FA),
                                fontFamily: gilroyMedium,
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
            // The button stays in reach while the form scrolls.
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColorBlack,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                ),
              ),
              child: Consumer<TeamMembersProvider>(
                builder: (context, provider, child) {
                  final busy = provider.isRegistering;
                  return GestureDetector(
                    onTap: busy ? null : _submitForm,
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: busy
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
                              ),
                        color: busy ? const Color(0xFF3A3A40) : null,
                      ),
                      child: busy
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Register Team'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: gilroyBold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2416), Color(0xFF141416)],
        ),
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
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: _gold,
                    size: 24,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Topar hasaba alyş'.tr,
                  style: const TextStyle(
                    fontFamily: gilroyBold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Topary bir gezek hasaba alyp bolýar, dostlaryňyzy ýa-da tanyşlaryňyzy çagyryň'
                .tr,
            style: const TextStyle(
              fontFamily: gilroyRegular,
              fontSize: 14,
              height: 1.4,
              color: Color(0xFFB8B8C0),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _isVisible = !_isVisible),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedKey01,
                    color: _gold,
                    size: 18,
                    strokeWidth: 1.8,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isVisible
                          ? '${widget.teamMember?.quartturnir?.code ?? 'Unknown Code'}'
                          : '••••••',
                      style: TextStyle(
                        color: _isVisible
                            ? const Color(0xFFFF5A5F)
                            : Colors.white54,
                        fontFamily: gilroyBold,
                        fontSize: 16,
                        letterSpacing: _isVisible ? 0.5 : 3,
                      ),
                    ),
                  ),
                  Text(
                    _isVisible ? 'Hide Code'.tr : 'Show Code'.tr,
                    style: const TextStyle(
                      color: _gold,
                      fontFamily: gilroyBold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text, List<List<dynamic>> icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: _gold, size: 20, strokeWidth: 1.8),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: gilroyBold,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// A numbered row: the place of the player in the team and his field.
  Widget _playerBox({required int number, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(top: 11, right: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: number == 1 ? 1 : 0.14),
              border: Border.all(color: _gold.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: number == 1 ? Colors.black : _gold,
                fontFamily: gilroyBold,
                fontSize: 15,
                height: 1,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required List<List<dynamic>> icon,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: validator,
          cursorColor: _gold,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: gilroySemiBold,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF6E6E78),
              fontFamily: gilroyMedium,
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: HugeIcon(
                icon: icon,
                color: _gold,
                size: 20,
                strokeWidth: 1.8,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: const Color(0xFF1B1B1E),
            border: border(Colors.transparent),
            enabledBorder: border(Colors.white.withValues(alpha: 0.08)),
            focusedBorder: border(_gold, 1.5),
            errorBorder: border(const Color(0xFFFF5A5F)),
            focusedErrorBorder: border(const Color(0xFFFF5A5F), 1.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
          ),
        ),
      ],
    );
  }
}
