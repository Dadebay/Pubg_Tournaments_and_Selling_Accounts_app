import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/views/catalog/catalog_list_page.dart';
import 'package:game_app/views/other_pages/show_all_acconts.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// The balance under the banner: a gold-lit wallet badge, the amount in TMT and
/// the top-up button, over soft glowing circles.
class HomeBalanceCard extends StatelessWidget {
  const HomeBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.75), width: 1.8),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E2713), Color(0xFF18181B), Color(0xFF121214)]),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.2), blurRadius: 22)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Soft rings in the corner, like coins catching the light.
            Positioned(right: -34, top: -44, child: _ring(130, 0.08)),
            Positioned(right: 20, top: -14, child: _ring(56, 0.07)),
            Positioned(left: -26, bottom: -40, child: _ring(96, 0.06)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE08A), _goldDark]),
                      boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 5))],
                    ),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: Color(0xFF1A1200), size: 28, strokeWidth: 1.9),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'balance'.tr,
                          style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroySemiBold, fontSize: 13),
                        ),
                        const SizedBox(height: 3),
                        Obx(() {
                          final money = Get.find<WalletController>().userMoney.value;
                          final amount = double.tryParse(money);
                          final text = amount == null ? money : amount.toStringAsFixed(2);
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: text,
                                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 30, height: 1.05),
                                children: const [
                                  TextSpan(
                                    text: ' TMT',
                                    style: TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Get.to(() => const TopUpScreen()),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.only(left: 12, right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: Colors.black, size: 18, strokeWidth: 2.6),
                          const SizedBox(width: 6),
                          Text(
                            'add_monay'.tr,
                            style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )));
  }

  Widget _ring(double size, double alpha) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _gold.withValues(alpha: alpha * 2), width: 1.5),
          color: _gold.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

/// The four sections under the balance: games, programs, gift cards and accounts for sale.
/// Each tile shows a scalable gold icon; a bundled icon is the fallback.
class HomeSections extends StatelessWidget {
  const HomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Section(
        label: 'homeGames'.tr,
        image: 'home_games',
        icon: HugeIcons.strokeRoundedGameController03,
        onTap: () => Get.to(() => const CatalogListPage(kind: 'game')),
      ),
      _Section(
        label: 'homePrograms'.tr,
        image: 'home_programs',
        icon: HugeIcons.strokeRoundedDashboardSquare01,
        onTap: () => Get.to(() => const CatalogListPage(kind: 'program')),
      ),
      _Section(
        label: 'homeGifts'.tr,
        image: 'home_gifts',
        icon: HugeIcons.strokeRoundedGift,
        onTap: () => Get.to(() => const CatalogListPage(kind: 'gift')),
      ),
      _Section(
        label: 'homeAccounts'.tr,
        image: 'home_accounts',
        icon: HugeIcons.strokeRoundedUserStar01,
        onTap: () => Get.to(() => const ShowAllAccounts(name: 'accountsForSale')),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[if (i > 0) const SizedBox(width: 9), Expanded(child: tiles[i])],
        ],
      ))),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.image, required this.icon, required this.onTap});

  final String label;
  final String image;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _gold.withValues(alpha: 0.8), width: 1.6),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF261D0D), Color(0xFF0E0D0C)]),
            boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.22), blurRadius: 16)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/$image.svg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => HugeIcon(icon: icon, color: _gold, size: 40, strokeWidth: 1.8),
                  ),
                ),
              ),
              if (label.contains(' '))
                Text(
                  label,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 11.5, height: 1.1),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 12, height: 1.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
