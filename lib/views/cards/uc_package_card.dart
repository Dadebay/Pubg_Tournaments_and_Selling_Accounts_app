import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';

const _gold = Color(0xFFFFC83D);

/// Cart access shared by the UC and premium cards.
class UcCart {
  const UcCart._();

  static WalletController get _cart => Get.find<WalletController>();

  static int count(UcModel model) {
    for (final item in _cart.cartList) {
      if (item['id'] == model.id) {
        return item['count'] as int;
      }
    }
    return 0;
  }

  static void add(UcModel model) {
    _cart.addCart(id: model.id!, image: model.image!, price: model.price!, title: model.title!, status: 'uc');
    _cart.cartList.refresh();
  }

  static void minus(UcModel model) {
    if (count(model) <= 1) {
      _cart.removeCart(model.id!);
    } else {
      _cart.minusCart(model.id!);
    }
    _cart.cartList.refresh();
  }

  /// The API sends absolute image urls; older answers sent a path on our server.
  static String imageUrl(UcModel model) {
    final image = model.image ?? '';
    return image.startsWith('http') ? image : '$serverURL$image';
  }

  static String priceText(UcModel model) {
    final value = double.tryParse(model.price ?? '');
    if (value == null) {
      return '${model.price} TMT';
    }
    return '${value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2)} TMT';
  }

  /// Description in the app language, without the `null` the model stores for a missing one.
  static String description(UcModel model) {
    final isRu = Get.locale?.languageCode == 'ru';
    final text = (isRu ? model.description_ru : model.description_tm) ?? '';
    return text == 'null' ? '' : text;
  }

  static Future<void> showDetail(UcModel model) async {
    final result = await UcdayyApi.getUcDetail(model.id!);
    final data = result.data;
    if (!result.ok || data is! Map) {
      return;
    }
    final isRu = Get.locale?.languageCode == 'ru';
    final description = '${data[isRu ? 'description_ru' : 'description_tm'] ?? data['description'] ?? ''}';
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF151517),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['title'] ?? model.title}',
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              priceText(model),
              style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 18),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontFamily: gilroyRegular, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Plus / minus control that replaces the price once a package is in the cart.
class UcStepper extends StatelessWidget {
  const UcStepper({required this.model, super.key});

  final UcModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _button(CupertinoIcons.minus, () => UcCart.minus(model)),
          Expanded(
            child: Text(
              '${UcCart.count(model)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 18),
            ),
          ),
          _button(CupertinoIcons.add, () => UcCart.add(model)),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: 44, height: 42, child: Icon(icon, color: Colors.white, size: 18)),
    );
  }
}

/// One UC package: a voucher with a glowing pack image, the UC amount in large
/// type and a torn-off price strip. Tapping puts it in the cart; once it is in
/// the cart the price strip turns into a quantity stepper.
class UcPackageCard extends StatelessWidget {
  const UcPackageCard({required this.model, super.key});

  final UcModel model;

  /// "660 UC" → ("660", "UC"); a title without a leading number is shown whole.
  (String, String) get _title {
    final match = RegExp(r'^\s*([\d\s.,]+)\s*(.*)$').firstMatch(model.title ?? '');
    if (match == null || match.group(1)!.trim().isEmpty) {
      return (model.title ?? '', '');
    }
    return (match.group(1)!.trim(), match.group(2)!.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = UcCart.count(model) > 0;
      final (amount, unit) = _title;
      return GestureDetector(
        onTap: () => UcCart.add(model),
        onLongPress: () => UcCart.showDetail(model),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF26262B), Color(0xFF121214)]),
            border: Border.all(color: selected ? _gold : Colors.white.withValues(alpha: 0.08), width: selected ? 1.6 : 1),
            boxShadow: selected ? [BoxShadow(color: _gold.withValues(alpha: 0.25), blurRadius: 20)] : const [],
          ),
          child: Column(
            children: [
              Expanded(child: _art()),
              _amount(amount, unit),
              const Padding(padding: EdgeInsets.fromLTRB(16, 10, 16, 10), child: _DashedLine()),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: selected ? UcStepper(key: const ValueKey('stepper'), model: model) : _priceStrip(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _art() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: RadialGradient(center: const Alignment(0, 0.1), radius: 0.8, colors: [_gold.withValues(alpha: 0.26), Colors.transparent]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
          child: CachedNetworkImage(
            imageUrl: UcCart.imageUrl(model),
            fit: BoxFit.contain,
            fadeInCurve: Curves.ease,
            placeholder: (context, url) => const Shimmer(child: Center(child: ShimmerBlock(width: 80, height: 80, radius: 24))),
            errorWidget: (context, url, error) => Center(child: Icon(CupertinoIcons.photo, color: Colors.white.withValues(alpha: 0.3), size: 36)),
          ),
        ),
      ],
    );
  }

  /// The UC amount under the pack image, centered above the tear line.
  Widget _amount(String amount, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 24, height: 1),
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(
            unit,
            style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 14, height: 1),
          ),
        ],
      ],
    );
  }

  Widget _priceStrip() {
    return Container(
      key: const ValueKey('price'),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
      ),
      child: Text(
        UcCart.priceText(model),
        style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 16),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashes = (constraints.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashes, (_) => Container(width: 4, height: 1.2, color: Colors.white.withValues(alpha: 0.16))),
        );
      },
    );
  }
}
