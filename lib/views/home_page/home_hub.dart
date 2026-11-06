import 'package:flutter/material.dart';
import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/views/concurs/get_concurs.dart';
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E2713), Color(0xFF18181B), Color(0xFF121214)]),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
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
                      borderRadius: BorderRadius.circular(18),
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
                        borderRadius: BorderRadius.circular(23),
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
    );
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

/// The four sections under the balance: UC, tournaments, free UC and orders.
/// Each tile shows `assets/image/<image>.webp`; if it is missing an icon is drawn.
class HomeSections extends StatelessWidget {
  const HomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Section(label: 'homeBuyUc'.tr, image: 'home_uc', icon: HugeIcons.strokeRoundedCoins01, onTap: () => BottomNavBus.goTo(BottomNavBus.uc)),
      _Section(label: 'tournament'.tr, image: 'home_tournament', icon: HugeIcons.strokeRoundedCrown, onTap: () => BottomNavBus.goTo(BottomNavBus.premium)),
      _Section(label: 'homeFreeUc'.tr, image: 'home_free_uc', icon: HugeIcons.strokeRoundedGift, onTap: () => Get.to(() => const GetConcursScreen())),
      _Section(label: 'orders'.tr, image: 'home_orders', icon: HugeIcons.strokeRoundedTaskDone01, onTap: () => BottomNavBus.goTo(BottomNavBus.orders)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[if (i > 0) const SizedBox(width: 10), Expanded(child: tiles[i])],
        ],
      ),
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
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                color: const Color(0xFF141416),
              ),
              // The pictures carry their own dark background, so they fill the tile.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(
                  'assets/image/$image.webp',
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withValues(alpha: 0.12)),
                      child: HugeIcon(icon: icon, color: _gold, size: 26, strokeWidth: 1.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 12.5, height: 1.15),
          ),
        ],
      ),
    );
  }
}
