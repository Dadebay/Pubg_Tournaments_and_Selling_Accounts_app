// ignore_for_file: missing_return, file_names, must_be_immutable, require_trailing_commas, deprecated_member_use

import 'package:game_app/views/buttons/animated_nav_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/views/buttons/floating_nav_bar.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:url_launcher/url_launcher.dart';

import 'views/home_page/home_page.dart';
import 'views/premium/premium_page.dart';
import 'views/tournament_page/new_tournamet_page.dart';

import 'package:game_app/views/orders/orders_history_page.dart';

import 'views/user_profil/user_profil.dart';
import 'views/wallet/wallet_page.dart';

const _fullItems = [
  FloatingNavItem(kind: NavIconKind.home, icon: IconlyLight.home, selectedIcon: IconlyBold.home, label: 'bottomNavBar1'),
  FloatingNavItem(kind: NavIconKind.gift, icon: IconlyLight.star, selectedIcon: IconlyBold.star, label: 'premium'),
  FloatingNavItem(kind: NavIconKind.wallet, icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet, hugeIcon: HugeIcons.strokeRoundedWallet01, label: 'UC'),
  FloatingNavItem(kind: NavIconKind.list, icon: IconlyLight.document, selectedIcon: IconlyBold.document, label: 'orderTab'),
  FloatingNavItem(kind: NavIconKind.profile, icon: IconlyLight.profile, selectedIcon: IconlyBold.profile, label: 'profil'),
];

// Apple (review) build: home, list and profile only.
const _reviewItems = [
  FloatingNavItem(kind: NavIconKind.home, icon: IconlyLight.home, selectedIcon: IconlyBold.home, label: 'bottomNavBar1'),
  FloatingNavItem(kind: NavIconKind.list, icon: IconlyLight.document, selectedIcon: IconlyBold.document, label: 'bottomNavBar2'),
  FloatingNavItem(kind: NavIconKind.profile, icon: IconlyLight.profile, selectedIcon: IconlyBold.profile, label: 'profil'),
];

/// Lets any page switch the bottom bar tab, e.g. the home page tiles:
/// `BottomNavBus.goTo(BottomNavBus.uc)`.
class BottomNavBus {
  const BottomNavBus._();

  static const int home = 0;
  static const int premium = 1;
  static const int uc = 2;
  static const int orders = 3;
  static const int profile = 4;

  /// The tab that is selected (the bar keeps it in step when the player taps a tab).
  static final ValueNotifier<int> index = ValueNotifier<int>(0);

  static void goTo(int tab) => index.value = tab;
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.showPages, super.key});
  final bool showPages;
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    BottomNavBus.index.value = 0;
    BottomNavBus.index.addListener(_onBus);
  }

  @override
  void dispose() {
    BottomNavBus.index.removeListener(_onBus);
    super.dispose();
  }

  /// A page asked for another tab (only the full bar has them all).
  void _onBus() {
    final tab = BottomNavBus.index.value;
    if (!mounted || widget.showPages || tab == selectedIndex || tab >= page.length) {
      return;
    }
    // Back to the tab root if a page was opened on top of the home page.
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => selectedIndex = tab);
  }

  List page = [const HomePage(), const PremiumPage(), const WalletPage(), const OrdersHistoryPage(backArrow: false), const UserProfil()];
  List page2 = [const HomePage(), const NewTournamentPage(), const UserProfil()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(items: widget.showPages ? _reviewItems : _fullItems, selectedIndex: selectedIndex, onTap: onTapp),
      body: Stack(
        children: [
          Center(child: widget.showPages == false ? page[selectedIndex] : page2[selectedIndex]),
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
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 30),
            ),
            const SizedBox(height: 15),
            Text(
              'blokedSubtitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 25),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
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
                  style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold, fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapp(int index) async {
    BottomNavBus.index.value = index;
    setState(() {
      selectedIndex = index;
    });
  }
}
