// ignore_for_file: file_names, deprecated_member_use

import 'package:game_app/connection_check.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/views/constants/index.dart';
// import 'package:restart_app/restart_app.dart';
// import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/settings_button.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(
        backArrow: true,
        iconRemove: true,
        fontSize: 0.0,
        name: 'settings',
        elevationWhite: true,
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 1,
            color: backgroundColor,
            height: 1,
          ),
          SettingButton(
            name: Get.locale!.toLanguageTag() == 'tr' ? 'Türkmen dili' : 'Rus dili',
            onTap: () {
              changeLanguage();
            },
            icon: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: ClipRRect(
                borderRadius: borderRadius30,
                child: Image.asset(
                  Get.locale!.toLanguageTag() == 'tr' ? tmIcon : ruIcon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SettingButton(
            name: 'versia',
            onTap: () {},
            icon: const Text(
              '1.0.1',
              style: TextStyle(color: kPrimaryColor, fontFamily: josefinSansMedium),
            ),
          ),
          SettingButton(
            name: 'share',
            onTap: () {
              // Share.share(appShareLink, subject: appName);
            },
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(
                IconlyLight.arrowRightCircle,
                color: Colors.white,
              ),
            ),
          ),
          SettingButton(
            name: 'giveLike',
            onTap: () {
              launchURL(appShareLink);
            },
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(
                IconlyLight.arrowRightCircle,
                color: Colors.white,
              ),
            ),
          ),
          SettingButton(
            name: 'deleteAccount',
            onTap: () {
              // Restart.restartApp();
              Get.to(() => const ConnectionCheck());
              Auth().removeToken();
              Auth().removeRefreshToken();
            },
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(
                IconlyLight.delete,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  dynamic launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
