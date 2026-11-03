// ignore_for_file: file_names, must_be_immutable

import 'package:game_app/connection_check.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';

import '../../constants/index.dart';

class OtpCheck extends StatelessWidget {
  final String phoneNumber;
  final bool loginType;
  OtpCheck({
    required this.phoneNumber,
    required this.loginType,
    super.key,
  });
  FocusNode otpFocusNode = FocusNode();
  final otpCheck = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(fontSize: 0.0, backArrow: true, iconRemove: false, name: 'otp', elevationWhite: false),
      body: Container(
        color: kPrimaryColorBlack,
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                loginType ? 'loginWithGmail1'.tr : 'otpSubtitle'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: gilroyMedium),
              ),
            ),
            Form(key: otpCheck, child: CustomTextField(labelName: 'otp', controller: otpController, focusNode: otpFocusNode, requestfocusNode: otpFocusNode, borderRadius: true, isNumber: true)),
            const SizedBox(
              height: 15,
            ),
            AgreeButton(
              name: 'agree',
              onTap: () {
                if (otpCheck.currentState!.validate()) {
                  Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
                  if (loginType == true) {
                    UserSignInModel().gmailOtpCheck(otp: otpController.text, email: phoneNumber).then((value) {
                      if (value == true) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ConnectionCheck(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
                      }
                    });
                  } else {
                    UserSignInModel().otpCheck(otp: otpController.text, phoneNumber: phoneNumber).then((value) {
                      if (value == true) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ConnectionCheck(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
                      }
                    });
                  }
                } else {
                  showSnackBar('tournamentInfo14', 'signInDialog', Colors.red);
                }
                Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
