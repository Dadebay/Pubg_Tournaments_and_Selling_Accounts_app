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
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 25),
              child: Text(
                'signInDialog'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 20),
              ),
            ),
            page ? CustomTextField(labelName: 'signIn1', controller: fullNameController, focusNode: fullNameFocusNode, requestfocusNode: idFocusNode, borderRadius: true, isNumber: false) : const SizedBox.shrink(),
            page
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextField(labelName: 'signIn2', controller: idController, focusNode: idFocusNode, requestfocusNode: phoneNumberFocusNode, borderRadius: true, isNumber: false),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: page ? const EdgeInsets.symmetric(vertical: 10) : const EdgeInsets.symmetric(vertical: 25),
              child: PhoneNumber(
                mineFocus: phoneNumberFocusNode,
                controller: phoneNumberController,
                requestFocus: phoneNumberFocusNode,
                style: false,
              ),
            ),
            const SizedBox(
              height: 20,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBar(fontSize: 0.0, backArrow: true, iconRemove: true, name: page == false ? 'signIn'.tr : 'signUp'.tr, elevationWhite: true),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: ClipRRect(
                  borderRadius: borderRadius30,
                  child: Image.asset(
                    logo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            loginDesign(),
          ],
        ),
      ),
    );
  }
}
