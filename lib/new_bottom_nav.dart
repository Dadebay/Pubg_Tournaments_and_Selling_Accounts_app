// ignore_for_file: missing_return, file_names, must_be_immutable, require_trailing_commas, deprecated_member_use

import 'package:game_app/views/buttons/bottom_nav_bar_button.dart';
import 'package:game_app/views/concurs/koncurs_screen.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/new_home_page.dart';
import 'package:game_app/views/tournament_page/tounament_page_not.dart';
import 'package:game_app/views/user_profil/new_user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'views/home_page/home_page.dart';
import 'views/tournament_page/new_tournamet_page.dart';
import 'views/user_profil/user_profil.dart';
import 'views/wallet/wallet_page.dart';

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
        bottomNavigationBar: Container(
          color: kPrimaryColorBlack,
          height: kBottomNavigationBarHeight,
          child: Row(
            children: [
              Expanded(
                  child: BottomNavbarButton(
                icon: false,
                index: 0,
                selectedIndex: selectedIndex,
                showPage: widget.showPages,
                onTapp: () => onTapp(0),
              )),
              Expanded(
                  child: BottomNavbarButton(
                icon: false,
                index: 1,
                selectedIndex: selectedIndex,
                showPage: widget.showPages,
                onTapp: () => onTapp(1),
              )),
              widget.showPages
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: BottomNavbarButton(
                      icon: true,
                      index: 2,
                      selectedIndex: selectedIndex,
                      showPage: widget.showPages,
                      onTapp: () => onTapp(2),
                    )),
              widget.showPages
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: BottomNavbarButton(
                      icon: false,
                      index: 3,
                      selectedIndex: selectedIndex,
                      onTapp: () => onTapp(3),
                      showPage: widget.showPages,
                    )),
              Expanded(
                  child: BottomNavbarButton(
                icon: false,
                index: widget.showPages ? 2 : 4,
                selectedIndex: selectedIndex,
                showPage: widget.showPages,
                onTapp: () => onTapp(widget.showPages ? 2 : 4),
              )),
            ],
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: page2[selectedIndex],
            ),
            // blokedPage(),
          ],
        ));
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
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontSize: 30),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'blokedSubtitle'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 25),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: Get.size.width,
            child: ElevatedButton(
              onPressed: () async {
                await launch('tel://+99362222307');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
              ),
              child: Text(
                'popUP1'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansSemiBold, fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void onTapp(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }
}
