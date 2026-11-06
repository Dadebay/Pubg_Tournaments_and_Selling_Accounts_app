import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);

/// A page that lists what the user bought: a header with a back button, a
/// shimmering skeleton while loading, pull to refresh, and a retry / empty state.
class BoughtListPage<T> extends StatefulWidget {
  const BoughtListPage({required this.title, required this.load, required this.itemBuilder, super.key});

  /// Translation key of the title.
  final String title;
  final Future<List<T>> Function() load;
  final Widget Function(T item) itemBuilder;

  @override
  State<BoughtListPage<T>> createState() => _BoughtListPageState<T>();
}

class _BoughtListPageState<T> extends State<BoughtListPage<T>> {
  late Future<List<T>> _future = widget.load();

  Future<void> _reload() async {
    final future = widget.load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder shows the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: widget.title.tr, onBack: Get.back),
            Expanded(
              child: FutureBuilder<List<T>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _skeleton();
                  }
                  if (snapshot.hasError) {
                    return Center(child: errorData(onTap: _reload));
                  }
                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return Center(
                      child: CatalogEmptyState(icon: IconlyLight.document, imageAsset: 'assets/image/empty_orders_clipboard.webp', title: 'noOrder'.tr, description: 'ordersEmptyDescription'.tr),
                    );
                  }
                  return RefreshIndicator(
                    color: _gold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _reload,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => widget.itemBuilder(items[index]),
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

  Widget _skeleton() {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          for (var i = 0; i < 5; i++) ...[const ShimmerBlock(height: 92, radius: 22), const SizedBox(height: 12)],
        ],
      ),
    );
  }
}

/// One bought item as a ticket: a colored stripe on the left, the icon, name and
/// price on top and, when it has one, the code on a torn-off strip with a copy button.
class BoughtCard extends StatelessWidget {
  const BoughtCard({required this.icon, required this.accent, required this.title, this.subtitle, this.price, this.count, this.code, super.key});

  final List<List<dynamic>> icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final String? price;
  final String? count;
  final String? code;

  bool get _hasCode => code != null && code!.isNotEmpty && code != 'null' && code != 'false';

  void _copy() {
    Clipboard.setData(ClipboardData(text: code!)).then((_) => showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty && subtitle != 'null';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [accent.withValues(alpha: 0.14), const Color(0xFF17171A)]),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accent),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: accent.withValues(alpha: 0.16),
                            border: Border.all(color: accent.withValues(alpha: 0.4)),
                          ),
                          child: Center(
                            child: HugeIcon(icon: icon, color: accent, size: 28, strokeWidth: 1.6),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18, height: 1.15),
                              ),
                              if (hasSubtitle) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyMedium, fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (price != null || count != null) ...[
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (price != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: _gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    '$price TMT',
                                    style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 15),
                                  ),
                                ),
                              if (count != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '×$count',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroySemiBold, fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_hasCode) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: List.generate(
                          22,
                          (_) => Expanded(
                            child: Container(height: 1.2, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white.withValues(alpha: 0.14)),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _copy,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                code!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20, letterSpacing: 1.6),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const HugeIcon(icon: HugeIcons.strokeRoundedCopy01, color: Color(0xFF111111), size: 18, strokeWidth: 1.8),
                                  const SizedBox(width: 6),
                                  Text(
                                    'copy'.tr,
                                    style: const TextStyle(color: Color(0xFF111111), fontFamily: gilroyBold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
