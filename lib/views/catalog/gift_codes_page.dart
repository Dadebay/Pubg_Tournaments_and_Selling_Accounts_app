import 'package:game_app/models/catalog_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';

import '../constants/index.dart';

/// The gift codes the player bought (`/gifts/my-codes/`), each with a copy button.
class GiftCodesPage extends StatefulWidget {
  const GiftCodesPage({super.key});

  @override
  State<GiftCodesPage> createState() => _GiftCodesPageState();
}

class _GiftCodesPageState extends State<GiftCodesPage> {
  late Future<List<GiftCode>> _future = _load();

  Future<List<GiftCode>> _load() async {
    final result = await UcdayyApi.getMyGiftCodes();
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    final data = result.data;
    final items = data is List ? data : apiItems(data);
    return [for (final item in items.whereType<Map>()) GiftCode.fromJson(item)];
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    try {
      await _future;
    } catch (_) {}
  }

  String _date(DateTime? value) {
    if (value == null) {
      return '';
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}.${two(value.month)}.${value.year}  ${two(value.hour)}:${two(value.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'catalogMyCodes'.tr, onBack: Get.back),
            Expanded(
              child: FutureBuilder<List<GiftCode>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: catalogGold));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.cloud_off_outlined, title: 'catalogLoadFailed'.tr, description: '', actionLabel: 'noConnection3'.tr, actionIcon: Icons.refresh_rounded, onAction: _refresh),
                    );
                  }
                  final codes = snapshot.data ?? const <GiftCode>[];
                  if (codes.isEmpty) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.key_outlined, title: 'catalogNoCodes'.tr, description: ''),
                    );
                  }
                  return RefreshIndicator(
                    color: catalogGold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: codes.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => _card(codes[index]),
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

  Widget _card(GiftCode code) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: catalogGold.withValues(alpha: 0.35)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [catalogGold.withValues(alpha: 0.1), const Color(0xFF161618)]),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(width: 56, height: 56, child: CatalogImage(url: code.image)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (code.brand.isNotEmpty)
                      Text(
                        code.brand,
                        style: const TextStyle(color: catalogGold, fontFamily: gilroySemiBold, fontSize: 12.5),
                      ),
                    Text(
                      code.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16, height: 1.2),
                    ),
                    Text(
                      _date(code.boughtAt),
                      style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${catalogMoney(code.price)} TMT',
                style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code.code,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17, letterSpacing: 1),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: code.code));
                    showSnackBar('catalogCopy', 'catalogCopied', const Color(0xFF34D399));
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFFFFD866), catalogGoldDark]),
                    ),
                    child: Text(
                      'catalogCopy'.tr,
                      style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
