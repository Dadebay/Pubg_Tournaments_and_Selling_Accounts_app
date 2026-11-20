import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../constants/index.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

String _priceText(String? price) {
  final value = double.tryParse('$price');
  if (value == null) {
    return '$price';
  }
  return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(2);
}

/// The bar fixed at the bottom of an account page: the price and the buy button.
class AccountBuyBar extends StatelessWidget {
  const AccountBuyBar({required this.model, super.key});

  final GetPostsAccountModel model;

  Future<void> _buy(BuildContext context) async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      showSnackBar('loginError', 'loginError1', Colors.red);
      return;
    }
    if (!context.mounted) {
      return;
    }
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => BuyAccountDialog(model: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: const Color(0xF2131315),
        border: Border(top: BorderSide(color: _gold.withValues(alpha: 0.25))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/image/coin_stack.webp',
            height: 40,
            errorBuilder: (context, error, stackTrace) => const HugeIcon(icon: HugeIcons.strokeRoundedCoins01, color: _gold, size: 34, strokeWidth: 1.8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: _priceText(model.price),
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 30, height: 1),
                  children: const [
                    TextSpan(
                      text: '  TMT',
                      style: TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            // A sold account can not be bought again.
            onTap: model.sold ? null : () => _buy(context),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 26),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: model.sold ? Colors.white.withValues(alpha: 0.12) : null,
                gradient: model.sold ? null : const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                boxShadow: model.sold ? null : [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 5))],
              ),
              child: Text(
                model.sold ? 'accountSoldBadge'.tr : 'accountBuy'.tr,
                style: TextStyle(color: model.sold ? Colors.white54 : const Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Buying an account with the wallet balance: the price against the balance and the
/// two things the seller needs, the buyer's Gmail and PUBG id.
class BuyAccountDialog extends StatefulWidget {
  const BuyAccountDialog({required this.model, super.key});

  final GetPostsAccountModel model;

  @override
  State<BuyAccountDialog> createState() => _BuyAccountDialogState();
}

class _BuyAccountDialogState extends State<BuyAccountDialog> {
  final _gmail = TextEditingController();
  final _pubgId = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final WalletController _wallet = Get.find<WalletController>();
  bool _busy = false;
  String? _error;

  double get _price => double.tryParse('${widget.model.price}') ?? 0;
  double get _balance => double.tryParse(_wallet.userMoney.value) ?? 0;

  @override
  void initState() {
    super.initState();
    _wallet.getUserMoney();
    _prefill();
  }

  /// The player's own e-mail and PUBG id, so most of the time they only press the button.
  Future<void> _prefill() async {
    final result = await UcdayyApi.getMyAccount();
    final data = result.data;
    if (!mounted || !result.ok || data is! Map) {
      return;
    }
    final email = '${data['email'] ?? ''}';
    final pubg = '${data['pubg_id'] ?? ''}';
    if (_gmail.text.isEmpty && email.contains('@')) {
      _gmail.text = email;
    }
    if (_pubgId.text.isEmpty && pubg.isNotEmpty && pubg != 'null') {
      _pubgId.text = pubg;
    }
  }

  @override
  void dispose() {
    _gmail.dispose();
    _pubgId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_balance < _price) {
      Get.back();
      await Get.to(() => const TopUpScreen());
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await UcdayyApi.buyAccountPost(widget.model.id!, gmail: _gmail.text.trim(), pubgId: _pubgId.text.trim());
    if (!mounted) {
      return;
    }
    if (result.ok) {
      final data = result.data;
      final newBalance = data is Map ? (data['balance'] ?? data['points_balance']) : null;
      if (newBalance != null) {
        _wallet.setMoneyFromPoints('$newBalance');
      } else {
        _wallet.getUserMoney();
      }
      Get.back();
      await showDialog(context: Get.context!, barrierColor: Colors.black.withValues(alpha: 0.75), builder: (context) => const _DoneDialog());
      return;
    }
    final code = result.data is Map ? result.data['code'] : null;
    if (code == 'not_enough_money') {
      // The balance on the screen was old: offer the top-up.
      _wallet.getUserMoney();
      Get.back();
      await Get.to(() => const TopUpScreen());
      return;
    }
    setState(() {
      _busy = false;
      _error = code == 'already_sold' || result.statusCode == 409 ? 'accountBuySold'.tr : (result.error ?? 'accountBuyFailed'.tr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.size.height * 0.88),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _gold.withValues(alpha: 0.35)),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF131315)]),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.15), blurRadius: 36)],
        ),
        child: SingleChildScrollView(
          child: Obx(() {
            final enough = (double.tryParse(_wallet.userMoney.value) ?? 0) >= _price;
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.14),
                      border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: _gold, size: 30, strokeWidth: 1.8),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'accountBuyTitle'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  _summary(enough),
                  const SizedBox(height: 16),
                  _field(
                    controller: _gmail,
                    label: 'accountBuyGmail'.tr,
                    icon: HugeIcons.strokeRoundedMail01,
                    keyboard: TextInputType.emailAddress,
                    validator: (value) => RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch((value ?? '').trim()) ? null : 'accountBuyInvalidEmail'.tr,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'accountBuyGmailHint'.tr,
                        style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12),
                      ),
                    ),
                  ),
                  _field(
                    controller: _pubgId,
                    label: 'Pubg ID',
                    icon: HugeIcons.strokeRoundedIdentityCard,
                    keyboard: TextInputType.number,
                    digitsOnly: true,
                    validator: (value) => (value ?? '').trim().length >= 5 ? null : 'accountBuyInvalidId'.tr,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFF6B6B), fontFamily: gilroySemiBold, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _busy ? null : _submit,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: _busy
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                          : Text(
                              enough ? '${'accountBuy'.tr}  ·  ${_priceText(widget.model.price)} TMT' : 'add_monay'.tr,
                              style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : Get.back,
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Price, the balance and what is left, with a red warning when the money is not enough.
  Widget _summary(bool enough) {
    final balance = double.tryParse(_wallet.userMoney.value) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          _row('accountDetaile5'.tr, '${_priceText(widget.model.price)} TMT', highlight: true),
          _row('balance'.tr, '${_priceText('$balance')} TMT', last: enough, danger: !enough),
          if (!enough) _row('', 'accountBuyNotEnough'.tr, last: true, danger: true, wide: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false, bool last = false, bool danger = false, bool wide = false}) {
    final color = danger ? const Color(0xFFFF6B6B) : (highlight ? _gold : Colors.white);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          if (label.isNotEmpty)
            Text(
              label.replaceAll(':', '').trim(),
              style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 14),
            ),
          if (label.isNotEmpty) const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: wide ? TextAlign.center : TextAlign.end,
              style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: wide ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required List<List<dynamic>> icon,
    required TextInputType keyboard,
    required String? Function(String?) validator,
    bool digitsOnly = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1.3]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      cursorColor: _gold,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyMedium, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: _gold, fontFamily: gilroySemiBold),
        errorStyle: const TextStyle(fontFamily: gilroyMedium),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: HugeIcon(icon: icon, color: Colors.white.withValues(alpha: 0.5), size: 22, strokeWidth: 1.6),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        enabledBorder: border(Colors.white.withValues(alpha: 0.14)),
        focusedBorder: border(_gold, 1.8),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.8),
      ),
    );
  }
}

class _DoneDialog extends StatelessWidget {
  const _DoneDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _gold.withValues(alpha: 0.4)),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF131315)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.6), width: 2),
              ),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: Color(0xFF34D399), size: 40, strokeWidth: 2.4),
            ),
            const SizedBox(height: 18),
            Text(
              'accountBuyDone'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'accountBuyDoneText'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 15, height: 1.3),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.back();
              },
              child: Container(
                height: 54,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                ),
                child: Text(
                  'luckyOk'.tr,
                  style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
