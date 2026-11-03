// ignore_for_file: file_names

import 'dart:async';

import 'package:game_app/connection_check.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/user_profil/pages/legal_page.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../constants/index.dart';

/// Asks for the code the server sent by sms (or e-mail) in four large boxes.
class OtpCheck extends StatefulWidget {
  final String phoneNumber;
  final bool loginType;
  const OtpCheck({
    required this.phoneNumber,
    required this.loginType,
    super.key,
  });

  @override
  State<OtpCheck> createState() => _OtpCheckState();
}

class _OtpCheckState extends State<OtpCheck>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC83D);
  static const _length = 4;

  final FocusNode _focus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _shakeOffset = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shake, curve: Curves.easeOut));

  bool _error = false;

  /// A check is running; further taps and keyboard submits are ignored.
  bool _busy = false;

  /// The sms can take up to two minutes; until then the code cannot be asked again.
  static const _waitSeconds = 120;
  Timer? _timer;
  int _left = _waitSeconds;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _error = false));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = _waitSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _left--);
      if (_left <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _resend() async {
    if (_left > 0 || _resending) {
      return;
    }
    setState(() => _resending = true);
    try {
      final status = widget.loginType
          ? await UserSignInModel().gmailLogin(email: widget.phoneNumber)
          : await UserSignInModel().login(phone: widget.phoneNumber);
      if (status == 200) {
        _controller.clear();
        _startTimer();
        showSnackBar('otp', 'otpResent', Colors.green);
      } else {
        showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
      }
    } catch (_) {
      showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
    }
    if (mounted) {
      setState(() => _resending = false);
    }
  }

  String get _clock =>
      '${(_left ~/ 60).toString().padLeft(2, '0')}:${(_left % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    _controller.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _fail() {
    setState(() => _error = true);
    _shake.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  void _toggleLoading() {
    final settings = Get.find<SettingsController>();
    settings.agreeButton.value = !settings.agreeButton.value;
  }

  void _submit() {
    if (_busy) {
      return;
    }
    if (_controller.text.length != _length) {
      _fail();
      showSnackBar('tournamentInfo14', 'signInDialog', Colors.red);
      return;
    }
    _busy = true;
    // Taken now: a successful check removes this page, and with it its context.
    final navigator = Navigator.of(context);
    _toggleLoading();
    final Future check = widget.loginType
        ? UserSignInModel().gmailOtpCheck(
            otp: _controller.text,
            email: widget.phoneNumber,
          )
        : UserSignInModel().otpCheck(
            otp: _controller.text,
            phoneNumber: widget.phoneNumber,
          );
    check
        .then((value) {
          if (value == true) {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const ConnectionCheck()),
              (Route<dynamic> route) => false,
            );
            return;
          }
          _busy = false;
          if (mounted) {
            _controller.clear();
            _fail();
          }
          showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
        })
        .catchError((Object _) {
          _busy = false;
          if (mounted) {
            _fail();
          }
          showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
        })
        .whenComplete(_toggleLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: Stack(
        children: [
          // Warm glow behind the icon.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.65),
                  radius: 0.9,
                  colors: [_gold.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Align(alignment: Alignment.centerLeft, child: _backButton()),
                const SizedBox(height: 28),
                Center(child: _icon()),
                const SizedBox(height: 28),
                Text(
                  'otp'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroyBold,
                    fontSize: 32,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.loginType ? 'loginWithGmail1'.tr : 'otpSubtitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB8B8C0),
                    fontFamily: gilroyRegular,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.loginType
                      ? widget.phoneNumber
                      : '+993 ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _gold,
                    fontFamily: gilroyBold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _shakeOffset,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeOffset.value, 0),
                    child: child,
                  ),
                  child: _codeBoxes(),
                ),
                const SizedBox(height: 18),
                _waitInfo(),
                const SizedBox(height: 26),
                AgreeButton(name: 'agree', onTap: _submit),
                const SizedBox(height: 14),
                _resendButton(),
                const SizedBox(height: 22),
                _terms(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The wait explained, with the clock running down.
  Widget _waitInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedClock01,
            color: _gold,
            size: 20,
            strokeWidth: 1.8,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'otpWaitInfo'.tr,
              style: const TextStyle(
                color: Color(0xFFD0D0D6),
                fontFamily: gilroyMedium,
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resendButton() {
    final ready = _left <= 0;
    return GestureDetector(
      onTap: ready ? _resend : null,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withValues(alpha: ready ? 0.08 : 0.04),
          border: Border.all(
            color: ready
                ? _gold.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: _resending
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: _gold, strokeWidth: 3),
              )
            : Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: ready ? 'otpResend'.tr : '${'otpResendIn'.tr} ',
                      style: TextStyle(
                        color: ready ? _gold : Colors.white38,
                        fontFamily: gilroyBold,
                        fontSize: 15,
                      ),
                    ),
                    if (!ready)
                      TextSpan(
                        text: _clock,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Confirming the code counts as accepting the terms and the privacy policy.
  Widget _terms() {
    Widget link(String text, LegalKind kind) => GestureDetector(
      onTap: () => Get.to(() => LegalPage(kind: kind)),
      child: Text(
        text,
        style: const TextStyle(
          color: _gold,
          fontFamily: gilroySemiBold,
          fontSize: 13.5,
          decoration: TextDecoration.underline,
          decorationColor: _gold,
        ),
      ),
    );
    const plain = TextStyle(
      color: Color(0xFF8E8E98),
      fontFamily: gilroyMedium,
      fontSize: 13.5,
    );
    return Column(
      children: [
        Text('otpTermsLead'.tr, textAlign: TextAlign.center, style: plain),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            link('termsOfUse'.tr, LegalKind.terms),
            Text('andWord'.tr, style: plain),
            link('privacy'.tr, LegalKind.privacy),
          ],
        ),
      ],
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: const Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.white,
            size: 20,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF1B1B1E),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.28), blurRadius: 32),
        ],
      ),
      child: Center(
        child: HugeIcon(
          icon: widget.loginType
              ? HugeIcons.strokeRoundedShieldKey
              : HugeIcons.strokeRoundedSmartPhone01,
          color: _gold,
          size: 44,
          strokeWidth: 1.6,
        ),
      ),
    );
  }

  /// Four boxes drawn over one invisible number field, so the system keyboard,
  /// paste and sms autofill all keep working.
  Widget _codeBoxes() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _focus.requestFocus,
          behavior: HitTestBehavior.opaque,
          child: ListenableBuilder(
            listenable: _focus,
            builder: (context, _) {
              final text = _controller.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _box(
                      i < text.length ? text[i] : '',
                      active:
                          _focus.hasFocus &&
                          i == text.length.clamp(0, _length - 1),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: _length,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enableInteractiveSelection: false,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _box(String digit, {required bool active}) {
    final filled = digit.isNotEmpty;
    final color = _error
        ? Colors.redAccent
        : (active || filled ? _gold : Colors.white.withValues(alpha: 0.14));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 64,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1B1B1E),
        border: Border.all(color: color, width: active || _error ? 2 : 1.4),
        boxShadow: active && !_error
            ? [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 16)]
            : const [],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          digit,
          key: ValueKey(digit),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: gilroyBold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
