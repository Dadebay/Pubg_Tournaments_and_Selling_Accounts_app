import 'package:hugeicons/hugeicons.dart';

import '../constants/shimmer.dart';

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';

import '../../../models/user_models/auth_model.dart';

import '../../repository/ucdayy_api.dart';
import '../cards/premium_package_card.dart';
import '../cards/uc_package_card.dart';
import '../constants/catalog_empty_state.dart';
import '../constants/collapsing_tabs_page.dart';
import '../constants/index.dart';
import 'cart_fab.dart';
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
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      // The floating nav bar overlaps the page, so lift the button above it.
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 8,
        ),
        child: CartFab(
          onTap: () async {
            if (await _checkToken()) {
              await onTapFunction();
            }
          },
        ),
      ),
      body: CollapsingTabsPage(
        title: 'Pubg UC',
        actions: userAppBarMoney(),
        tabs: [
          for (final category in _categories ?? const <Map>[])
            SegmentTab(label: _categoryName(category)),
          // The tab bar needs at least one tab while the categories load.
          if (_categories == null || _categories!.isEmpty)
            const SegmentTab(label: 'UC'),
        ],
        selectedIndex: _tab,
        onTabChanged: (i) => setState(() => _tab = i),
        onRefresh: _refresh,
        // Room for the floating order button and the nav bar.
        bottomPadding: 90,
        body: _tabContent(),
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
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => _idDialog(),
    );
  }

  static const _gold = Color(0xFFFFC83D);

  /// Asks for the PUBG id the UC are sent to, with a short summary of the cart.
  Widget _idDialog() {
    var count = 0;
    var total = 0.0;
    for (final item in walletController.cartList) {
      count += item['count'] as int;
      total +=
          (double.tryParse('${item['price']}') ?? 0) * (item['count'] as int);
    }
    final price =
        '${total == total.roundToDouble() ? total.toInt() : total.toStringAsFixed(2)} TMT';
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF26231C), Color(0xFF131315)],
          ),
          border: Border.all(color: _gold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(color: _gold.withValues(alpha: 0.18), blurRadius: 40),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: _gold.withValues(alpha: 0.12),
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedGameController03,
                    color: _gold,
                    size: 34,
                    strokeWidth: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'enterID'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: gilroyBold,
                  fontSize: 24,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              _summaryChip(count, price),
              const SizedBox(height: 20),
              Form(key: validator, child: _idField()),
              const SizedBox(height: 20),
              _confirmButton(),
              const SizedBox(height: 6),
              TextButton(
                onPressed: Get.back,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: Colors.white70,
                ),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(
                    fontFamily: gilroySemiBold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryChip(int count, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedShoppingBag01,
            color: Colors.white70,
            size: 18,
            strokeWidth: 1.6,
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: gilroyBold,
              fontSize: 15,
            ),
          ),
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white24,
          ),
          Text(
            price,
            style: const TextStyle(
              color: _gold,
              fontFamily: gilroyBold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _idField() {
    OutlineInputBorder border(Color color, [double width = 1.4]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );
    return TextFormField(
      controller: pubgUserIDController,
      focusNode: pubgUserIDFocusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      cursorColor: _gold,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: gilroyBold,
        fontSize: 22,
        letterSpacing: 1.5,
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'errorEmpty'.tr : null,
      decoration: InputDecoration(
        hintText: 'Pubg ID',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontFamily: gilroyMedium,
          fontSize: 18,
          letterSpacing: 0,
        ),
        errorStyle: const TextStyle(fontFamily: gilroyMedium),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Center(
            widthFactor: 1,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedIdentityCard,
              color: Colors.white.withValues(alpha: 0.5),
              size: 22,
              strokeWidth: 1.6,
            ),
          ),
        ),
        // Keeps the id centered between the icon and an equally wide gap.
        suffixIcon: const SizedBox(width: 48),
        enabledBorder: border(Colors.white.withValues(alpha: 0.16)),
        focusedBorder: border(_gold, 2),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 2),
      ),
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: _confirmId,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'agree'.tr,
          style: const TextStyle(
            color: Color(0xFF1A1200),
            fontFamily: gilroyBold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmId() async {
    if (!await _checkToken()) {
      showSnackBar('noConnection3', 'order_error_subtitle', Colors.red);
      return;
    }
    if (!validator.currentState!.validate()) {
      showSnackBar('tournamentInfo14', 'errorEmpty', Colors.red);
      return;
    }
    double value = 0.0;
    double counts = 0.0;
    for (var element in walletController.cartList) {
      value += double.parse(element['price']) * element['count'];
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
  }

  int _tab = 0;

  /// Tabs of the page: the categories of `/ucs/categories/`, in server order.
  /// Null while loading, empty list when the request failed.
  List<Map>? _categories;
  final Map<int, Future<List<UcModel>?>> _tabFutures = {};

  Future<void> _loadCategories() async {
    final result = await UcdayyApi.getUcCategories();
    if (!mounted) {
      return;
    }
    setState(() {
      _categories = result.ok ? apiItems(result.data) : [];
      _tab = 0;
    });
  }

  /// True while a pull to refresh runs: the cards give way to shimmering skeletons.
  bool _refreshing = false;

  /// Number of cards last shown, so the skeleton has the same size.
  int _shownCount = 4;

  /// Pull to refresh: the balance (`get-my-account`), the categories (tabs) and
  /// the products of the open tab are loaded again while the cards shimmer.
  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    // Shown for at least this long, so a fast answer does not make it flicker.
    final minimum = Future<void>.delayed(const Duration(milliseconds: 900));
    try {
      final money = walletController.getUserMoney();
      final result = await UcdayyApi.getUcCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        // A failed request keeps the tabs that are already shown.
        if (result.ok) {
          _categories = apiItems(result.data);
        }
        if (_tab >= (_categories?.length ?? 0)) {
          _tab = 0;
        }
      });
      final categories = _categories ?? [];
      if (categories.isNotEmpty) {
        final id = categories[_tab]['id'] as int;
        final fresh = await UcModel.getByCategory(id);
        if (!mounted) {
          return;
        }
        // The other tabs' products are stale now; they load when opened.
        _tabFutures.removeWhere((key, _) => key != id);
        if (fresh != null) {
          _tabFutures[id] = Future.value(fresh);
        }
      }
      await money;
      await minimum;
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  String _categoryName(Map category) {
    final isRu = Get.locale?.languageCode == 'ru';
    final name =
        category[isRu ? 'name_ru' : 'name_tm'] ??
        category['name_tm'] ??
        category['name_ru'] ??
        category['name'];
    return '${name ?? ''}';
  }

  String _emptyImageForCategory(Map category) {
    final names = [
      category['name'],
      category['name_tm'],
      category['name_ru'],
      category['slug'],
    ].whereType<String>().join(' ').toLowerCase();
    if (names.contains('wow') || names.contains('wonder')) {
      return 'assets/image/empty_wow_world.webp';
    }
    if (names.contains('premium') || names.contains('премиум')) {
      return 'assets/image/empty_premium_reward.webp';
    }
    return 'assets/image/empty_uc_tokens.webp';
  }

  /// Products of one category, loaded from `/ucs/categories/{id}/` once.
  Future<List<UcModel>?> _tabFuture(int id) {
    return _tabFutures.putIfAbsent(id, () => UcModel.getByCategory(id));
  }

  Widget _tabContent() {
    final categories = _categories;
    if (categories == null) {
      return const CatalogSkeletonGrid();
    }
    if (categories.isEmpty || _tab >= categories.length) {
      return _emptyState(true);
    }
    final id = categories[_tab]['id'] as int;
    if (_refreshing) {
      return CatalogSkeletonGrid(
        premium: _isPremium(categories[_tab]),
        count: _shownCount,
      );
    }
    return FutureBuilder<List<UcModel>?>(
      future: _tabFuture(id),
      builder: (context, snapshot) {
        // Waiting with data is a refresh: keep showing the cards that are there.
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return CatalogSkeletonGrid(premium: _isPremium(categories[_tab]));
        }
        final items = snapshot.data;
        if (snapshot.hasError || items == null) {
          return _emptyState(true);
        }
        if (items.isEmpty) {
          return _emptyState(false);
        }
        _shownCount = items.length;
        final premium = _isPremium(categories[_tab]);
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: premium ? 0.7 : 0.78,
          ),
          itemBuilder: (context, index) => premium
              ? PremiumPackageCard(
                  key: ValueKey(items[index].id),
                  model: items[index],
                )
              : UcPackageCard(
                  key: ValueKey(items[index].id),
                  model: items[index],
                ),
        );
      },
    );
  }

  bool _isPremium(Map category) {
    final names = [
      category['name'],
      category['name_tm'],
      category['name_ru'],
    ].whereType<String>().join(' ').toLowerCase();
    return names.contains('premium') || names.contains('премиум');
  }

  Widget _emptyState(bool failed) {
    final categories = _categories ?? [];
    // The tab page gives its body the free viewport height, so this centers.
    return Center(
      child: CatalogEmptyState(
        icon: failed ? IconlyLight.dangerCircle : IconlyLight.bag,
        imageAsset: failed ? null : _emptyImageForCategory(categories[_tab]),
        title: (failed ? 'catalogLoadErrorTitle' : 'catalogEmptyTitle').tr,
        description:
            (failed ? 'catalogLoadErrorDescription' : 'catalogEmptyDescription')
                .tr,
        actionLabel: failed ? 'noConnection3'.tr : null,
        actionIcon: Icons.refresh_rounded,
        onAction: failed
            ? () {
                if (categories.isEmpty) {
                  setState(() => _categories = null);
                  _loadCategories();
                } else {
                  setState(() => _tabFutures.remove(categories[_tab]['id']));
                }
              }
            : null,
      ),
    );
  }
}
