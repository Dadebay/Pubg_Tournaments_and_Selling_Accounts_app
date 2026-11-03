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
import 'package:game_app/views/user_profil/pages/legal_page.dart';
import 'package:game_app/views/user_profil/pages/edit_work_profil.dart';
import 'package:game_app/views/user_profil/pages/profile_settings.dart';
import 'package:game_app/views/user_profil/pages/settings.dart' as page;

import 'pages/notification.dart';

class UserProfil extends StatefulWidget {
  const UserProfil({super.key});

  @override
  State<UserProfil> createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  bool showPage = false;
  final SettingsController settingsController = Get.put(SettingsController());

  /// My account, loaded when the tab opens and again on pull to refresh. The same
  /// answer updates the balance, so the page makes one request instead of two.
  late Future<GetMeModel> _me = GetMeModel().getMeAndBalance();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> _refresh() async {
    final future = GetMeModel().getMeAndBalance();
    setState(() => _me = future);
    await future;
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
      appBar: MyAppBar(
        backArrow: false,
        fontSize: 0.0,
        iconRemove: true,
        name: 'profil',
        elevationWhite: true,
      ),
      body: FutureBuilder<GetMeModel>(
        future: _me,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: _refresh);
          } else if (snapshot.data == null) {
            return emptyData();
          }
          return Obx(() {
            return RefreshIndicator(
              color: const Color(0xFFFFC83D),
              backgroundColor: const Color(0xFF1C1C20),
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 120),
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
                      Get.to(() => NotificationPage());
                    },
                    icon: IconlyLight.notification,
                  ),
                  settingsController.loginUser.value
                      ? whenUserLogin(snapshot.data!.forSale!, snapshot.data!)
                      : const SizedBox.shrink(),
                  // settingsController.loginUser.value ? whenUserLogin(true, snapshot.data!) : const SizedBox.shrink(),
                  ProfilButton(
                    name: 'aboutUs',
                    onTap: () {
                      Get.to(() => const AboutUs());
                    },
                    icon: IconlyLight.infoSquare,
                  ),
                  ProfilButton(
                    name: 'termsOfUse',
                    onTap: () {
                      Get.to(() => const LegalPage(kind: LegalKind.terms));
                    },
                    icon: IconlyLight.document,
                  ),
                  ProfilButton(
                    name: 'privacy',
                    onTap: () {
                      Get.to(() => const LegalPage(kind: LegalKind.privacy));
                    },
                    icon: IconlyLight.shieldDone,
                  ),
                  const SizedBox(height: 6),
                  loginLogout(context),
                ],
              ),
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
          Get.to(() => const TabBarViewPage());
        } else {
          logOut(context);
        }
      },
      icon: IconlyLight.login,
      danger: settingsController.loginUser.value,
    );
  }

  Column whenUserLogin(bool forSale, GetMeModel model) {
    return Column(
      children: [
        showPage == false
            ? ProfilButton(
                name: 'cashHistory',
                onTap: () {
                  Get.to(
                    () => const TopUpScreen(
                      // text: 'message',
                      // textSend: 'requestCash'.tr,
                    ),
                  );
                },
                icon: IconlyLight.wallet,
              )
            : const SizedBox(),
        forSale
            ? ProfilButton(
                name: 'editProfil',
                onTap: () {
                  Get.to(() => EditWorkProfile(model: model));
                },
                icon: IconlyLight.category,
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
