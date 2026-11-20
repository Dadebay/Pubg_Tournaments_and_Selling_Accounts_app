// ignore_for_file: file_names, must_be_immutable

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:game_app/controllers/settings_controller.dart';

import '../constants/index.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String name;
  final bool? showIcon;

  AgreeButton({required this.onTap, required this.name, super.key, this.showIcon});

  SettingsController settingsController = Get.put(SettingsController());
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        return animatedContaner(MediaQuery.sizeOf(context).width);
      }),
    );
  }

  AnimatedContainer animatedContaner(double availableWidth) {
    return AnimatedContainer(
      decoration: const BoxDecoration(borderRadius: borderRadius20, color: Colors.white),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: settingsController.agreeButton.value ? 0 : 10),
      width: settingsController.agreeButton.value ? 60 : availableWidth,
      duration: const Duration(milliseconds: 1000),
      child: settingsController.agreeButton.value
          ? const Center(
              child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: kPrimaryColor)),
            )
          : showIcon == true
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: Icon(name == 'Nagt' ? IconlyLight.wallet : CupertinoIcons.creditcard, color: kPrimaryColor),
                ),
                Text(
                  name.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold, fontSize: 22),
                ),
              ],
            )
          : Text(
              name.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold, fontSize: 22),
            ),
    );
  }
}
