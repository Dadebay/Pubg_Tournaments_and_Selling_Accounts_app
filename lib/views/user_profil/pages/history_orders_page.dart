// ignore_for_file: file_names

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/collapsing_tabs_page.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:game_app/views/constants/uc_picture.dart';
import 'package:game_app/views/user_profil/auth/tab_bar_view.dart';
import 'package:hugeicons/hugeicons.dart';

/// The user's orders: tabs for all / pending / completed, and a header that
/// scrolls away so the tabs take the top of the screen.
class HistoryOrdersPage extends StatefulWidget {
  const HistoryOrdersPage({this.backArrow = true, super.key});

  final bool backArrow;

  @override
  State<HistoryOrdersPage> createState() => _HistoryOrdersPageState();
}

class _OrdersLoginRequired implements Exception {}

class _HistoryOrdersPageState extends State<HistoryOrdersPage> {
  static const _gold = Color(0xFFFFC83D);
  static const _green = Color(0xFF34D399);

  int _tab = 0;
  late Future<List<HistoryOrderModel>> _future = _loadOrders();

  Future<List<HistoryOrderModel>> _loadOrders() async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      throw _OrdersLoginRequired();
    }
    return HistoryOrderModel().getOrders();
  }

  Future<void> _refresh() async {
    setState(() {
      _details.clear();
      _future = _loadOrders();
    });
    try {
      await _future;
    } catch (_) {
      // The FutureBuilder displays the login or load-error state.
    }
  }

  Future<void> _openLogin() async {
    await Get.to(() => const TabBarViewPage());
    if (mounted) {
      setState(() {
        _future = _loadOrders();
      });
    }
  }

  bool _requiresLogin(Object? error) {
    if (error is _OrdersLoginRequired) {
      return true;
    }
    final message = '$error'.toLowerCase();
    return message.contains('401') ||
        message.contains('credentials') ||
        message.contains('authentication') ||
        message.contains('token is invalid');
  }

  static const _pendingStatuses = {
    'pending',
    'processing',
    'waiting',
    'new',
    'in_progress',
    'created',
  };
  static const _cancelledStatuses = {
    'canceled',
    'cancelled',
    'rejected',
    'failed',
    'declined',
  };

  bool _isPending(HistoryOrderModel order) =>
      _pendingStatuses.contains(order.status?.toLowerCase());
  bool _isCancelled(HistoryOrderModel order) =>
      _cancelledStatuses.contains(order.status?.toLowerCase());

  /// Which tab an order belongs to: 1 pending, 2 completed. Cancelled orders only show under "all".
  bool _inTab(HistoryOrderModel order, int tab) {
    switch (tab) {
      case 1:
        return _isPending(order);
      case 2:
        return !_isPending(order) && !_isCancelled(order);
      default:
        return true;
    }
  }

  /// `dd.MM.yyyy | HH:mm` from the API's ISO date, or the raw text if it does not parse.
  String _date(String? raw) {
    if (raw == null || raw.isEmpty) {
      return '';
    }
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) {
      return raw;
    }
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}  |  ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<HistoryOrderModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError && _requiresLogin(snapshot.error)) {
            return _loginRequiredState();
          }
          final all = snapshot.data ?? const <HistoryOrderModel>[];
          return CollapsingTabsPage(
            title: 'orders',
            titleSize: 22,
            centerTitle: true,
            onBack: widget.backArrow ? Get.back : null,
            onRefresh: _refresh,
            tabs: [
              SegmentTab(
                label: 'allOrders'.tr,
                icon: HugeIcons.strokeRoundedTask01,
              ),
              SegmentTab(
                label: 'pendingOrders'.tr,
                icon: HugeIcons.strokeRoundedClock01,
              ),
              SegmentTab(
                label: 'doneOrders'.tr,
                icon: HugeIcons.strokeRoundedCheckmarkSquare02,
              ),
            ],
            selectedIndex: _tab,
            onTabChanged: (i) => setState(() => _tab = i),
            bottomPadding: 90,
            body: _content(snapshot, all),
          );
        },
      ),
    );
  }

  Widget _loginRequiredState() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                if (widget.backArrow)
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  'orders'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroyBold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: CatalogEmptyState(
                  icon: IconlyLight.profile,
                  imageAsset: 'assets/image/empty_login_badge.webp',
                  title: 'ordersLoginTitle'.tr,
                  description: 'ordersLoginDescription'.tr,
                  actionLabel: 'signIn'.tr,
                  actionIcon: IconlyLight.login,
                  onAction: _openLogin,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(
    AsyncSnapshot<List<HistoryOrderModel>> snapshot,
    List<HistoryOrderModel> all,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: spinKit());
    }
    if (snapshot.hasError) {
      return Center(child: errorData(onTap: _refresh));
    }
    // Orders are numbered by their place in the whole list, whichever tab shows them.
    final shown = [
      for (var i = 0; i < all.length; i++)
        if (_inTab(all[i], _tab)) (number: all.length - i, order: all[i]),
    ];
    if (shown.isEmpty) {
      final titleKey = switch (_tab) {
        1 => 'pendingOrdersEmptyTitle',
        2 => 'doneOrdersEmptyTitle',
        _ => 'noOrder',
      };
      final descriptionKey = switch (_tab) {
        1 => 'pendingOrdersEmptyDescription',
        2 => 'doneOrdersEmptyDescription',
        _ => 'ordersEmptyDescription',
      };
      // The tab page gives its body the free viewport height, so this centers.
      return Center(
        child: CatalogEmptyState(
          icon: IconlyLight.document,
          imageAsset: 'assets/image/empty_orders_clipboard.webp',
          title: titleKey.tr,
          description: descriptionKey.tr,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          for (final item in shown)
            _orderCard(item.order, item.number, all.length),
          const SizedBox(height: 4),
          _thanksBanner(),
        ],
      ),
    );
  }

  /// The items of orders whose list entry carries none, loaded once per order
  /// from `/carts/get-cart/{id}/`.
  final Map<int, Future<List<CartItems>>> _details = {};

  Future<List<CartItems>> _itemsOf(HistoryOrderModel order) {
    return _details.putIfAbsent(order.id!, () async {
      try {
        return (await HistoryIDModel().getOrderByID(order.id!)).cartItems ??
            const [];
      } catch (_) {
        return const <CartItems>[];
      }
    });
  }

  Widget _orderCard(HistoryOrderModel order, int number, int total) {
    // The list answer may not carry the items; then they come from the order detail.
    if (order.items.isEmpty && order.id != null) {
      return FutureBuilder<List<CartItems>>(
        future: _itemsOf(order),
        builder: (context, snapshot) =>
            _orderTile(order, snapshot.data ?? const []),
      );
    }
    return _orderTile(order, order.items);
  }

  /// A compact order card: the bought UC, its amount and date on the left, the
  /// price and the status on the right.
  Widget _orderTile(HistoryOrderModel order, List<CartItems> items) {
    final pending = _isPending(order);
    final cancelled = _isCancelled(order);
    final badge = cancelled
        ? const Color(0xFFFF5A5F)
        : (pending ? const Color(0xFF60A5FA) : _green);
    final badgeText = cancelled
        ? 'statusCancelled'
        : (pending ? 'statusPending' : 'statusDone');
    final first = items.isEmpty ? null : items.first;
    final title = (first?.ucName?.isNotEmpty ?? false)
        ? first!.ucName!
        : '${'orderPage'.tr} №${order.id}';
    final extra = items.length > 1 ? items.length - 1 : 0;
    final count = first?.count ?? 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF232327), Color(0xFF151517)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: order.id == null
                ? null
                : () => Get.to(
                    () => OrderByID(
                      orderID: order.id!,
                      pageName: '${'orderPage'.tr} №${order.id}',
                      ask: order.ask ?? false,
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _productTile(first, extra),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.id != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '№ ${order.id}',
                              style: const TextStyle(
                                color: _gold,
                                fontFamily: gilroyBold,
                                fontSize: 11.5,
                                height: 1.1,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          children: [
                            Flexible(
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
                            if (count > 1) ...[
                              const SizedBox(width: 8),
                              Text(
                                '×$count',
                                style: const TextStyle(
                                  color: _gold,
                                  fontFamily: gilroyBold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _date(order.created_date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontFamily: gilroyMedium,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order.price} TMT',
                        style: const TextStyle(
                          color: _gold,
                          fontFamily: gilroyBold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badge,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badgeText.tr,
                            style: TextStyle(
                              color: badge,
                              fontFamily: gilroySemiBold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The picture of the bought UC: the local pack image of its amount, else the
  /// one the API sends, else a gold "UC" mark. `extra` more items show as a badge.
  Widget _productTile(CartItems? item, int extra) {
    final Widget picture = UcPicture(name: item?.ucName, image: item?.ucImage);
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(
                  colors: [
                    _gold.withValues(alpha: 0.26),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
                border: Border.all(color: _gold.withValues(alpha: 0.25)),
              ),
              child: picture,
            ),
          ),
          if (extra > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: Color(0xFF1A1200),
                    fontFamily: gilroyBold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thanksBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [_gold.withValues(alpha: 0.16), Colors.black],
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.14),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFire,
                color: _gold,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ordersThanks'.tr,
                  style: const TextStyle(
                    color: _gold,
                    fontFamily: gilroyBold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ordersThanksSub'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: gilroyMedium,
                    fontSize: 13,
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

/// Where an order is in its life: waiting, done or cancelled.
enum _OrderState { pending, done, cancelled }

_OrderState _orderStateOf(String? status) {
  final value = status?.toLowerCase();
  if (const {
    'canceled',
    'cancelled',
    'rejected',
    'failed',
    'declined',
  }.contains(value)) {
    return _OrderState.cancelled;
  }
  if (const {
    'pending',
    'processing',
    'waiting',
    'new',
    'in_progress',
    'created',
  }.contains(value)) {
    return _OrderState.pending;
  }
  return _OrderState.done;
}

/// One order: its status and total on top, the bought UC with their codes, and
/// the PUBG id, date and note the order was made with.
class OrderByID extends StatefulWidget {
  final int orderID;
  final String pageName;
  final bool ask;
  const OrderByID({
    required this.orderID,
    required this.pageName,
    required this.ask,
    super.key,
  });

  @override
  State<OrderByID> createState() => _OrderByIDState();
}

class _OrderByIDState extends State<OrderByID> {
  static const _gold = Color(0xFFFFC83D);
  static const _green = Color(0xFF34D399);
  static const _blue = Color(0xFF60A5FA);
  static const _red = Color(0xFFFF5A5F);

  late Future<HistoryIDModel> _future = HistoryIDModel().getOrderByID(
    widget.orderID,
  );

  Future<void> _reload() async {
    final future = HistoryIDModel().getOrderByID(widget.orderID);
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder shows the error state.
    }
  }

  /// `dd.MM.yyyy | HH:mm` from the API's ISO date.
  String _date(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (date == null) {
      return raw ?? '';
    }
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}  |  ${two(date.hour)}:${two(date.minute)}';
  }

  String _money(num value) =>
      '${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(2)} TMT';

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then(
      (_) => showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: FutureBuilder<HistoryIDModel>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _skeleton();
                  }
                  final order = snapshot.data;
                  if (snapshot.hasError || order == null) {
                    return Center(child: errorData(onTap: _reload));
                  }
                  return RefreshIndicator(
                    color: _gold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        _statusCard(order),
                        const SizedBox(height: 22),
                        for (final item
                            in order.cartItems ?? const <CartItems>[])
                          _itemCard(item),
                        const SizedBox(height: 10),
                        _infoCard(order),
                      ],
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

  Widget _header() {
    return CenteredHeader(title: widget.pageName, onBack: Get.back);
  }

  Widget _skeleton() {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: const [
          ShimmerBlock(height: 150, radius: 26),
          SizedBox(height: 22),
          ShimmerBlock(height: 112, radius: 24),
          SizedBox(height: 12),
          ShimmerBlock(height: 112, radius: 24),
          SizedBox(height: 22),
          ShimmerBlock(height: 140, radius: 24),
        ],
      ),
    );
  }

  /// The big card on top: the status, the date and the total.
  Widget _statusCard(HistoryIDModel order) {
    final state = _orderStateOf(order.status);
    final color = switch (state) {
      _OrderState.cancelled => _red,
      _OrderState.pending => _blue,
      _OrderState.done => _green,
    };
    final icon = switch (state) {
      _OrderState.cancelled => HugeIcons.strokeRoundedCancelCircle,
      _OrderState.pending => HugeIcons.strokeRoundedHourglass,
      _OrderState.done => HugeIcons.strokeRoundedCheckmarkCircle02,
    };
    final label = switch (state) {
      _OrderState.cancelled => 'statusCancelled',
      _OrderState.pending => 'statusPending',
      _OrderState.done => 'statusDone',
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.22), const Color(0xFF141416)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 28,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.tr,
                      style: TextStyle(
                        color: color,
                        fontFamily: gilroyBold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _date(order.created_date),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontFamily: gilroyMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orderPage3'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: gilroySemiBold,
                  fontSize: 16,
                ),
              ),
              Text(
                _money(double.tryParse(order.price ?? '') ?? 0),
                style: const TextStyle(
                  color: _gold,
                  fontFamily: gilroyBold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A bought UC: its picture, name, amount and price, with its codes below.
  Widget _itemCard(CartItems item) {
    final count = item.count ?? 1;
    final unit = double.tryParse(item.unitPrice ?? '');
    final codes = (item.code ?? const <Codes>[])
        .map((c) => c.code)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232327), Color(0xFF141416)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    colors: [
                      _gold.withValues(alpha: 0.26),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                  border: Border.all(color: _gold.withValues(alpha: 0.25)),
                ),
                child: UcPicture(name: item.ucName, image: item.ucImage),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ucName ?? 'UC',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: gilroyBold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit == null ? '×$count' : '×$count  ·  ${_money(unit)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontFamily: gilroyMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (unit != null)
                Text(
                  _money(unit * count),
                  style: const TextStyle(
                    color: _gold,
                    fontFamily: gilroyBold,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
          if (!widget.ask && codes.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final code in codes) _codeRow(code),
          ],
        ],
      ),
    );
  }

  /// A code of the item; a tap copies it.
  Widget _codeRow(String code) {
    return GestureDetector(
      onTap: () => _copy(code),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _gold,
                  fontFamily: gilroyBold,
                  fontSize: 17,
                  letterSpacing: 1,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCopy01,
                    color: Colors.white70,
                    size: 18,
                    strokeWidth: 1.6,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'copy'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: gilroyMedium,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PUBG id (copyable), order number and the note, when there is one.
  Widget _infoCard(HistoryIDModel order) {
    final note = order.note?.trim() ?? '';
    final pubgId = order.pubgID ?? '';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF17130C),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          _infoRow(
            HugeIcons.strokeRoundedGameController03,
            'signIn2'.tr,
            pubgId,
            onCopy: pubgId.isEmpty ? null : () => _copy(pubgId),
          ),
          _divider(),
          _infoRow(
            HugeIcons.strokeRoundedTask01,
            'orderPage'.tr,
            '№${order.id}',
          ),
          if (note.isNotEmpty) ...[
            _divider(),
            _infoRow(HugeIcons.strokeRoundedNote01, 'note'.tr, note),
          ],
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.07));

  Widget _infoRow(
    List<List<dynamic>> icon,
    String label,
    String value, {
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: _gold, size: 22, strokeWidth: 1.6),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC9BFA8),
              fontFamily: gilroyMedium,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: gilroyBold,
                fontSize: 17,
              ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCopy01,
                  color: Colors.white54,
                  size: 20,
                  strokeWidth: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
