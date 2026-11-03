import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/user_profil/pages/bought_gifts.dart';
import 'package:game_app/views/user_profil/pages/bought_konkurs.dart';
import 'package:game_app/views/user_profil/pages/history_orders_page.dart';
import 'package:hugeicons/hugeicons.dart';

/// "My orders" of the profile: four tiles, one per kind of purchase.
class BoughtThings extends StatelessWidget {
  const BoughtThings({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Tile(
        'boughtUC',
        HugeIcons.strokeRoundedCoins01,
        const Color(0xFF34D399),
        () => Get.to(() => const HistoryOrdersPage()),
      ),
      _Tile(
        'boughtGifts',
        HugeIcons.strokeRoundedGift,
        const Color(0xFFFF7AB6),
        () => Get.to(() => const BoughtGifts()),
      ),
      _Tile(
        'boughtKonkurs',
        HugeIcons.strokeRoundedAward01,
        const Color(0xFFFFC83D),
        () => Get.to(() => const BoughtKonkurs()),
      ),
      _Tile(
        'boughtCODES',
        HugeIcons.strokeRoundedKey01,
        const Color(0xFF60A5FA),
        () => Get.to(() => const BoughtCODES()),
      ),
    ];
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CenteredHeader(title: 'orders'.tr, onBack: Get.back),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (var i = 0; i < tiles.length; i++)
                    // Each tile slides up a little after the one before it.
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 380 + i * 90),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 22 * (1 - t)),
                          child: child,
                        ),
                      ),
                      child: _TileCard(tile: tiles[i]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  const _Tile(this.title, this.icon, this.color, this.onTap);

  final String title;
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onTap;
}

class _TileCard extends StatelessWidget {
  const _TileCard({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    final color = tile.color;
    return GestureDetector(
      onTap: tile.onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.28), const Color(0xFF141416)],
          ),
          border: Border.all(color: color.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // A large faded copy of the icon in the corner.
            Positioned(
              right: -18,
              bottom: -18,
              child: Transform.rotate(
                angle: -0.3,
                child: HugeIcon(
                  icon: tile.icon,
                  color: color.withValues(alpha: 0.13),
                  size: 110,
                  strokeWidth: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: color.withValues(alpha: 0.18),
                          border: Border.all(
                            color: color.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: tile.icon,
                            color: color,
                            size: 30,
                            strokeWidth: 1.6,
                          ),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowUpRight01,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tile.title.tr,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: gilroyBold,
                      fontSize: 19,
                      height: 1.15,
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
}
