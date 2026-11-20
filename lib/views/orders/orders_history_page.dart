import 'dart:async';

import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:game_app/views/user_profil/auth/tab_bar_view.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// "My orders": everything the player bought in one list (`GET /orders/history/`), with
/// filter chips by type, endless paging and a detail sheet with the items, the codes
/// (copyable) and the details of each type.
class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({this.backArrow = true, super.key});

  final bool backArrow;

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _HistoryEntry {
  _HistoryEntry(this.json);

  final Map json;

  String get type => '${json['type'] ?? ''}';
  int get id => int.tryParse('${json['id']}') ?? 0;
  double get total => double.tryParse('${json['total']}') ?? 0;
  String get status => '${json['status'] ?? ''}'.toLowerCase();
  bool get byCard => '${json['paid_by']}' == 'card';
  String get image => catalogImageUrl(json['image']);
  DateTime? get date => DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal();
  List<Map> get items => json['items'] is List
      ? [
          for (final item in json['items'] as List)
            if (item is Map) item,
        ]
      : const [];
  List<String> get codes => json['codes'] is List ? [for (final code in json['codes'] as List) '$code'] : const [];
  Map get extra => json['extra'] is Map ? json['extra'] as Map : const {};

  String get title {
    final ru = Get.locale?.languageCode == 'ru';
    return '${json[ru ? 'title_ru' : 'title_tm'] ?? json['title_tm'] ?? json['title_ru'] ?? ''}';
  }
}

String catalogImageUrl(dynamic value) {
  final path = '${value ?? ''}'.trim();
  if (path.isEmpty || path == 'null') {
    return '';
  }
  return path.startsWith('http') ? path : '$serverURL${path.startsWith('/') ? '' : '/'}$path';
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  /// Where the order was bought: (type sent as `?type=`, label key). The first one is "all".
  static const _sources = [
    (null, 'allOrders'),
    ('uc', 'ordersTypeUc'),
    ('game', 'homeGames'),
    ('program', 'homePrograms'),
    ('gift', 'homeGifts'),
    ('account_post', 'accountsForSale'),
    ('account_buy', 'ordersTypeAccountBuy'),
  ];

  /// What "all" asks the server for (`?type=a,b,...`).
  static const _purchaseTypes = 'uc,game,program,gift,account_post,account_buy';

  final ScrollController _scroll = ScrollController();
  late final List<GlobalKey> _sourceKeys = List.generate(_sources.length, (_) => GlobalKey());

  /// The chosen source (sent to the server as `type`); null is everything.
  String? _type;

  final List<_HistoryEntry> _entries = [];
  int _page = 0;
  int _count = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _failed = false;
  bool _loginRequired = false;

  bool get _hasMore => _entries.length < _count;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
    _reload();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _loginRequired = true;
          _loading = false;
        });
      }
      return;
    }
    setState(() {
      _loginRequired = false;
      _loading = true;
      _failed = false;
      _entries.clear();
      _page = 0;
      _count = 0;
    });
    await _fetch(1);
  }

  Future<void> _fetch(int page) async {
    final type = _type;
    // "All" is the purchases only: tournaments, contests, spins and premium have their own buttons.
    final result = await UcdayyApi.getOrderHistory(page: page, type: type ?? _purchaseTypes);
    // The source changed while this was loading: the answer is for the old one.
    if (!mounted || type != _type) {
      return;
    }
    final data = result.data;
    if (!result.ok || data is! Map) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (page == 1) {
          _failed = true;
        }
      });
      return;
    }
    final results = data['results'];
    setState(() {
      _page = page;
      _count = int.tryParse('${data['count']}') ?? 0;
      if (results is List) {
        _entries.addAll([
          for (final item in results)
            if (item is Map) _HistoryEntry(item),
        ]);
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _failed) {
      return;
    }
    setState(() => _loadingMore = true);
    await _fetch(_page + 1);
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'orders'.tr, onBack: widget.backArrow ? Get.back : null),
            if (!_loginRequired) ...[_sourceBar()],
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  void _selectSource(int index) {
    final type = _sources[index].$1;
    if (type == _type) {
      return;
    }
    _type = type;
    final target = _sourceKeys[index].currentContext;
    if (target != null) {
      unawaited(Scrollable.ensureVisible(target, alignment: 0.5, duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
    }
    _reload();
  }

  /// Where the orders come from: UC, games, programs, gift cards, contests, premium, ...
  /// A second bar under the status tabs, sent to the server as `?type=`.
  /// The source buttons in two rows that scroll sideways together. The buttons are shared out so both
  /// rows are about equally long, every button keeps its full size and its icon.
  Widget _sourceBar() {
    const gap = 8.0;
    const extra = 8.0 + 8.0 + 17.0 + 6.0 + 2.0; // padding + icon + space + border
    final widths = [
      for (final source in _sources)
        (TextPainter(
              text: TextSpan(
                text: source.$2.tr,
                style: const TextStyle(fontFamily: gilroyBold, fontSize: 14.5),
              ),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout()).width +
            extra,
    ];
    // Longest first onto the shorter row, then each row back in its original order.
    final order = List.generate(_sources.length, (i) => i)..sort((x, y) => widths[y].compareTo(widths[x]));
    final rows = <List<int>>[[], []];
    final totals = [0.0, 0.0];
    for (final i in order) {
      final row = totals[0] <= totals[1] ? 0 : 1;
      rows[row].add(i);
      totals[row] += widths[i];
    }
    for (final row in rows) {
      row.sort();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: gap),
            Row(
              children: [
                for (var k = 0; k < rows[r].length; k++) ...[if (k > 0) const SizedBox(width: gap), _sourceChip(rows[r][k])],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _sourceChip(int index) {
    final source = _sources[index];
    final selected = source.$1 == _type;
    return GestureDetector(
      key: _sourceKeys[index],
      onTap: () => _selectSource(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(colors: selected ? const [Color(0xFFFFD96B), Color(0xFFFFC83D)] : const [Color(0xFF1C1C20), Color(0xFF1C1C20)]),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.09)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: source.$1 == null ? HugeIcons.strokeRoundedGridView : _icon(source.$1!), color: selected ? const Color(0xFF1A1200) : catalogGold, size: 17, strokeWidth: 1.9),
            const SizedBox(width: 6),
            Text(
              source.$2.tr,
              maxLines: 1,
              style: TextStyle(color: selected ? const Color(0xFF1A1200) : Colors.white70, fontFamily: gilroyBold, fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loginRequired) {
      return Center(
        child: SingleChildScrollView(
          child: CatalogEmptyState(
            icon: IconlyLight.profile,
            imageAsset: 'assets/image/empty_login_badge.webp',
            title: 'ordersLoginTitle'.tr,
            description: 'ordersLoginDescription'.tr,
            actionLabel: 'signIn'.tr,
            actionIcon: IconlyLight.login,
            onAction: () async {
              await Get.to(() => const TabBarViewPage());
              if (mounted) {
                _reload();
              }
            },
          ),
        ),
      );
    }
    if (_loading) {
      return _skeleton();
    }
    if (_failed) {
      return Center(
        child: CatalogEmptyState(icon: Icons.cloud_off_outlined, title: 'catalogLoadFailed'.tr, description: '', actionLabel: 'noConnection3'.tr, actionIcon: Icons.refresh_rounded, onAction: _reload),
      );
    }
    final shown = _entries;
    if (shown.isEmpty) {
      const titleKey = 'noOrder';
      const descriptionKey = 'ordersEmptyDescription';
      return RefreshIndicator(
        color: catalogGold,
        backgroundColor: const Color(0xFF1C1C20),
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            const SizedBox(height: 80),
            CatalogEmptyState(icon: IconlyLight.document, imageAsset: 'assets/image/empty_orders_clipboard.webp', title: titleKey.tr, description: descriptionKey.tr),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: catalogGold,
      backgroundColor: const Color(0xFF1C1C20),
      onRefresh: _reload,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        // Room for the navigation bar that covers the bottom of the page.
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
        itemCount: shown.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= shown.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: catalogGold, strokeWidth: 3)),
            );
          }
          return _card(shown[index]);
        },
      ),
    );
  }

  /// Shimmering placeholders shaped like the order cards, shown while the list loads (also when the
  /// player comes to the page through the bottom bar).
  Widget _skeleton() {
    Widget card() => Container(
      height: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1B1B1F), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          ShimmerBlock(width: 68, height: 68, radius: 16),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ShimmerBlock(width: 150, height: 16, radius: 8), SizedBox(height: 10), ShimmerBlock(width: 100, height: 12, radius: 6)],
            ),
          ),
          ShimmerBlock(width: 56, height: 22, radius: 8),
        ],
      ),
    );
    return Shimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => card(),
      ),
    );
  }

  // --------------------------------------------------------------- helpers

  List<List<dynamic>> _icon(String type) => switch (type) {
    'uc' => HugeIcons.strokeRoundedCoins01,
    'game' => HugeIcons.strokeRoundedGameController03,
    'program' => HugeIcons.strokeRoundedDashboardSquare01,
    'gift' => HugeIcons.strokeRoundedGift,
    'konkurs' => HugeIcons.strokeRoundedAward01,
    'premium' => HugeIcons.strokeRoundedCrown,
    'spins' => HugeIcons.strokeRoundedRotate01,
    'turnir' => HugeIcons.strokeRoundedChampion,
    'account_post' => HugeIcons.strokeRoundedUserStar01,
    'account_buy' => HugeIcons.strokeRoundedUserCheck01,
    _ => HugeIcons.strokeRoundedShoppingBag01,
  };

  ({Color color, String label}) _status(String status) => switch (status) {
    'success' || 'completed' || 'done' => (color: const Color(0xFF34D399), label: 'orderSuccess'.tr),
    'pending' || 'waiting' => (color: catalogGold, label: 'orderPending'.tr),
    'active' => (color: const Color(0xFF60A5FA), label: 'orderActive'.tr),
    'finished' => (color: const Color(0xFF9A9AA3), label: 'tournamentInfo9'.tr),
    'refunded' => (color: const Color(0xFF34D399), label: 'orderRefundedStatus'.tr),
    'failed' || 'cancelled' || 'canceled' => (color: const Color(0xFFFF6B6B), label: 'orderFailed'.tr),
    '' => (color: const Color(0xFF9A9AA3), label: ''),
    // An unknown status is shown as it comes.
    _ => (color: const Color(0xFF9A9AA3), label: status),
  };

  String _date(DateTime? value) {
    if (value == null) {
      return '';
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}.${two(value.month)}.${value.year}  ${two(value.hour)}:${two(value.minute)}';
  }

  Widget _thumb(_HistoryEntry entry, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Container(
        width: size,
        height: size,
        color: catalogGold.withValues(alpha: 0.1),
        child: entry.image.isEmpty
            ? Center(
                child: HugeIcon(icon: _icon(entry.type), color: catalogGold, size: size * 0.5, strokeWidth: 1.8),
              )
            : CatalogImage(url: entry.image),
      ),
    );
  }

  // ------------------------------------------------------------------ card

  Widget _card(_HistoryEntry entry) {
    final status = _status(entry.status);
    return GestureDetector(
      onTap: () => _openDetail(entry),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
        ),
        child: Row(
          children: [
            _thumb(entry, 58),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 15.5, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _date(entry.date),
                    style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: [if (status.label.isNotEmpty) _chip(status.label, status.color), if (entry.byCard) _chip('ordersCard'.tr, const Color(0xFF9A9AA3))]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  catalogMoney(entry.total),
                  style: const TextStyle(color: catalogGold, fontFamily: gilroyBold, fontSize: 20, height: 1),
                ),
                const Text(
                  'TMT',
                  style: TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withValues(alpha: 0.16)),
      child: Text(
        text,
        style: TextStyle(color: color, fontFamily: gilroySemiBold, fontSize: 11.5, height: 1.15),
      ),
    );
  }

  // ---------------------------------------------------------------- detail

  /// (label, value) lines for the details of each type.
  List<(String, String)> _details(_HistoryEntry entry) {
    final extra = entry.extra;
    final lines = <(String, String)>[];
    void add(String label, dynamic value) {
      final text = '${value ?? ''}'.trim();
      if (text.isNotEmpty && text != 'null' && text != 'false') {
        lines.add((label, text == 'true' ? '✓' : text));
      }
    }

    switch (entry.type) {
      case 'uc':
        add('Pubg ID', extra['pubg_id']);
        add('catalogAdminNote'.tr, extra['note']);
      case 'game' || 'program':
        add('catalogAdminNote'.tr, extra['note']);
        if (extra['refunded'] == true) {
          add('orderRefunded'.tr, '✓');
        }
      case 'premium':
        add('ordersDays'.tr, extra['days']);
        final until = DateTime.tryParse('${extra['until'] ?? ''}')?.toLocal();
        add('ordersUntil'.tr, until == null ? null : _date(until));
        if (extra['given_by_admin'] == true) {
          add('ordersByAdmin'.tr, '✓');
        }
      case 'turnir':
        final start = DateTime.tryParse('${extra['start_date'] ?? ''}')?.toLocal();
        add('tournamentInfo7'.tr.replaceAll(':', '').trim(), start == null ? null : _date(start));
        add('Team', extra['team']);
      case 'account_buy':
        // What the buyer sent to the admin, and the bought account itself.
        add('Gmail', extra['gmail']);
        add('Pubg ID', extra['pubg_id']);
        add('accountBuyBoughtAccount'.tr, extra['account_pubg_username']);
        if (entry.status == 'failed') {
          add('orderRefunded'.tr, '✓');
        }
      case 'account_post':
        add('accountDetaile5'.tr.replaceAll(':', '').trim(), extra['account_price'] == null ? null : '${extra['account_price']} TMT');
        if (extra['vip'] == true) {
          add('VIP', '✓');
        }
    }
    return lines;
  }

  /// The order in a dialog: its picture, title, date and status, the items with the total,
  /// the details of its type and the codes (each with a copy button).
  Future<void> _openDetail(_HistoryEntry entry) {
    final status = _status(entry.status);
    final details = _details(entry);
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.size.height * 0.86),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: catalogGold.withValues(alpha: 0.35)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF111113)]),
            boxShadow: [BoxShadow(color: catalogGold.withValues(alpha: 0.15), blurRadius: 36)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _thumb(entry, 84),
                      const SizedBox(height: 14),
                      Text(
                        entry.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _date(entry.date),
                        style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [if (status.label.isNotEmpty) _chip(status.label, status.color), if (entry.byCard) _chip('ordersCard'.tr, const Color(0xFF9A9AA3))],
                      ),
                      const SizedBox(height: 18),
                      _box([for (final item in entry.items) _itemRow(item), _line('catalogTotal'.tr, '${catalogMoney(entry.total)} TMT', highlight: true)]),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _box([for (final line in details) _line(line.$1, line.$2)]),
                      ],
                      if (entry.codes.isNotEmpty) ...[const SizedBox(height: 12), for (final code in entry.codes) _codeRow(code)],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: CatalogGoldButton(label: 'close'.tr, onTap: () => Navigator.pop(context), height: 52),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: children),
    );
  }

  Widget _line(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: highlight ? catalogGold : Colors.white, fontFamily: gilroyBold, fontSize: highlight ? 18 : 15, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(Map item) {
    final ru = Get.locale?.languageCode == 'ru';
    final name = '${item[ru ? 'name_ru' : 'name_tm'] ?? item['name_tm'] ?? item['name_ru'] ?? ''}';
    final count = int.tryParse('${item['count']}') ?? 1;
    final price = double.tryParse('${item['price']}') ?? 0;
    final answer = '${item['answer'] ?? ''}'.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name  ×$count',
                  style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 15),
                ),
                if (answer.isNotEmpty)
                  Text(
                    answer,
                    style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 13),
                  ),
              ],
            ),
          ),
          Text(
            '${catalogMoney(price)} TMT',
            style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _codeRow(String code) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.4),
        border: Border.all(color: catalogGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              code,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16, letterSpacing: 1),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: code));
              showSnackBar('catalogCopy', 'catalogCopied', const Color(0xFF34D399));
            },
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(colors: [Color(0xFFFFD866), catalogGoldDark]),
              ),
              child: Text(
                'catalogCopy'.tr,
                style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
