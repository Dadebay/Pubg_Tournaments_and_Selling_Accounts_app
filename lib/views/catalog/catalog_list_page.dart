import 'package:game_app/models/catalog_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/catalog/catalog_detail_page.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// The brands of one kind: games (`/games/`), programs (`/programs/`) or gift cards
/// (`/gifts/`). A tap opens the brand with its products.
class CatalogListPage extends StatefulWidget {
  const CatalogListPage({required this.kind, super.key});

  /// `game`, `program` or `gift`.
  final String kind;

  @override
  State<CatalogListPage> createState() => _CatalogListPageState();
}

class _CatalogListPageState extends State<CatalogListPage> {
  late Future<List<CatalogBrand>> _future = _load();

  String get _title => switch (widget.kind) {
    'program' => 'homePrograms'.tr,
    'gift' => 'homeGifts'.tr,
    _ => 'homeGames'.tr,
  };

  Future<List<CatalogBrand>> _load() async {
    final result = await UcdayyApi.getCatalog(widget.kind);
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    final data = result.data;
    final items = data is List ? data : apiItems(data);
    return [for (final item in items.whereType<Map>()) CatalogBrand.fromJson(item, kind: widget.kind)];
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: _title, onBack: Get.back),
            Expanded(
              child: FutureBuilder<List<CatalogBrand>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Shimmer(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(child: ShimmerBlock(height: 220, radius: 24)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerBlock(height: 220, radius: 24)),
                          ],
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data ?? const <CatalogBrand>[];
                  if (snapshot.hasError) {
                    return Center(
                      child: CatalogEmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'catalogLoadFailed'.tr,
                        description: '',
                        actionLabel: 'noConnection3'.tr,
                        actionIcon: Icons.refresh_rounded,
                        onAction: _refresh,
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.inventory_2_outlined, title: 'catalogNoItems'.tr, description: ''),
                    );
                  }
                  return RefreshIndicator(
                    color: catalogGold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _refresh,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.74),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _tile(items[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A brand card: the picture in a rounded frame with the number of products as a
  /// gold pill on it, and the name under it with a small arrow.
  Widget _tile(CatalogBrand brand) {
    return GestureDetector(
      onTap: () => Get.to(() => CatalogDetailPage(kind: widget.kind, brand: brand)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: catalogGold.withValues(alpha: 0.4), width: 1.3),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF26231A), Color(0xFF141416)]),
          boxShadow: [BoxShadow(color: catalogGold.withValues(alpha: 0.1), blurRadius: 14)],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CatalogImage(url: brand.image),
                    if (brand.productsCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withValues(alpha: 0.65),
                            border: Border.all(color: catalogGold.withValues(alpha: 0.7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: catalogGold, size: 13, strokeWidth: 2),
                              const SizedBox(width: 4),
                              Text(
                                '${brand.productsCount}',
                                style: const TextStyle(color: catalogGold, fontFamily: gilroyBold, fontSize: 12.5, height: 1.1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        brand.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 15, height: 1.15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: catalogGold.withValues(alpha: 0.14),
                    border: Border.all(color: catalogGold.withValues(alpha: 0.5)),
                  ),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: catalogGold, size: 15, strokeWidth: 2.2),
                ),
                const SizedBox(width: 2),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
