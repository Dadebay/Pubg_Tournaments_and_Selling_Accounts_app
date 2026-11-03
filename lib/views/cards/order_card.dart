import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// One line of the order page: the product on a glowing plate, its name and unit
/// price, the quantity, the line total and a remove button.
class OrderCard extends StatelessWidget {
  final int id;
  final int count;
  final String title;
  final String image;
  final String status;
  final String price;
  const OrderCard({
    required this.id,
    required this.count,
    required this.title,
    required this.status,
    required this.image,
    required this.price,
    super.key,
  });

  static const _gold = Color(0xFFFFC83D);

  WalletController get _cart => Get.find<WalletController>();

  int get _count {
    for (final item in _cart.cartList) {
      if (item['id'] == id) {
        return item['count'] as int;
      }
    }
    return count;
  }

  void _remove() {
    _cart.removeCart(id);
    _cart.cartList.refresh();
  }

  String _money(double value) =>
      '${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(2)} TMT';

  @override
  Widget build(BuildContext context) {
    final unit = double.tryParse(price) ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232327), Color(0xFF141416)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _plate(),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() {
              final current = _count;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: gilroyBold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _remove,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 4),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            color: Color(0xFF8D9AB8),
                            size: 20,
                            strokeWidth: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _money(unit),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontFamily: gilroyMedium,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _countBadge(current),
                      const Spacer(),
                      Text(
                        _money(unit * current),
                        style: const TextStyle(
                          color: _gold,
                          fontFamily: gilroyBold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _plate() {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          colors: [
            _gold.withValues(alpha: 0.26),
            Colors.black.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.22)),
      ),
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.contain,
        fadeInCurve: Curves.ease,
        placeholder: (context, url) => Center(child: spinKit()),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            CupertinoIcons.photo,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  /// The quantity is fixed once the user is in the cart; only the whole line can be removed.
  Widget _countBadge(int current) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        '× $current',
        style: const TextStyle(
          color: _gold,
          fontFamily: gilroyBold,
          fontSize: 16,
          height: 1,
        ),
      ),
    );
  }
}
