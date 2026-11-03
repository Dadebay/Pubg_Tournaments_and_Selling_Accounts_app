import 'package:flutter/cupertino.dart';
import 'package:game_app/connection_check.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/buttons/dialog_button.dart';
import 'package:game_app/views/constants/index.dart';

void logOut(BuildContext context) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(color: kPrimaryColorBlack),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  'log_out'.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(CupertinoIcons.xmark_circle, size: 22, color: Colors.white),
                ),
              ],
            ),
          ),
          customDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(
              'log_out_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: gilroyMedium,
                fontSize: 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Auth().logout();
              Get.back();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ConnectionCheck(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Container(
              width: Get.size.width,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[500], borderRadius: borderRadius10),
              child: Text(
                'yes'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Get.back();
            },
            child: Container(
              width: Get.size.width,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.red, borderRadius: borderRadius10),
              child: Text(
                'no'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void changeLanguage() {
  final SettingsController settingsController = Get.put(SettingsController());

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(color: kPrimaryColorBlack),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  'select_language'.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(CupertinoIcons.xmark_circle, size: 22, color: Colors.white),
                ),
              ],
            ),
          ),
          customDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              onTap: () {
                settingsController.switchLang('tr');
                Get.back();
              },
              leading: const CircleAvatar(
                backgroundImage: AssetImage(
                  tmIcon,
                ),
                backgroundColor: Colors.white,
                radius: 20,
              ),
              title: const Text(
                'Türkmen',
                style: TextStyle(fontFamily: gilroyMedium, color: Colors.white),
              ),
            ),
          ),
          customDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              onTap: () {
                settingsController.switchLang('ru');
                Get.back();
              },
              leading: const CircleAvatar(
                backgroundImage: AssetImage(
                  ruIcon,
                ),
                radius: 20,
                backgroundColor: Colors.white,
              ),
              title: const Text(
                'Русский',
                style: TextStyle(fontFamily: gilroyMedium, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void defaultBottomSheet({required String name, required Widget child}) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(color: kPrimaryColorBlack),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  name.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(CupertinoIcons.xmark_circle, size: 22, color: Colors.white),
                ),
              ],
            ),
          ),
          customDivider(),
          Center(
            child: child,
          ),
        ],
      ),
    ),
  );
}

Future<Object?> showDeleteDialog(BuildContext context, String text, String text2, Function() onTap) {
  return showGeneralDialog(
    transitionBuilder: (context, a1, a2, widget) {
      final curvedValue = Curves.decelerate.transform(a1.value) - 1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 400, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: kPrimaryColorBlack,
            shape: const OutlineInputBorder(borderRadius: borderRadius15, borderSide: BorderSide(color: Colors.white)),
            title: Text(
              text.tr,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: gilroyBold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
                  child: Text(
                    text2.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Row(
                  children: [
                    DialogButton(
                      name: 'no',
                      onTapp: () {
                        Get.back();
                      },
                      color: text2 == 'welcome' ? false : true,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DialogButton(
                      name: text2 == 'welcome' ? 'signUp' : 'yes',
                      onTapp: onTap,
                      color: text2 == 'welcome' ? true : false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox.shrink();
    },
  );
}
