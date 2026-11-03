// ignore_for_file: missing_return, file_names, must_be_immutable, require_trailing_commas, deprecated_member_use

import 'package:game_app/views/buttons/animated_nav_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/views/buttons/floating_nav_bar.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:url_launcher/url_launcher.dart';

import 'views/home_page/home_page.dart';
import 'views/premium/premium_page.dart';
import 'views/tournament_page/new_tournamet_page.dart';
import 'views/user_profil/pages/history_orders_page.dart';
import 'views/user_profil/user_profil.dart';
import 'views/wallet/wallet_page.dart';

const _fullItems = [
  FloatingNavItem(
    kind: NavIconKind.home,
    icon: IconlyLight.home,
    selectedIcon: IconlyBold.home,
    label: 'bottomNavBar1',
  ),
  FloatingNavItem(
    kind: NavIconKind.gift,
    icon: IconlyLight.star,
    selectedIcon: IconlyBold.star,
    label: 'premium',
  ),
  FloatingNavItem(
    kind: NavIconKind.wallet,
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
    hugeIcon: HugeIcons.strokeRoundedWallet01,
    label: 'UC',
  ),
  FloatingNavItem(
    kind: NavIconKind.list,
    icon: IconlyLight.document,
    selectedIcon: IconlyBold.document,
    label: 'orderTab',
  ),
  FloatingNavItem(
    kind: NavIconKind.profile,
    icon: IconlyLight.profile,
    selectedIcon: IconlyBold.profile,
    label: 'profil',
  ),
];

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

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.showPages, super.key});
  final bool showPages;
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  List page = [
    const HomePage(),
    const PremiumPage(),
    const WalletPage(),
    const HistoryOrdersPage(backArrow: false),
    const UserProfil(),
  ];
  List page2 = [
    const HomePage(),
    const NewTournamentPage(),
    const UserProfil(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(
        items: widget.showPages ? _reviewItems : _fullItems,
        selectedIndex: selectedIndex,
        onTap: onTapp,
      ),
      body: Stack(
        children: [
          Center(
            child: widget.showPages == false
                ? page[selectedIndex]
                : page2[selectedIndex],
          ),
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
