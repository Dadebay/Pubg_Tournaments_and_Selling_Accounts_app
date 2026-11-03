import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/premium_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';

const _gold = Color(0xFFFFC83D);
const _green = Color(0xFF34D399);
const _red = Color(0xFFFF5A5F);

/// Asks to buy premium and does it inside the same dialog: confirm → busy →
/// done (or the reason it failed). Returns true when premium was bought.
Future<bool> showPremiumBuyDialog(
  BuildContext context,
  PremiumStatus status,
) async {
  final bought = await Navigator.of(
    context,
    rootNavigator: true,
  ).push<bool>(_PremiumDialogRoute(status));
  return bought ?? false;
}

class _PremiumDialogRoute extends RawDialogRoute<bool> {
  _PremiumDialogRoute(PremiumStatus status)
    : super(
        barrierDismissible: true,
        barrierLabel: 'premium',
        barrierColor: Colors.black.withValues(alpha: 0.7),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondary) =>
            _PremiumBuyDialog(status: status),
        transitionBuilder: (context, animation, secondary, child) =>
            _PremiumDialogTransition(animation: animation, child: child),
      );

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 180);
}

class _PremiumDialogTransition extends StatefulWidget {
  const _PremiumDialogTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  State<_PremiumDialogTransition> createState() =>
      _PremiumDialogTransitionState();
}

class _PremiumDialogTransitionState extends State<_PremiumDialogTransition> {
  late CurvedAnimation _motion = _createMotion();

  CurvedAnimation _createMotion() => CurvedAnimation(
    parent: widget.animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void didUpdateWidget(_PremiumDialogTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _motion.dispose();
      _motion = _createMotion();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _motion,
      child: MediaQuery.disableAnimationsOf(context)
          ? widget.child
          : ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(_motion),
              child: widget.child,
            ),
    );
  }
}

enum _Step { confirm, busy, done, failed }

class _PremiumBuyDialog extends StatefulWidget {
  const _PremiumBuyDialog({required this.status});

  final PremiumStatus status;

  @override
  State<_PremiumBuyDialog> createState() => _PremiumBuyDialogState();
}

class _PremiumBuyDialogState extends State<_PremiumBuyDialog> {
  _Step _step = _Step.confirm;
  String _error = '';

  Future<void> _buy() async {
    setState(() => _step = _Step.busy);
    final result = await UcdayyApi.buyPremium();
    if (!mounted) {
      return;
    }
    if (result.ok) {
      final balance = result.data is Map ? result.data['points_balance'] : null;
      if (balance != null) {
        Get.find<WalletController>().setMoneyFromPoints('$balance');
      }
      HapticFeedback.mediumImpact();
      setState(() => _step = _Step.done);
      return;
    }
    setState(() {
      _error = result.statusCode == 401 || result.statusCode == 403
          ? 'premiumLoginFirst'.tr
          : 'premiumNotEnough'.tr;
      _step = _Step.failed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step != _Step.busy,
      onPopInvokedWithResult: (didPop, result) {},
      child: Stack(
        children: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: (_step == _Step.failed ? _red : _gold).withValues(
                      alpha: 0.4,
                    ),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2E2718), Color(0xFF141416)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.18),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    child: KeyedSubtree(key: ValueKey(_step), child: _body()),
                  ),
                ),
              ),
            ),
          ),
          // Confetti over the whole screen once premium is bought; it plays once and
          // never takes a touch.
          if (_step == _Step.done)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    return switch (_step) {
      _Step.confirm => _confirm(),
      _Step.busy => _status(
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(color: _gold, strokeWidth: 4),
        ),
        'premiumBuy'.tr,
        null,
      ),
      _Step.done => _status(
        const _ResultIcon(icon: Icons.check_rounded, color: _green),
        'premiumBought'.tr,
        _button('premiumDone'.tr, () => Navigator.of(context).pop(true)),
      ),
      _Step.failed => _status(
        const _ResultIcon(icon: Icons.close_rounded, color: _red),
        _error,
        _button(
          'premiumCancel'.tr,
          () => Navigator.of(context).pop(false),
          outlined: true,
        ),
      ),
    };
  }

  Widget _confirm() {
    final status = widget.status;
    return Column(
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
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCrown,
              color: _gold,
              size: 34,
              strokeWidth: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'premiumConfirmTitle'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: gilroyBold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _row('premiumDays'.tr, status.days > 0 ? '${status.days}' : '-'),
              const SizedBox(height: 8),
              _row(
                'premiumYourBalance'.tr,
                '${Get.find<WalletController>().userMoney.value} TMT',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Colors.white12),
              ),
              _row(
                'premiumBuy'.tr,
                status.price > 0 ? '${status.priceText} TMT' : '-',
                big: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _button('premiumBuy'.tr, _buy),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'premiumCancel'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: gilroySemiBold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool big = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFFB8B8C0),
              fontFamily: gilroyMedium,
              fontSize: big ? 16 : 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: big ? _gold : Colors.white,
            fontFamily: gilroyBold,
            fontSize: big ? 22 : 15,
          ),
        ),
      ],
    );
  }

  Widget _status(Widget icon, String text, Widget? action) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        SizedBox(height: 76, child: Center(child: icon)),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: gilroyBold,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 22), action],
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _button(String label, VoidCallback onTap, {bool outlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: outlined
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
                ),
          border: outlined ? Border.all(color: Colors.white24) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined ? Colors.white : Colors.black,
            fontFamily: gilroyBold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

/// One small overshoot makes the result legible without an elastic bounce.
class _ResultIcon extends StatefulWidget {
  const _ResultIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_ResultIcon> createState() => _ResultIconState();
}

class _ResultIconState extends State<_ResultIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale = _controller.drive(
    TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.88,
          end: 1.04,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.04,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 32,
      ),
    ]),
  );
  late final Animation<double> _opacity = _controller.drive(
    CurveTween(curve: const Interval(0, 0.55, curve: Curves.easeOut)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.16),
            border: Border.all(color: widget.color, width: 2.5),
          ),
          child: Icon(widget.icon, color: widget.color, size: 42),
        ),
      ),
    );
  }
}
