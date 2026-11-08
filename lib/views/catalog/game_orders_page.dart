import 'package:game_app/models/catalog_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';

import '../constants/index.dart';

/// The player's orders of games and programs: their status, what they answered and
/// the admin's note. The status changes when the admin handles the order (a push says so).
class GameOrdersPage extends StatefulWidget {
  const GameOrdersPage({super.key});

  @override
  State<GameOrdersPage> createState() => _GameOrdersPageState();
}

class _GameOrdersPageState extends State<GameOrdersPage> {
  late Future<List<GameOrder>> _future = _load();

  Future<List<GameOrder>> _load() async {
    final result = await UcdayyApi.getMyGameOrders();
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    final data = result.data;
    final items = data is List ? data : apiItems(data);
    return [for (final item in items.whereType<Map>()) GameOrder.fromJson(item)];
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    try {
      await _future;
    } catch (_) {}
  }

  ({Color color, String label}) _status(String status) => switch (status) {
    'success' => (color: const Color(0xFF34D399), label: 'orderSuccess'.tr),
    'failed' => (color: const Color(0xFFFF6B6B), label: 'orderFailed'.tr),
    _ => (color: catalogGold, label: 'orderPending'.tr),
  };

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
            CenteredHeader(title: 'orders'.tr, onBack: Get.back),
            Expanded(
              child: FutureBuilder<List<GameOrder>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: catalogGold));
                  }
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
                  final orders = snapshot.data ?? const <GameOrder>[];
                  if (orders.isEmpty) {
                    return Center(
                      child: CatalogEmptyState(icon: Icons.receipt_long_outlined, title: 'catalogNoOrders'.tr, description: ''),
                    );
                  }
                  return RefreshIndicator(
                    color: catalogGold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => _card(orders[index]),
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

  Widget _card(GameOrder order) {
    final status = _status(order.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [status.color.withValues(alpha: 0.1), const Color(0xFF161618)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: status.color.withValues(alpha: 0.16)),
                child: Text(
                  status.label,
                  style: TextStyle(color: status.color, fontFamily: gilroySemiBold, fontSize: 12.5),
                ),
              ),
              const Spacer(),
              Text(
                _date(order.createdAt),
                style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in order.items) _item(item),
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white.withValues(alpha: 0.06)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'catalogAdminNote'.tr,
                    style: const TextStyle(color: catalogGold, fontFamily: gilroySemiBold, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.note,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 14, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
          if (order.refunded) ...[
            const SizedBox(height: 8),
            Text(
              'orderRefunded'.tr,
              style: const TextStyle(color: Color(0xFF34D399), fontFamily: gilroySemiBold, fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'catalogTotal'.tr,
                style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${catalogMoney(order.total)} TMT',
                style: const TextStyle(color: catalogGold, fontFamily: gilroyBold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(GameOrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 48, height: 48, child: CatalogImage(url: item.image)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name}  ×${item.count}',
                  style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 15),
                ),
                if (item.answer.isNotEmpty)
                  Text(
                    item.asking.isEmpty ? item.answer : '${item.asking}: ${item.answer}',
                    style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 13, height: 1.25),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${catalogMoney(item.price)} TMT',
            style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
