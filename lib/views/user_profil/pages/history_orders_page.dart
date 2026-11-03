// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/collapsing_tabs_page.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';

/// The user's orders: tabs for all / pending / completed, and a header that
/// scrolls away so the tabs take the top of the screen.
class HistoryOrdersPage extends StatefulWidget {
  const HistoryOrdersPage({this.backArrow = true, super.key});

  final bool backArrow;

  @override
  State<HistoryOrdersPage> createState() => _HistoryOrdersPageState();
}

class _HistoryOrdersPageState extends State<HistoryOrdersPage> {
  static const _gold = Color(0xFFFFC83D);
  static const _green = Color(0xFF34D399);

  int _tab = 0;
  late Future<List<HistoryOrderModel>> _future = HistoryOrderModel()
      .getOrders();

  Future<void> _refresh() async {
    setState(() => _future = HistoryOrderModel().getOrders());
    await _future;
  }

  bool _isPending(HistoryOrderModel order) => order.status == 'pending';

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
          final all = snapshot.data ?? const <HistoryOrderModel>[];
          return CollapsingTabsPage(
            title: 'orders',
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
            bottomPadding: 100,
            body: _content(snapshot, all),
          );
        },
      ),
    );
  }

  Widget _content(
    AsyncSnapshot<List<HistoryOrderModel>> snapshot,
    List<HistoryOrderModel> all,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SizedBox(height: 320, child: Center(child: spinKit()));
    }
    if (snapshot.hasError) {
      return SizedBox(height: 420, child: errorData(onTap: _refresh));
    }
    // Orders are numbered by their place in the whole list, whichever tab shows them.
    final shown = [
      for (var i = 0; i < all.length; i++)
        if (_tab == 0 || (_tab == 1) == _isPending(all[i]))
          (number: all.length - i, order: all[i]),
    ];
    if (shown.isEmpty) {
      return SizedBox(height: 420, child: noData('noOrder'));
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

  Widget _orderCard(HistoryOrderModel order, int number, int total) {
    final pending = _isPending(order);
    final badge = pending ? const Color(0xFF60A5FA) : _green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF232327), Color(0xFF151517)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.to(
              () => OrderByID(
                orderID: order.id!,
                pageName: '${'orderPage'.tr} $number',
                ask: order.ask ?? false,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                      border: Border.all(color: _gold.withValues(alpha: 0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.18),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'UC',
                        style: TextStyle(
                          color: _gold,
                          fontFamily: gilroyBold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'orderPage'.tr} №$number',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: gilroyBold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _meta(HugeIcons.strokeRoundedUser, order.pubgID ?? ''),
                        const SizedBox(height: 4),
                        _meta(
                          HugeIcons.strokeRoundedCalendar03,
                          _date(order.created_date),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: badge.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: pending
                                  ? HugeIcons.strokeRoundedHourglass
                                  : HugeIcons.strokeRoundedCheckmarkCircle02,
                              color: badge,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              (pending ? 'statusPending' : 'statusDone').tr,
                              style: TextStyle(
                                color: badge,
                                fontFamily: gilroySemiBold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${order.price} TMT',
                        style: const TextStyle(
                          color: _gold,
                          fontFamily: gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(List<List<dynamic>> icon, String text) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: Colors.white.withValues(alpha: 0.5),
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontFamily: gilroyMedium,
              fontSize: 13,
            ),
          ),
        ),
      ],
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

class OrderByID extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBar(
        backArrow: true,
        fontSize: 0.0,
        elevationWhite: true,
        iconRemove: true,
        name: pageName,
      ),
      body: FutureBuilder<HistoryIDModel>(
        future: HistoryIDModel().getOrderByID(orderID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(
              onTap: () {
                HistoryIDModel().getOrderByID(orderID);
              },
            );
          } else if (snapshot.data == null) {
            return emptyData();
          } else if (snapshot.data.toString() == '[]') {
            return noData('noOrder');
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.cartItems!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      title: Row(
                        children: [
                          ClipRRect(
                            borderRadius: borderRadius15,
                            child: CachedNetworkImage(
                              fadeInCurve: Curves.ease,
                              imageUrl:
                                  '$serverURL${snapshot.data!.cartItems![index].ucImage}',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: borderRadius20,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) =>
                                  Center(child: spinKit()),
                              errorWidget: (context, url, error) =>
                                  const Text('No Image'),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      snapshot.data!.cartItems![index].ucName
                                          .toString(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: gilroySemiBold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'orderPage1'.tr +
                                        snapshot.data!.cartItems![index].count
                                            .toString(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: gilroyMedium,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      collapsedIconColor: kPrimaryColor,
                      collapsedTextColor: kPrimaryColor,
                      childrenPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${'tournamentInfo7'.tr} ',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: gilroyMedium,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      snapshot.data!.created_date!.substring(
                                        0,
                                        10,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontFamily: gilroyMedium,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${'signIn2'.tr} :',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: gilroyMedium,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      snapshot.data!.pubgID!,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontFamily: gilroyMedium,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ask
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${'tournamentInfo15'.tr} :  ',
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot
                                                .data!
                                                .cartItems![index]
                                                .code!
                                                .length,
                                            itemBuilder: (BuildContext context, int indexx) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      snapshot
                                                              .data!
                                                              .cartItems![index]
                                                              .code![indexx]
                                                              .code ??
                                                          'tournamentInfo10'.tr,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        color: kPrimaryColor,
                                                        fontFamily:
                                                            gilroyMedium,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                        ClipboardData(
                                                          text: snapshot
                                                              .data!
                                                              .cartItems![index]
                                                              .code![indexx]
                                                              .code
                                                              .toString(),
                                                        ),
                                                      ).then((value) {
                                                        showSnackBar(
                                                          'copySucces',
                                                          'copySuccesSubtitle',
                                                          Colors.green,
                                                        );
                                                      });
                                                    },
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              kPrimaryColorBlack,
                                                          elevation: 0.0,
                                                          side: const BorderSide(
                                                            color:
                                                                kPrimaryColor,
                                                          ),
                                                        ),
                                                    icon: const Icon(
                                                      Icons.copy_all,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      'copy'.tr,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            gilroyMedium,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ask
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${'signIn2'.tr} :  ',
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            snapshot.data!.pubgID ??
                                                'tournamentInfo10'.tr,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: kPrimaryColor,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            snapshot.data!.note != null
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${'note'.tr} :  ',
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            snapshot.data!.note ??
                                                'tournamentInfo10'.tr,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: kPrimaryColor,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ask
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${'note'.tr} :  ',
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            snapshot.data!.note ??
                                                'tournamentInfo10'.tr,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: kPrimaryColor,
                                              fontFamily: gilroyMedium,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
