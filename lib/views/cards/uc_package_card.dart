import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';

/// One UC package on the UC page: the pack image, its name and a price pill.
/// Tapping the card puts it in the cart; once it is in the cart the price pill
/// turns into a quantity stepper.
class UcPackageCard extends StatelessWidget {
  const UcPackageCard({required this.model, super.key});

  final UcModel model;

  static const _gold = Color(0xFFFFC83D);

  WalletController get _cart => Get.find<WalletController>();

  int get _count {
    for (final item in _cart.cartList) {
      if (item['id'] == model.id) {
        return item['count'] as int;
      }
    }
    return 0;
  }

  void _add() {
    _cart.addCart(id: model.id!, image: model.image!, price: model.price!, title: model.title!, status: 'uc');
    _cart.cartList.refresh();
  }

  void _minus() {
    if (_count <= 1) {
      _cart.removeCart(model.id!);
    } else {
      _cart.minusCart(model.id!);
    }
    _cart.cartList.refresh();
  }

  Future<void> _showDetail() async {
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
        decoration: const BoxDecoration(color: Color(0xFF151517), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data['title'] ?? model.title}', style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22)),
            const SizedBox(height: 8),
            Text(_priceText, style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 18)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description, style: const TextStyle(color: Colors.white70, fontFamily: gilroyRegular, fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  String get _priceText {
    final value = double.tryParse(model.price ?? '');
    if (value == null) {
      return '${model.price} TMT';
    }
    return '${value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2)} TMT';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = _count;
      final selected = count > 0;
      return GestureDetector(
        onTap: _add,
        onLongPress: _showDetail,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
            border: Border.all(color: selected ? kPrimaryColor : Colors.white.withValues(alpha: 0.07), width: selected ? 1.6 : 1),
            boxShadow: selected ? [BoxShadow(color: kPrimaryColor.withValues(alpha: 0.28), blurRadius: 18, spreadRadius: 0)] : const [],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CachedNetworkImage(
                    imageUrl: '$serverURL${model.image}',
                    fit: BoxFit.contain,
                    fadeInCurve: Curves.ease,
                    placeholder: (context, url) => Center(child: spinKit()),
                    errorWidget: (context, url, error) => Center(
                      child: Text('noImage'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                model.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 17),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected ? _stepper(count) : _pricePill(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _pricePill() {
    return Container(
      key: const ValueKey('price'),
      height: 40,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(14)),
      child: Text(_priceText, style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 16)),
    );
  }

  Widget _stepper(int count) {
    return Container(
      key: const ValueKey('stepper'),
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _stepButton(CupertinoIcons.minus, _minus),
          Expanded(
            child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 18)),
          ),
          _stepButton(CupertinoIcons.add, _add),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 40,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
