// ignore_for_file: file_names

import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/user_profil/auth/otp_check.dart';

import '../../constants/index.dart';

class TabBarViewPage extends StatefulWidget {
  const TabBarViewPage({super.key});

  @override
  State<TabBarViewPage> createState() => _TabBarViewPageState();
}

class _TabBarViewPageState extends State<TabBarViewPage> {
  TextEditingController fullNameController = TextEditingController();
  FocusNode fullNameFocusNode = FocusNode();
  TextEditingController idController = TextEditingController();
  FocusNode idFocusNode = FocusNode();
  final login = GlobalKey<FormState>();
  bool page = false;
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController phoneNumberController = TextEditingController();
  FocusNode phoneNumberFocusNode = FocusNode();

  dynamic onTapp() {
    if (login.currentState!.validate()) {
      Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
      UserSignInModel().login(phone: phoneNumberController.text).then((value) {
        if (value == 200) {
          Get.to(
            () => OtpCheck(
              phoneNumber: phoneNumberController.text,
              loginType: false,
            ),
          );
        } else if (value == 404) {
          page = true;
          phoneNumberController.clear();
          showSnackBar('userNotFound', 'userNotFound1', Colors.red);
        } else {
          page = true;
          phoneNumberController.clear();

          showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
        }
        setState(() {});

        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
      });
    } else {
      showSnackBar('tournamentInfo14', 'errorEmpty', Colors.red);
    }
  }

  dynamic onTappSignIn() {
    if (login.currentState!.validate()) {
      Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
      UserSignInModel().signUp(username: fullNameController.text, pubgID: idController.text, phoneNumber: phoneNumberController.text, referalCode: '').then((value) {
        if (value == 200) {
          Get.to(
            () => OtpCheck(
              phoneNumber: phoneNumberController.text,
              loginType: false,
            ),
          );
        } else if (value == 409) {
          showSnackBar('noConnection3', 'alreadyExist', Colors.red);
        } else if (value == 400) {
          showSnackBar('referal yalnys', 'Refereal kod yalys', Colors.red);
        } else {
          showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
        }
        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
      });
    } else {
      showSnackBar('tournamentInfo14', 'errorEmpty', Colors.red);
    }
  }

  dynamic loginDesign() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: login,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            page ? CustomTextField(labelName: 'signIn1', controller: fullNameController, focusNode: fullNameFocusNode, requestfocusNode: idFocusNode, borderRadius: true, isNumber: false) : const SizedBox.shrink(),
            page
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextField(labelName: 'signIn2', controller: idController, focusNode: idFocusNode, requestfocusNode: phoneNumberFocusNode, borderRadius: true, isNumber: false),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: PhoneNumber(
                mineFocus: phoneNumberFocusNode,
                controller: phoneNumberController,
                requestFocus: phoneNumberFocusNode,
                style: false,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            AgreeButton(
              onTap: page ? onTappSignIn : onTapp,
              name: 'agree',
            ),
          ],
        ),
      ),
    );
  }

  static const _gold = Color(0xFFFFC83D);

  /// The gamer picture, fading into the black page at the bottom.
  Widget _hero(double height) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Warm glow behind the phone light of the picture.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: const Alignment(0, 0.35), radius: 0.8, colors: [_gold.withValues(alpha: 0.28), Colors.transparent]),
              ),
            ),
          ),
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
              ),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.black, Colors.transparent], stops: [0, 0.62, 1]).createShader(rect),
                child: Image.asset('assets/image/login_gamer.webp', fit: BoxFit.cover, alignment: Alignment.topCenter, filterQuality: FilterQuality.high, excludeFromSemantics: true),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 8,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.45), border: Border.all(color: Colors.white.withValues(alpha: 0.14))),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              page ? 'signUp'.tr : 'signIn'.tr,
              key: ValueKey(page),
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 32, height: 1.1),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Text('signInDialog'.tr, style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 16, height: 1.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final heroHeight = (size.width * 0.9).clamp(240.0, size.height * 0.42);
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _hero(heroHeight),
            _header(),
            loginDesign(),
          ],
        ),
      ),
    );
  }
}
