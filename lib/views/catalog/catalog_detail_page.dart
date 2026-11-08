import 'package:game_app/models/catalog_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_buy.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// One game, program or gift brand: its picture, description and the products to buy.
class CatalogDetailPage extends StatefulWidget {
  const CatalogDetailPage({required this.kind, required this.brand, super.key});

  final String kind;
  final CatalogBrand brand;

  @override
  State<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends State<CatalogDetailPage> {
  late CatalogBrand _brand = widget.brand;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// A game id is not valid on `/programs/{id}/` (404), so the kind decides the address.
  Future<void> _load() async {
    final result = await UcdayyApi.getCatalogItem(widget.kind, widget.brand.id);
    if (!mounted) {
      return;
    }
    final data = result.data;
    setState(() {
      _loading = false;
      if (result.ok && data is Map) {
        _brand = CatalogBrand.fromJson(data, kind: widget.kind);
        _failed = false;
      } else {
        _failed = _brand.products.isEmpty;
      }
    });
  }

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: Stack(
        children: [
          RefreshIndicator(
            color: catalogGold,
            backgroundColor: const Color(0xFF1C1C20),
            edgeOffset: top + 60,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                _hero(top),
                if (_brand.description.isNotEmpty) _description(),
                const SizedBox(height: 18),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _products()),
              ],
            ),
          ),
          Positioned(
            top: top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, size: 22, strokeWidth: 2),
                  ),
                ),
                const Spacer(),
                const BalanceChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The brand's picture fading into the page, with its name and the number of products on it.
  Widget _hero(double top) {
    return SizedBox(
      height: 300 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CatalogImage(url: _brand.image),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Colors.transparent, Color(0xCC0D0E12), kPrimaryColorBlack],
                stops: [0, 0.35, 0.8, 1],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_brand.products.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: catalogGold.withValues(alpha: 0.18),
                      border: Border.all(color: catalogGold.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: catalogGold, size: 14, strokeWidth: 2),
                        const SizedBox(width: 6),
                        Text(
                          '${_brand.products.length}',
                          style: const TextStyle(color: catalogGold, fontFamily: gilroyBold, fontSize: 13, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _brand.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroyBold,
                    fontSize: 30,
                    height: 1.1,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The description in a soft card; long text shows three lines and opens on a tap.
  Widget _description() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            _brand.description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFD5D5DA), fontFamily: gilroyMedium, fontSize: 15, height: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _products() {
    if (_loading && _brand.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: catalogGold)),
      );
    }
    if (_failed) {
      return CatalogEmptyState(icon: Icons.cloud_off_outlined, title: 'catalogLoadFailed'.tr, description: '', actionLabel: 'noConnection3'.tr, actionIcon: Icons.refresh_rounded, onAction: _load);
    }
    if (_brand.products.isEmpty) {
      return CatalogEmptyState(icon: Icons.inventory_2_outlined, title: 'catalogNoItems'.tr, description: '');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _brand.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72),
      itemBuilder: (context, index) => _productCard(_brand.products[index]),
    );
  }

  /// A product: picture, name, short description, the codes left (gift cards) and the price button.
  Widget _productCard(CatalogProduct product) {
    final soldOut = product.soldOut;
    return GestureDetector(
      onTap: soldOut
          ? null
          : () async {
              final bought = await showCatalogBuy(context, kind: widget.kind, product: product);
              if (bought) {
                _load();
              }
            },
      child: Opacity(
        opacity: soldOut ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF26262B), Color(0xFF121214)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CatalogImage(url: product.image),
                      if (product.inStock != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.black.withValues(alpha: 0.65)),
                            child: Text(
                              soldOut ? 'catalogOutOfStock'.tr : '${'catalogLeft'.tr}: ${product.inStock}',
                              style: TextStyle(color: soldOut ? const Color(0xFFFF6B6B) : const Color(0xFF34D399), fontFamily: gilroySemiBold, fontSize: 11.5, height: 1.1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 15, height: 1.15),
                    ),
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: soldOut ? null : const LinearGradient(colors: [Color(0xFFFFD866), catalogGoldDark]),
                  color: soldOut ? Colors.white12 : null,
                ),
                child: Text.rich(
                  TextSpan(
                    text: catalogMoney(product.price),
                    style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                    children: const [TextSpan(text: ' TMT', style: TextStyle(fontSize: 11))],
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
