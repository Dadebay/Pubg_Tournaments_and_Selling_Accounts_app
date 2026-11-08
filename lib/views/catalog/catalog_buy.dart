import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/catalog_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/catalog/game_orders_page.dart';
import 'package:game_app/views/catalog/gift_codes_page.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

/// Opens the buy dialog of [product]; true when the purchase went through.
Future<bool> showCatalogBuy(BuildContext context, {required String kind, required CatalogProduct product}) async {
  final token = await Auth().getToken();
  if (token == null || token.isEmpty) {
    showSnackBar('loginError', 'loginError1', Colors.red);
    return false;
  }
  if (!context.mounted) {
    return false;
  }
  final bought = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) => CatalogBuyDialog(kind: kind, product: product),
  );
  return bought == true;
}

/// Pays one product from the balance. Games and programs ask the buyer one thing
/// (`asking`) and send the answer with the order; gift cards have a quantity
/// limited by the codes in stock.
class CatalogBuyDialog extends StatefulWidget {
  const CatalogBuyDialog({required this.kind, required this.product, super.key});

  final String kind;
  final CatalogProduct product;

  @override
  State<CatalogBuyDialog> createState() => _CatalogBuyDialogState();
}

class _CatalogBuyDialogState extends State<CatalogBuyDialog> {
  final _answer = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final WalletController _wallet = Get.find<WalletController>();
  int _count = 1;
  bool _busy = false;
  String? _error;

  bool get _gift => widget.kind == 'gift';
  double get _total => widget.product.price * _count;
  int get _max => _gift ? (widget.product.inStock ?? 1).clamp(1, 99) : 1;

  @override
  void initState() {
    super.initState();
    _wallet.getUserMoney();
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  /// The server's message in the app language (`message_tm` / `message_ru`), else its `error` text.
  String _serverMessage(dynamic data, String? fallback) {
    if (data is Map) {
      final ru = Get.locale?.languageCode == 'ru';
      final message = data[ru ? 'message_ru' : 'message_tm'] ?? data['message_tm'] ?? data['message_ru'];
      if (message != null && '$message'.isNotEmpty) {
        return '$message';
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return fallback ?? 'accountBuyFailed'.tr;
  }

  Future<void> _submit() async {
    final balance = double.tryParse(_wallet.userMoney.value) ?? 0;
    if (balance < _total) {
      Navigator.pop(context, false);
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
    final line = <String, Object?>{'id': widget.product.id, 'count': _count, 'status': _gift ? 'gift' : 'thing'};
    if (!_gift) {
      line['asking'] = _answer.text.trim();
    }
    final result = await UcdayyApi.payFromBalance([line]);
    if (!mounted) {
      return;
    }
    final data = result.data;
    if (result.ok && (data is! Map || data['success'] != false)) {
      _wallet.getUserMoney();
      Navigator.pop(context, true);
      await _showDone();
      return;
    }
    setState(() => _busy = false);
    if (data is Map && data['code'] == 'not_enough_codes') {
      // Someone bought codes meanwhile: lower the quantity to what is left.
      final available = int.tryParse('${data['available']}') ?? 0;
      if (available <= 0) {
        Navigator.pop(context, true);
        showSnackBar('catalogOutOfStock', _serverMessage(data, null), Colors.red);
        return;
      }
      setState(() {
        _count = available;
        _error = _serverMessage(data, null);
      });
      return;
    }
    final text = data is Map ? '${data['error']}' : '';
    if (result.statusCode == 404 || text.contains('not found') || text.contains('No Gifts')) {
      Navigator.pop(context, true);
      showSnackBar('catalogGone', 'catalogGone', Colors.red);
      return;
    }
    if (data is Map && data['error'] == true) {
      // `{"error": true, "message": "User has not enough money to buy"}`
      setState(() => _error = 'accountBuyNotEnough'.tr);
      _wallet.getUserMoney();
      return;
    }
    setState(() => _error = _serverMessage(data, result.error));
  }

  Future<void> _showDone() {
    final gift = _gift;
    return showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: catalogGold.withValues(alpha: 0.4)),
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
              const SizedBox(height: 20),
              CatalogGoldButton(
                label: (gift ? 'catalogMyCodes' : 'orders').tr,
                onTap: () {
                  Get.back();
                  Get.to(() => gift ? const GiftCodesPage() : const GameOrdersPage());
                },
              ),
              TextButton(
                onPressed: Get.back,
                child: Text(
                  'luckyOk'.tr,
                  style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.size.height * 0.88),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: catalogGold.withValues(alpha: 0.35)),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF131315)]),
          boxShadow: [BoxShadow(color: catalogGold.withValues(alpha: 0.15), blurRadius: 36)],
        ),
        child: SingleChildScrollView(
          child: Obx(() {
            final balance = double.tryParse(_wallet.userMoney.value) ?? 0;
            final enough = balance >= _total;
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(width: 64, height: 64, child: CatalogImage(url: product.image)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 19, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_gift && product.asking.isNotEmpty) ...[_askingField(product.asking), const SizedBox(height: 14)],
                  if (_gift) ...[_stepper(), const SizedBox(height: 14)],
                  _summary(balance, enough),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFF6B6B), fontFamily: gilroySemiBold, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  CatalogGoldButton(label: enough ? '${'accountBuy'.tr}  ·  ${catalogMoney(_total)} TMT' : 'add_monay'.tr, onTap: _submit, busy: _busy, height: 56),
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context, false),
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

  Widget _askingField(String label) {
    OutlineInputBorder border(Color color, [double width = 1.3]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
    return TextFormField(
      controller: _answer,
      maxLength: 300,
      maxLines: 1,
      cursorColor: catalogGold,
      style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
      validator: (value) => (value ?? '').trim().isEmpty ? '${'errorEmpty'.tr}: $label' : null,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontFamily: gilroyMedium, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: catalogGold, fontFamily: gilroySemiBold),
        errorStyle: const TextStyle(fontFamily: gilroyMedium),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
        enabledBorder: border(Colors.white.withValues(alpha: 0.14)),
        focusedBorder: border(catalogGold, 1.8),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.8),
      ),
    );
  }

  Widget _stepper() {
    Widget button(IconData icon, VoidCallback? onTap) => GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            'catalogQty'.tr,
            style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 15),
          ),
        ),
        button(Icons.remove, _count > 1 ? () => setState(() => _count--) : null),
        SizedBox(
          width: 48,
          child: Text(
            '$_count',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
          ),
        ),
        button(Icons.add, _count < _max ? () => setState(() => _count++) : null),
      ],
    );
  }

  Widget _summary(double balance, bool enough) {
    Widget row(String label, String value, {bool highlight = false, bool danger = false, bool last = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
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
              style: TextStyle(color: danger ? const Color(0xFFFF6B6B) : (highlight ? catalogGold : Colors.white), fontFamily: gilroyBold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          row('catalogTotal'.tr, '${catalogMoney(_total)} TMT', highlight: true),
          row('balance'.tr, '${catalogMoney(balance)} TMT', danger: !enough, last: enough),
          if (!enough) row('', 'accountBuyNotEnough'.tr, danger: true, last: true),
        ],
      ),
    );
  }
}
