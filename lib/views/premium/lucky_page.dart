import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/lucky_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// The lucky wheel: the games and the player's cashback come from
/// `GET /games/lucky/`; a spin costs 1 cashback and `POST .../spin/` tells the
/// slice the wheel has to stop on.
class LuckyPage extends StatefulWidget {
  const LuckyPage({super.key});

  @override
  State<LuckyPage> createState() => _LuckyPageState();
}

class _LuckyPageState extends State<LuckyPage> with TickerProviderStateMixin {
  LuckyData? _data;
  bool _loading = true;
  bool _failed = false;
  int _gameIndex = 0;

  /// A spin request or the wheel animation is running.
  bool _busy = false;

  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200));
  late final AnimationController _lights = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

  double _from = 0;
  double _to = 0;
  ui.Image? _giftImage;

  /// The wheel angle right now.
  double get _angle => _from + (_to - _from) * Curves.easeOutQuart.transform(_spin.value);

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getUserMoney();
    _loadGiftImage();
    _load();
  }

  Future<void> _loadGiftImage() async {
    final bytes = await rootBundle.load('assets/image/lucky_gift.webp');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (mounted) {
      setState(() => _giftImage = frame.image);
    } else {
      frame.image.dispose();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _lights.dispose();
    _giftImage?.dispose();
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    final result = await UcdayyApi.getLucky();
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      if (result.ok) {
        final data = LuckyData.fromJson(result.data);
        final firstLoad = _data == null;
        _data = data;
        _failed = false;
        // Starts on a game that is running, if there is one.
        final live = data.games.indexWhere((g) => g.isLive);
        if (!quiet || _gameIndex >= data.games.length) {
          _gameIndex = live < 0 ? 0 : live;
        }
        if (firstLoad && data.games.isNotEmpty) {
          final count = data.games[_gameIndex].prizes.length;
          if (count > 0) {
            _from = -math.pi / count;
            _to = _from;
          }
        }
      } else if (_data == null) {
        _failed = true;
      }
    });
  }

  LuckyGame? get _game {
    final data = _data;
    if (data == null || data.games.isEmpty) {
      return null;
    }
    return data.games[_gameIndex.clamp(0, data.games.length - 1)];
  }

  bool get _canSpin {
    final game = _game;
    return !_busy && game != null && game.isLive && game.prizes.length >= 2 && (_data?.spinsLeft ?? 0) > 0;
  }

  Future<void> _doSpin() async {
    final game = _game;
    if (game == null || _busy) {
      return;
    }
    if (!_canSpin) {
      _explainWhyNot(game);
      return;
    }
    setState(() => _busy = true);
    final result = await UcdayyApi.spinLucky(game.id);
    if (!mounted) {
      return;
    }
    final data = result.data;
    if (!result.ok || data is! Map) {
      setState(() => _busy = false);
      _showMessage(result.error ?? 'noConnection3'.tr);
      if (result.statusCode == 409 || result.statusCode == 400) {
        await _load(quiet: true);
      }
      return;
    }
    final spin = LuckySpinResult.fromJson(data);
    // Land the slice `prizeIndex` under the pointer at the top: the slices start
    // at the top and run clockwise, so slice i is centered at (i + 0.5) * slice.
    final slice = 2 * math.pi / game.prizes.length;
    var index = spin.prizeIndex;
    if (index < 0) {
      // The server names the prize, not its position: find its slice.
      index = game.prizes.indexWhere((p) => p.id == spin.prizeId);
      if (index < 0) {
        index = game.prizes.indexWhere((p) => p.points == spin.points);
      }
    }
    index = index.clamp(0, game.prizes.length - 1);
    final stop = -(index + 0.5) * slice;
    final current = _angle;
    var delta = (stop - current) % (2 * math.pi);
    if (delta < 0) {
      delta += 2 * math.pi;
    }
    _from = current;
    _to = current + 2 * math.pi * 6 + delta;
    setState(() {
      final old = _data!;
      _data = LuckyData(cashback: spin.cashback, spinsLeft: spin.cashback.floor(), spinPrice: old.spinPrice, games: old.games);
    });
    await _spin.forward(from: 0);
    if (!mounted) {
      return;
    }
    _from = _to;
    _spin.value = 0;
    Get.find<WalletController>().setMoneyFromPoints(spin.pointsBalance?.toStringAsFixed(2));
    setState(() => _busy = false);
    await _showResult(spin, game.prizes[index]);
    await _load(quiet: true);
  }

  void _explainWhyNot(LuckyGame game) {
    if (!game.isLive) {
      _showMessage('luckyStatus_${game.status}'.tr);
    } else if ((_data?.spinsLeft ?? 0) <= 0) {
      _showMessage('luckyNoSpins'.tr);
    }
  }

  void _showMessage(String text) {
    showSnackBar('cashbackTitle', text, Colors.red);
  }

  Future<void> _buySpin() async {
    final price = _data?.spinPrice;
    if (price == null || _busy) {
      return;
    }
    final priceText = '${price == price.roundToDouble() ? price.toInt() : price} TMT';
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => _ConfirmDialog(title: 'luckyBuySpin'.tr, value: priceText),
    );
    if (ok != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    final result = await UcdayyApi.buyLuckySpins(1);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (result.ok) {
      final data = result.data;
      if (data is Map && data['points_balance'] != null) {
        Get.find<WalletController>().setMoneyFromPoints('${data['points_balance']}');
      }
      await _load(quiet: true);
    } else {
      _showMessage(result.error ?? 'noConnection3'.tr);
    }
  }

  Future<void> _showResult(LuckySpinResult spin, LuckyPrize prize) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (context) => _ResultDialog(
        // What the server paid is what counts, not the slice the wheel stopped on:
        // the wheel may land on a decorative slice while the spin pays 1 TMT.
        won: spin.points > 0,
        label: '${spin.points == spin.points.roundToDouble() ? spin.points.toInt() : spin.points} TMT',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'cashbackTitle'.tr, onBack: Get.back, trailing: const BalanceChip()),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return Shimmer(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: const [
            ShimmerBlock(height: 170, radius: 28),
            SizedBox(height: 20),
            Center(child: ShimmerBlock(width: 300, height: 300, radius: 150)),
            SizedBox(height: 20),
            ShimmerBlock(height: 62, radius: 22),
          ],
        ),
      );
    }
    if (_failed || _game == null) {
      return Center(child: errorData(onTap: _load));
    }
    final game = _game!;
    final data = _data!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final hasBuy = data.spinPrice != null && game.isLive;
        final hasChips = data.games.length > 1;
        // Everything is sized so the page fits one screen without scrolling:
        // the wheel takes whatever height the fixed parts leave over.
        final fixed = 84 + 44 + 56 + 54 + (hasBuy ? 40 : 0) + (hasChips ? 44 : 0) + 7 * 8 + 24;
        final wheelSize = (height - fixed - 20).clamp(220.0, math.min(width - 32, 380.0)).toDouble();
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/image/lucky_hero.webp', fit: BoxFit.cover, alignment: Alignment.topCenter, cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round()),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x990D0E12), Color(0xFF0D0E12)], stops: [0, 0.45, 0.8]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset('assets/image/lucky_decor.webp', fit: BoxFit.fitWidth, alignment: Alignment.bottomCenter, cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round()),
              ),
            ),
            // Only if a very small screen cannot fit it, the page may scroll.
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _title(width),
                    const SizedBox(height: 8),
                    _subtitle(),
                    if (hasChips) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: _gameChips(data)),
                    const SizedBox(height: 8),
                    _wheel(game, wheelSize),
                    const SizedBox(height: 8),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: _spinButton(game, data)),
                    const SizedBox(height: 8),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _stats(game, data)),
                    if (hasBuy) ...[const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buyButton(data.spinPrice!))],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// "UCDAYY / CASHBACK", centered above the wheel.
  Widget _title(double width) {
    final small = width < 360;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 76,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 22, strokeWidth: 2),
              Text(
                'UCDAYY',
                style: TextStyle(
                  color: _gold,
                  fontFamily: gilroyBold,
                  fontStyle: FontStyle.italic,
                  fontSize: small ? 34 : 40,
                  height: 0.95,
                  letterSpacing: 1,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 4)),
                    Shadow(color: _goldDark, blurRadius: 14),
                  ],
                ),
              ),
              Text(
                'CASHBACK',
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: gilroyBold,
                  fontStyle: FontStyle.italic,
                  fontSize: small ? 22 : 27,
                  height: 1,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 4))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subtitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C4209), Color(0xF20D0A06), Color(0xFF6C4209)]),
        border: Border.all(color: _gold, width: 1.2),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.28), blurRadius: 14)],
      ),
      child: Text(
        'luckyHeroSubtitle'.tr,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 12.5, height: 1.2),
      ),
    );
  }

  Widget _gameChips(LuckyData data) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.games.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _gameIndex;
          final title = data.games[index].title.isEmpty ? '#${data.games[index].id}' : data.games[index].title;
          return GestureDetector(
            onTap: _busy ? null : () => setState(() => _gameIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: selected ? _gold : Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: selected ? _gold : Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                title,
                style: TextStyle(color: selected ? const Color(0xFF1A1200) : Colors.white70, fontFamily: gilroyBold, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Spins left, cashback and, when the game limits them, the free winner slots.
  Widget _stats(LuckyGame game, LuckyData data) {
    final cashback = data.cashback;
    final cashbackText = cashback == cashback.roundToDouble() ? '${cashback.toInt()}' : cashback.toStringAsFixed(2);
    return Row(
      children: [
        Expanded(child: _statTile(HugeIcons.strokeRoundedRotate01, 'luckySpinsLeft'.tr, '${data.spinsLeft}')),
        const SizedBox(width: 10),
        Expanded(child: _statTile(HugeIcons.strokeRoundedCoins01, 'cashbackTitle'.tr, cashbackText)),
        if (game.winnersLeft != null) ...[const SizedBox(width: 10), Expanded(child: _statTile(HugeIcons.strokeRoundedAward01, 'luckyWinnersLeft'.tr, '${game.winnersLeft}'))],
      ],
    );
  }

  Widget _statTile(List<List<dynamic>> icon, String label, String value) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xEB17171A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: _gold, size: 18, strokeWidth: 1.8),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontFamily: gilroyMedium, fontSize: 11, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18, height: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wheel(LuckyGame game, double size) {
    final width = MediaQuery.sizeOf(context).width;
    final active = game.isLive;
    return Center(
      child: SizedBox(
        width: width,
        height: size + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 12,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.22), blurRadius: 50, spreadRadius: 12)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              child: AnimatedBuilder(
                animation: Listenable.merge([_spin, _lights]),
                builder: (context, _) => SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _WheelPainter(labels: [for (final p in game.prizes) p.label], angle: _angle, lights: _lights.value, dim: !active, giftImage: _giftImage),
                  ),
                ),
              ),
            ),
            // The pointer stays still while the wheel turns under it.
            const Positioned(top: 0, child: _Pointer()),
            Positioned(
              top: 12 + size / 2 - size * 0.13,
              child: GestureDetector(
                onTap: _doSpin,
                child: Container(
                  width: size * 0.26,
                  height: size * 0.26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _canSpin ? const [Color(0xFFFFE68A), _goldDark] : [Colors.grey.shade600, Colors.grey.shade800],
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                    boxShadow: [BoxShadow(color: (_canSpin ? _gold : Colors.black).withValues(alpha: 0.55), blurRadius: 18)],
                  ),
                  child: _busy
                      ? const Center(
                          child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF1A1200))),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: Color(0xFF1A1200), size: 22, strokeWidth: 2),
                            Text(
                              'luckySpin'.tr,
                              style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 11, height: 1.2),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spinButton(LuckyGame game, LuckyData data) {
    final can = _canSpin;
    final String label;
    if (!game.isLive) {
      label = 'luckyStatus_${game.status}'.tr;
    } else if (data.spinsLeft <= 0) {
      label = 'luckyNoSpins'.tr;
    } else {
      label = '${'luckySpin'.tr}  ·  ${data.spinsLeft}';
    }
    return GestureDetector(
      onTap: _doSpin,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: can || _busy ? 1 : 0.55,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE08A), _goldDark]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: can ? 0.4 : 0.1),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF1A1200)))
              : Text(
                  game.isLive ? 'luckyCashbackButton'.tr : label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 18, height: 1.2),
                ),
        ),
      ),
    );
  }

  Widget _buyButton(double price) {
    final priceText = '${price == price.roundToDouble() ? price.toInt() : price} TMT';
    return GestureDetector(
      onTap: _buySpin,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF17171A),
          border: Border.all(color: _gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedRotate01, color: _gold, size: 20, strokeWidth: 1.8),
            const SizedBox(width: 10),
            Text(
              'luckyBuySpin'.tr,
              style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
            ),
            const SizedBox(width: 10),
            Text(
              priceText,
              style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// The gold marker above the wheel that points at the winning slice.
class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(34, 40), painter: _PointerPainter());
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.22)
      ..quadraticBezierTo(size.width / 2, -size.height * 0.1, size.width, size.height * 0.22)
      ..close();
    canvas.drawShadow(path, Colors.black, 6, true);
    canvas.drawPath(path, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE68A), _goldDark]).createShader(Offset.zero & size));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.34), 4, Paint()..color = const Color(0xFF1A1200));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The wheel: a gold ring with blinking lights around the prize slices. The
/// first slice starts at the top and the slices run clockwise.
class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.labels, required this.angle, required this.lights, required this.dim, required this.giftImage});

  final List<String> labels;
  final double angle;
  final double lights;
  final bool dim;
  final ui.Image? giftImage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final ring = radius * 0.095;
    final inner = radius - ring;

    // Outer gold ring with its glow.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _gold.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()..shader = const SweepGradient(colors: [Color(0xFFFFE68A), _goldDark, Color(0xFFFFE68A), _goldDark, Color(0xFFFFE68A)]).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(center, inner + 1.5, Paint()..color = const Color(0xFF0E0C08));

    // The prize slices turn with the wheel.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final count = labels.length;
    final slice = 2 * math.pi / math.max(count, 1);
    final rect = Rect.fromCircle(center: Offset.zero, radius: inner);
    for (var i = 0; i < count; i++) {
      final start = -math.pi / 2 + i * slice;
      final even = i.isEven;
      final fill = Paint()..shader = RadialGradient(colors: even ? const [Color(0xFF2A2312), Color(0xFF16120A)] : const [Color(0xFF5A4518), Color(0xFF2C220C)]).createShader(rect);
      canvas.drawArc(rect, start, slice, true, fill);
      canvas.drawArc(
        rect,
        start,
        slice,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _gold.withValues(alpha: 0.55),
      );
      _prize(canvas, labels[i], start + slice / 2, inner, angle);
    }
    canvas.restore();

    // Lights on the ring: two sets that blink in turn.
    const bulbs = 24;
    final ringRadius = radius - ring / 2;
    for (var i = 0; i < bulbs; i++) {
      final a = 2 * math.pi * i / bulbs;
      final on = (i.isEven ? lights : 1 - lights);
      final position = center + Offset(math.cos(a), math.sin(a)) * ringRadius;
      canvas.drawCircle(
        position,
        ring * 0.3,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35 + 0.6 * on)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    if (dim) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.black.withValues(alpha: 0.45));
    }
  }

  /// Each gift and its amount stay upright on screen while the wheel turns:
  /// they sit on the slice but are counter-rotated by the wheel's angle.
  void _prize(Canvas canvas, String text, double sliceAngle, double inner, double wheelAngle) {
    final direction = Offset(math.cos(sliceAngle), math.sin(sliceAngle));
    final gift = giftImage;
    if (gift != null) {
      final giftSize = inner * 0.26;
      final center = direction * (inner * 0.72);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-wheelAngle);
      canvas.drawImageRect(
        gift,
        Rect.fromLTWH(0, 0, gift.width.toDouble(), gift.height.toDouble()),
        Rect.fromCenter(center: Offset.zero, width: giftSize, height: giftSize),
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }
    final display = text.replaceFirst(RegExp(r'\s+TMT$', caseSensitive: false), '\nTMT');
    // A long amount (millions) is made smaller until it fits on one line of the slice.
    final limit = inner * 0.48;
    var fontSize = math.max(12.0, inner * 0.115);
    TextPainter build(double size, double width) => TextPainter(
      text: TextSpan(
        text: display,
        style: TextStyle(
          color: Colors.white,
          fontFamily: gilroyBold,
          fontSize: size,
          height: 0.98,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 2))],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: width);
    final natural = build(fontSize, double.infinity);
    if (natural.width > limit) {
      fontSize = math.max(7.0, fontSize * limit / natural.width);
    }
    final painter = build(fontSize, limit + 4);
    final center = direction * (inner * 0.43);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-wheelAngle);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => old.angle != angle || old.lights != lights || old.dim != dim || old.labels != labels || old.giftImage != giftImage;
}

/// Asks to confirm a purchase: its title and price.
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF26231C), Color(0xFF131315)]),
          border: Border.all(color: _gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 30),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                ),
                child: Text(
                  'agree'.tr,
                  style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44), foregroundColor: Colors.white70),
              child: Text('cancel'.tr, style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the spin gave: the prize, or a nudge to try again.
class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.won, required this.label});

  final bool won;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = won ? _gold : const Color(0xFF8D9AB8);
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withValues(alpha: 0.22), const Color(0xFF131315)]),
            border: Border.all(color: color.withValues(alpha: 0.45)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 44)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, t, child) => Transform.scale(scale: t.clamp(0.0, 1.4), child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 30)],
                  ),
                  child: Center(
                    child: HugeIcon(icon: won ? HugeIcons.strokeRoundedGift : HugeIcons.strokeRoundedRotate01, color: color, size: 50, strokeWidth: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                (won ? 'luckyWon' : 'luckyLost').tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 26, height: 1.15),
              ),
              const SizedBox(height: 10),
              if (won) ...[
                Text(
                  'luckyWonText'.tr,
                  style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 34),
                ),
              ] else
                Text(
                  'luckyLostText'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 16),
                ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                  ),
                  child: Text(
                    'luckyOk'.tr,
                    style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
