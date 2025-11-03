// ignore_for_file: file_names

import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/profile_button.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:game_app/views/user_profil/auth/tab_bar_view.dart';
import 'package:game_app/views/user_profil/pages/about_us.dart';
import 'package:game_app/views/user_profil/pages/add_cash.dart';
import 'package:game_app/views/user_profil/pages/bought_things.dart';
import 'package:game_app/views/user_profil/pages/edit_work_profil.dart';
import 'package:game_app/views/user_profil/pages/new_notification_page.dart';
import 'package:game_app/views/user_profil/pages/profile_settings.dart';
import 'package:game_app/views/user_profil/pages/settings.dart' as page;

import '../../controllers/wallet_controller.dart';
import 'pages/notification.dart';

class NewUserProfil extends StatefulWidget {
  const NewUserProfil({super.key});

  @override
  State<NewUserProfil> createState() => _NewUserProfilState();
}

class _NewUserProfilState extends State<NewUserProfil> {
  bool showPage = false;
  final SettingsController settingsController = Get.put(SettingsController());
  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getUserMoney();
    getData();
  }

  dynamic getData() async {
    int a = 0;
    await AboutUsModel().getAboutUs().then((value) {
      print(value);
      for (var element in value) {
        if (element.pageShow == true) {
          a++;
        }
      }
    });
    if (a == 3) {
      showPage = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(
        backArrow: false,
        fontSize: 0.0,
        iconRemove: false,
        icon: SizedBox(),
        name: 'profil',
        elevationWhite: true,
      ),
      body: FutureBuilder<GetMeModel>(
        future: GetMeModel().getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: () {});
          } else if (snapshot.data == null) {
            return emptyData();
          }
          return Obx(() {
            return ListView(
              children: [
                settingsController.loginUser.value
                    ? ProfilButton(
                        name: 'profil',
                        onTap: () {
                          final data = snapshot.data;
                          if (data == null) return;
                          Get.to(
                            () => ProfileSettings(
                              medata: data,
                              image: data.image ?? '', // ✅ Safe null check
                            ),
                          );
                        },
                        icon: IconlyLight.profile,
                      )
                    : const SizedBox.shrink(),
                ProfilButton(
                  name: 'settings',
                  onTap: () {
                    Get.to(() => const page.Settings());
                  },
                  icon: IconlyLight.setting,
                ),
                ProfilButton(
                  name: 'notification',
                  onTap: () {
                    Get.to(() => NewNotificationPage());
                  },
                  icon: IconlyLight.notification,
                ),
                ProfilButton(
                  name: 'aboutUs',
                  onTap: () {
                    Get.to(() => const AboutUs());
                  },
                  icon: IconlyLight.infoSquare,
                ),
                loginLogout(context),
              ],
            );
          });
        },
      ),
    );
  }

  ProfilButton loginLogout(BuildContext context) {
    return ProfilButton(
      name: settingsController.loginUser.value ? 'log_out' : 'signUp',
      onTap: () {
        if (settingsController.loginUser.value == false) {
          Get.to(
            () => const TabBarViewPage(),
          );
        } else {
          logOut(context);
        }
      },
      icon: IconlyLight.login,
    );
  }
}
