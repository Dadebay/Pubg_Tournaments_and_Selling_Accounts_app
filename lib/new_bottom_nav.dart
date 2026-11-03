// ignore_for_file: missing_return, file_names, must_be_immutable, require_trailing_commas, deprecated_member_use

import 'package:game_app/views/buttons/animated_nav_icon.dart';
import 'package:game_app/views/buttons/floating_nav_bar.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/new_home_page.dart';
import 'package:game_app/views/tournament_page/tounament_page_not.dart';
import 'package:game_app/views/user_profil/new_user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

// Apple (review) build: home, list and profile only.
const _reviewItems = [
  FloatingNavItem(
    kind: NavIconKind.home,
    icon: IconlyLight.home,
    selectedIcon: IconlyBold.home,
    label: 'bottomNavBar1',
  ),
  FloatingNavItem(
    kind: NavIconKind.list,
    icon: IconlyLight.document,
    selectedIcon: IconlyBold.document,
    label: 'bottomNavBar2',
  ),
  FloatingNavItem(
    kind: NavIconKind.profile,
    icon: IconlyLight.profile,
    selectedIcon: IconlyBold.profile,
    label: 'profil',
  ),
];

class NewBottomNavBar extends StatefulWidget {
  const NewBottomNavBar({required this.showPages, super.key});
  final bool showPages;
  @override
  State<NewBottomNavBar> createState() => _NewBottomNavBarState();
}

class _NewBottomNavBarState extends State<NewBottomNavBar> {
  int selectedIndex = 0;

  List page2 = [
    const NewHomePage(),
    const NotTournamentPage(),
    const NewUserProfil(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(
        items: _reviewItems,
        selectedIndex: selectedIndex,
        onTap: onTapp,
      ),
      body: Stack(
        children: [
          Center(child: page2[selectedIndex]),
          // blokedPage(),
        ],
      ),
    );
  }

  Widget blokedPage() {
    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.all(15),
        color: kPrimaryColorBlack.withOpacity(0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'blokedTitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: gilroyBold,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'blokedSubtitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: gilroySemiBold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: Get.size.width,
              child: ElevatedButton(
                onPressed: () async {
                  await launch('tel://+99362222307');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: borderRadius15,
                  ),
                ),
                child: Text(
                  'popUP1'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontFamily: gilroySemiBold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapp(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }
}
