import 'dart:async';
import 'dart:ui';

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/premium_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/premium/premium_buy_dialog.dart';
import 'package:game_app/views/user_profil/auth/tab_bar_view.dart';
import 'package:game_app/views/best_players/best_players.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/premium/lucky_page.dart';
import 'package:game_app/views/tournament_page/tournament.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);

/// The Premium tab: the best players, the tournaments and the lobbies as picture
/// tiles, and at the bottom the cashback banner that opens the lucky wheel.
/// Without premium the tiles stay visible but blurred, with an offer on top.
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  late Future<ApiResult> _future = UcdayyApi.getPremium();

  /// The offer is hidden and the page shown clean, to look at what premium gives.
  bool _peeking = false;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getUserMoney();
  }

  Future<void> _reload() async {
    final next = UcdayyApi.getPremium();
    setState(() {
      _future = next;
    });
    await next;
    Get.find<WalletController>().getUserMoney();
  }

  Future<void> _buy(PremiumStatus status) async {
    final bought = await showPremiumBuyDialog(context, status);
    if (bought && mounted) {
      await _reload();
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
            CenteredHeader(title: 'tournament'.tr, trailing: const BalanceChip()),
            Expanded(
              child: FutureBuilder<ApiResult>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _gold));
                  }
                  final result = snapshot.data;
                  if (result == null || !result.ok) {
                    final needsLogin = result != null && (result.statusCode == 401 || result.statusCode == 403);
                    return Stack(
                      children: [
                        _blurred(_content()),
                        _offer(child: needsLogin ? _loginCard() : _errorCard()),
                      ],
                    );
                  }
                  final status = PremiumStatus.fromJson(result.data);
                  if (status.premium) {
                    return _content(status: status);
                  }
                  return Stack(
                    children: [
                      _blurred(_content(), blur: !_peeking),
                      _offer(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          ),
                          child: KeyedSubtree(key: ValueKey(_peeking), child: _peeking ? _peekBar(status) : _offerCard(status)),
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
    );
  }

  Widget _blurred(Widget child, {bool blur = true}) {
    return IgnorePointer(
      child: blur
          ? ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.decal),
              child: child,
            )
          : child,
    );
  }

  /// While peeking: a slim bar that brings the offer back.
  Widget _peekBar(PremiumStatus status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: _cardDecoration,
      child: Row(
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 22, strokeWidth: 1.8),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status.price > 0 ? '${status.priceText} TMT' : 'premiumLockedTitle'.tr,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _peeking = false),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
              ),
              child: Text(
                'premiumBuy'.tr,
                style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The offer sits at the bottom, so the blurred page stays readable above it.
  Widget _offer({required Widget child}) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x00000000), Color(0xCC000000)], stops: [0, 0.35, 1]),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(reverse: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 96), child: child),
        ),
      ),
    );
  }

  Future<void> _openLogin() async {
    await Get.to(() => const TabBarViewPage());
    if (mounted) {
      await _reload();
    }
  }

  /// A round icon, a title, a line of explanation and one action.
  Widget _stateCard({required List<List<dynamic>> icon, required String title, required String action, required VoidCallback onAction, String? text}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: _cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.14),
              border: Border.all(color: _gold.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: _gold, size: 34, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22, height: 1.15),
          ),
          if (text != null) ...[
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 14.5, height: 1.4),
            ),
          ],
          const SizedBox(height: 20),
          _goldButton(action, onAction),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return _stateCard(icon: HugeIcons.strokeRoundedLockKey, title: 'premiumLoginFirst'.tr, text: 'premiumLoginText'.tr, action: 'premiumLoginButton'.tr, onAction: _openLogin);
  }

  Widget _errorCard() {
    return _stateCard(icon: HugeIcons.strokeRoundedWifiOff01, title: 'premiumLoadError'.tr, action: 'premiumRetry'.tr, onAction: _reload);
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    border: Border.all(color: _gold.withValues(alpha: 0.4)),
    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E2718), Color(0xFF141416)]),
    boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.18), blurRadius: 30)],
  );

  Widget _offerCard(PremiumStatus status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
      decoration: _cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.16),
              border: Border.all(color: _gold.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 34, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'premiumLockedTitle'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'premiumLockedText'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 14.5, height: 1.4),
          ),
          const SizedBox(height: 18),
          _perk(HugeIcons.strokeRoundedCrown, 'premiumPerkTournaments'.tr),
          _perk(HugeIcons.strokeRoundedGift, 'premiumPerkLucky'.tr),
          _perk(HugeIcons.strokeRoundedAward01, 'premiumPerkBest'.tr),
          const SizedBox(height: 18),
          if (status.price > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: status.priceText,
                      style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 34),
                    ),
                    const TextSpan(
                      text: ' TMT',
                      style: TextStyle(color: _gold, fontFamily: gilroySemiBold, fontSize: 16),
                    ),
                    if (status.days > 0)
                      TextSpan(
                        text: '  /  ${status.days} ${'premiumDays'.tr}',
                        style: const TextStyle(color: Colors.white60, fontFamily: gilroyMedium, fontSize: 15),
                      ),
                  ],
                ),
              ),
            ),
          _goldButton('premiumBuy'.tr, () => _buy(status)),
          TextButton(
            onPressed: () => setState(() => _peeking = true),
            child: Text(
              'premiumPeek'.tr,
              style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _perk(List<List<dynamic>> icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withValues(alpha: 0.12)),
            child: Center(
              child: HugeIcon(icon: icon, color: _gold, size: 17, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 14.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldButton(String label, VoidCallback onTap, {bool busy = false}) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
        ),
        child: busy
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Text(
                label,
                style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 17),
              ),
      ),
    );
  }

  Widget _content({PremiumStatus? status}) {
    return RefreshIndicator(
      color: _gold,
      backgroundColor: const Color(0xFF1C1C20),
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        // Room for the navigation bar that covers the bottom of the page.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (status != null && status.daysLeft > 0) ...[_activeChip(status), const SizedBox(height: 12)],
          _Tile(title: 'bestPlayers2'.tr, image: 'assets/image/img3.jpg', icon: HugeIcons.strokeRoundedAward01, height: 150, onTap: () => Get.to(() => const BestPlayers())),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Tile(title: 'Turnir', image: 'assets/image/img1.jpg', icon: HugeIcons.strokeRoundedCrown, height: 190, onTap: () => Get.to(() => const TournamentPage(tournamentType: 1))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Tile(title: 'Lobbi', image: 'assets/image/img2.jpg', icon: HugeIcons.strokeRoundedGift, height: 190, onTap: () => Get.to(() => const TournamentPage(tournamentType: 2))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CashbackBanner(onTap: () => Get.to(() => const LuckyPage())),
        ],
      ),
    );
  }

  Widget _activeChip(PremiumStatus status) {
    return _PremiumCountdown(status: status);
  }
}

/// The time premium has left, ticking every second: days, hours, minutes, seconds.
class _PremiumCountdown extends StatefulWidget {
  const _PremiumCountdown({required this.status});

  final PremiumStatus status;

  @override
  State<_PremiumCountdown> createState() => _PremiumCountdownState();
}

class _PremiumCountdownState extends State<_PremiumCountdown> {
  Timer? _timer;
  late Duration _left;

  /// The end of premium; without an exact date, the whole days left from now.
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _setEnd();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_tick);
      }
    });
  }

  @override
  void didUpdateWidget(_PremiumCountdown old) {
    super.didUpdateWidget(old);
    if (old.status.until != widget.status.until || old.status.daysLeft != widget.status.daysLeft) {
      _setEnd();
    }
  }

  void _setEnd() {
    final until = DateTime.tryParse(widget.status.until ?? '');
    _end = until ?? DateTime.now().add(Duration(days: widget.status.daysLeft));
    _tick();
  }

  void _tick() {
    final left = _end.difference(DateTime.now());
    _left = left.isNegative ? Duration.zero : left;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = [(_left.inDays, 'premiumDays'.tr), (_left.inHours % 24, 'premiumHours'.tr), (_left.inMinutes % 60, 'premiumMinutes'.tr), (_left.inSeconds % 60, 'premiumSeconds'.tr)];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2416), Color(0xFF141416)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 20, strokeWidth: 1.8),
              const SizedBox(width: 8),
              Text(
                'premiumDaysLeft'.tr,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < units.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: _box(units[i].$1, units[i].$2))],
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(int value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: _gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 24, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 11, height: 1),
          ),
        ],
      ),
    );
  }
}

/// A picture tile: the title at the bottom over a dark fade, an icon and an arrow.
class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.image, required this.icon, required this.height, required this.onTap});

  final String title;
  final String image;
  final List<List<dynamic>> icon;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover, cacheWidth: 900),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0x00000000), Color(0xDD000000)], stops: [0, 0.35, 1]),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: _gold, size: 20, strokeWidth: 1.8),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 52,
              bottom: 14,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 24, height: 1.1),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.16)),
                child: const Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedArrowUpRight01, color: Colors.white, size: 18, strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The cashback banner picture: spend 100 TMT or more, earn cashback, spin the
/// lucky wheel. A tap opens the wheel.
class _CashbackBanner extends StatelessWidget {
  const _CashbackBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 2,
          child: Image.asset('assets/image/cashback_banner.webp', fit: BoxFit.cover, cacheWidth: 1200, filterQuality: FilterQuality.high),
        ),
      ),
    );
  }
}
