import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';

import '../../../models/user_models/auth_model.dart';

import 'package:hugeicons/hugeicons.dart';

import '../../repository/ucdayy_api.dart';
import '../cards/uc_package_card.dart';
import '../constants/collapsing_tabs_page.dart';
import '../constants/index.dart';
import 'order_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  TextEditingController pubgUserIDController = TextEditingController();
  final WalletController walletController = Get.put(WalletController());
  FocusNode pubgUserIDFocusNode = FocusNode();

  String title = 'selectUCType'.tr;
  final validator = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    walletController.getUserMoney();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      floatingActionButton: Obx(() {
        return AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: orderButton(),
          crossFadeState: walletController.cartList.isEmpty
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 500),
          alignment: Alignment.center,
          sizeCurve: Curves.easeInOut,
        );
      }),
      body: CollapsingTabsPage(
        title: 'Pubg UC',
        actions: userAppBarMoney(),
        tabs: [for (final tab in _tabs) SegmentTab(label: tab)],
        selectedIndex: _tab,
        onTabChanged: (i) => setState(() => _tab = i),
        // Room for the floating order button and the nav bar.
        bottomPadding: 90,
        body: _tabContent(),
      ),
    );
  }

  ElevatedButton orderButton() {
    return ElevatedButton(
      onPressed: () async {
        if (await _checkToken()) {
          await onTapFunction();
        }
      },
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: kPrimaryColor,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'order'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: gilroySemiBold,
              fontSize: 22,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2, left: 8),
            child: Icon(
              IconlyLight.arrowRightCircle,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkToken() async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      showSnackBar('loginError', 'loginError1', Colors.red);
      return false;
    }
    return true;
  }

  Future<void> onTapFunction() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColorBlack,
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadius20,
            side: BorderSide(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'enterID'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: gilroyBold,
                  fontSize: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Form(
                  key: validator,
                  child: CustomTextField(
                    labelName: 'Pubg id:',
                    controller: pubgUserIDController,
                    borderRadius: true,
                    focusNode: pubgUserIDFocusNode,
                    requestfocusNode: pubgUserIDFocusNode,
                    isNumber: false,
                  ),
                ),
              ),
              AgreeButton(
                name: 'agree',
                onTap: () async {
                  if (await _checkToken()) {
                    if (validator.currentState!.validate()) {
                      double value = 0.0;
                      double counts = 0.0;
                      for (var element in walletController.cartList) {
                        value +=
                            double.parse(element['price']) * element['count'];
                        counts += element['count'];
                      }
                      walletController.finalPRice.value = value;
                      walletController.finalCount.value = counts;
                      await Get.to(
                        () => OrderPage(
                          pubgID: pubgUserIDController.text,
                          onlyCard: false,
                          asking: 'accountDetaile2'.tr,
                        ),
                      );
                    } else {
                      showSnackBar(
                        'tournamentInfo14',
                        'errorEmpty',
                        Colors.red,
                      );
                    }
                  } else {
                    showSnackBar(
                      'noConnection3',
                      'order_error_subtitle',
                      Colors.red,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static const _gold = Color(0xFFFFC83D);
  static const _tabs = ['UC', 'WOW', 'Premium'];

  int _tab = 0;
  late final Future<List<Map>> _categories = _loadCategories();
  final Map<int, Future<List<UcModel>?>> _tabFutures = {};

  Future<List<Map>> _loadCategories() async {
    final result = await UcdayyApi.getUcCategories();
    return result.ok ? apiItems(result.data) : [];
  }

  /// The API category whose name mentions the tab, if there is one.
  int? _categoryIdFor(List<Map> categories, String tab) {
    final key = tab.toLowerCase();
    for (final category in categories) {
      final names = category.values.whereType<String>().map(
        (v) => v.toLowerCase(),
      );
      if (names.any((name) => name.contains(key))) {
        return category['id'] as int?;
      }
    }
    return null;
  }

  /// Products of one tab; null when the tab has no category on the server yet.
  Future<List<UcModel>?> _tabFuture(int tab) {
    return _tabFutures.putIfAbsent(tab, () async {
      final id = _categoryIdFor(await _categories, _tabs[tab]);
      if (id != null) {
        return UcModel().getUCS(category: id);
      }
      // Without a matching category the UC tab shows every product.
      return tab == 0 ? UcModel().getUCS() : null;
    });
  }

  Widget _tabContent() {
    return FutureBuilder<List<UcModel>?>(
      future: _tabFuture(_tab),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(height: 320, child: Center(child: spinKit()));
        }
        final items = snapshot.data;
        if (snapshot.hasError || items == null || items.isEmpty) {
          return _emptyState(snapshot.hasError);
        }
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) => UcPackageCard(model: items[index]),
        );
      },
    );
  }

  Widget _emptyState(bool failed) {
    return SizedBox(
      height: 360,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.12),
                border: Border.all(color: _gold.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: HugeIcon(
                  icon: failed
                      ? HugeIcons.strokeRoundedWifiDisconnected01
                      : HugeIcons.strokeRoundedClock01,
                  color: _gold,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              (failed ? 'noConnection3' : 'premiumSoon').tr,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: gilroySemiBold,
                fontSize: 18,
              ),
            ),
            if (failed) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _tabFutures.remove(_tab)),
                child: const Text(
                  '↻',
                  style: TextStyle(color: _gold, fontSize: 26),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
