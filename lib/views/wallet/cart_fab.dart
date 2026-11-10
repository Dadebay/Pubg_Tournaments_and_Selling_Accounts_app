import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/views/constants/index.dart';

/// Floating "go to cart" pill of the UC page. It slides up once the first
/// package is in the cart, bounces whenever the cart changes and its arrow
/// keeps nudging forward.
class CartFab extends StatefulWidget {
  const CartFab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  State<CartFab> createState() => _CartFabState();
}

class _CartFabState extends State<CartFab> with TickerProviderStateMixin {
  static const _gold = Color(0xFFFFC83D);

  final WalletController _cart = Get.find<WalletController>();

  late final AnimationController _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final AnimationController _arrow = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.09).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.09, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
  ]).animate(_bounce);

  Worker? _worker;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = _totalCount;
    _worker = ever(_cart.cartList, (_) {
      final count = _totalCount;
      if (count != _lastCount) {
        _bounce.forward(from: 0);
      }
      _lastCount = count;
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _bounce.dispose();
    _arrow.dispose();
    super.dispose();
  }

  int get _totalCount {
    var total = 0;
    for (final item in _cart.cartList) {
      total += item['count'] as int;
    }
    return total;
  }

  double get _totalPrice {
    var total = 0.0;
    for (final item in _cart.cartList) {
      total += (double.tryParse('${item['price']}') ?? 0) * (item['count'] as int);
    }
    return total;
  }

  String _price(double value) => '${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(2)} TMT';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visible = _cart.cartList.isNotEmpty;
      final count = _totalCount;
      final price = _totalPrice;
      return AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 1.6),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !visible,
            child: ScaleTransition(scale: _scale, child: _pill(count, price)),
          ),
        ),
      );
    });
  }

  /// A slim dark bar: the cart count and total on the left, a small gold arrow
  /// button on the right, so only the arrow carries the accent colour.
  Widget _pill(int count, double price) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xEE1C1C20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cartIcon(count),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'goToCart'.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 15, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  _price(price),
                  style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 13, height: 1),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
              // Center loosens the circle's tight constraints, otherwise the icon
              // stretches to the full circle whatever its size is.
              child: Center(
                child: AnimatedBuilder(
                  animation: _arrow,
                  builder: (context, child) => Transform.translate(offset: Offset(3 * Curves.easeInOut.transform(_arrow.value), 0), child: child),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Color(0xFF1A1200), size: 18, strokeWidth: 2.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartIcon(int count) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: Colors.white, size: 26, strokeWidth: 1.6),
          ),
          Positioned(
            right: -8,
            top: -6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Container(
                key: ValueKey(count),
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(9)),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 11, height: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
