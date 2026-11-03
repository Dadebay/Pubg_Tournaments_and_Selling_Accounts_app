// ignore_for_file: file_names

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:hugeicons/hugeicons.dart';

import '../cards/order_card.dart';
import '../constants/index.dart';

/// The cart before paying: its lines, the PUBG id they are sent to and a bottom
/// panel with the total, the balance and the pay button.
class OrderPage extends StatefulWidget {
  final String pubgID;
  final String asking;
  final bool onlyCard;
  const OrderPage({required this.pubgID, required this.onlyCard, required this.asking, super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _gold = Color(0xFFFFC83D);

  final WalletController walletController = Get.put(WalletController());

  /// A payment request is running; the pay button shows a spinner and ignores taps.
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    walletController.getUserMoney();
  }

  /// The API sends absolute image urls; older answers sent a path on our server.
  String _imageUrl(String image) => image.startsWith('http') ? image : '$serverURL$image';

  String _money(double value) => '${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(2)} TMT';

  double get _total {
    var total = 0.0;
    for (final item in walletController.cartList) {
      total += (double.tryParse('${item['price']}') ?? 0) * (item['count'] as int);
    }
    return total;
  }

  double get _balance => double.tryParse(walletController.userMoney.toString()) ?? 0;

  Future<void> _payWithBalance() async {
    if (_paying) {
      return;
    }
    final token = await Auth().getToken();
    if (token == null) {
      showSnackBar('loginError', 'loginError1', Colors.red);
      return;
    }
    if (_balance <= 0) {
      showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
      return;
    }
    final List list = [];
    for (final element in walletController.cartList) {
      if (element['status'] == 'thing') {
        list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'asking': widget.pubgID});
      } else if (element['status'] == 'gift') {
        list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': 'gift'});
      } else {
        list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': widget.pubgID});
      }
    }
    setState(() => _paying = true);
    final value = await UcModel().addCart(list, pubgId: widget.pubgID);
    if (mounted) {
      setState(() => _paying = false);
    }
    if (value == 200 || value == 201) {
      final total = _money(_total);
      walletController.cartList.clear();
      walletController.cartList.refresh();
      walletController.getUserMoney();
      if (mounted) {
        await _showAcceptedDialog(total);
      }
      // Closes the order page and the PUBG id dialog under it.
      Get.back();
      Get.back();
    } else if (value == 404) {
      showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
    } else {
      showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
      if (mounted) {
        await _showNoMoneyDialog();
      }
    }
  }

  /// Tells the order was accepted and that an operator will get in touch.
  Future<void> _showAcceptedDialog(String total) {
    const green = Color(0xFF34D399);
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF16261F), Color(0xFF131315)]),
              border: Border.all(color: green.withValues(alpha: 0.35)),
              boxShadow: [BoxShadow(color: green.withValues(alpha: 0.2), blurRadius: 44)],
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
                      color: green.withValues(alpha: 0.14),
                      border: Border.all(color: green.withValues(alpha: 0.5), width: 2),
                      boxShadow: [BoxShadow(color: green.withValues(alpha: 0.35), blurRadius: 30)],
                    ),
                    child: const Center(child: Icon(Icons.check_rounded, color: green, size: 54)),
                  ),
                ),
                const SizedBox(height: 22),
                Text('orderAcceptedTitle'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 24, height: 1.2)),
                const SizedBox(height: 10),
                Text('orderAcceptedDescription'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 16, height: 1.35)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      _summaryRow(widget.asking.tr, widget.pubgID.tr, Colors.white),
                      const SizedBox(height: 10),
                      _summaryRow('orderPage3'.tr, total, _gold),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                      boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Text('orderAcceptedButton'.tr, style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 14)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: valueColor, fontFamily: gilroyBold, fontSize: 17)),
        ),
      ],
    );
  }

  Future<void> _showNoMoneyDialog() {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF26231C), Color(0xFF131315)]),
            border: Border.all(color: _gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: _gold.withValues(alpha: 0.12), border: Border.all(color: _gold.withValues(alpha: 0.4))),
                child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: _gold, size: 34, strokeWidth: 1.6)),
              ),
              const SizedBox(height: 18),
              Text('not_monay'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22, height: 1.2)),
              const SizedBox(height: 10),
              Text('Dowam etmek üçin balansy dolduryň'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 15)),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TopUpScreen()));
                },
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)])),
                  child: Text('add_monay'.tr, style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44), foregroundColor: Colors.white70),
                child: Text('cancel'.tr, style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Obx(() {
                if (walletController.cartList.isEmpty) {
                  return noData('Sargyt zat yok');
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    for (final item in walletController.cartList)
                      OrderCard(
                        key: ValueKey(item['id']),
                        id: item['id'],
                        image: _imageUrl('${item['image']}'),
                        title: item['name'] ?? 'Pubg UC',
                        price: item['price'].toString(),
                        count: item['count'],
                        status: item['status'] ?? 'thing',
                      ),
                    _idCard(),
                  ],
                );
              }),
            ),
            _payPanel(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06), border: Border.all(color: Colors.white.withValues(alpha: 0.14))),
              child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, size: 20, strokeWidth: 2)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('orderPage'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 28)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF1B1B1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: _gold, size: 20, strokeWidth: 1.6),
                const SizedBox(width: 8),
                Obx(() => Text(_balance.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Where the order is sent to.
  Widget _idCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF17130C),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _gold.withValues(alpha: 0.12)),
            child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedGameController03, color: _gold, size: 24, strokeWidth: 1.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.asking.tr, style: const TextStyle(color: Color(0xFFC9BFA8), fontFamily: gilroyMedium, fontSize: 13)),
                const SizedBox(height: 2),
                Text(widget.pubgID.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _payPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 24, offset: const Offset(0, -8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final total = _total;
            final short = _balance < total;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('orderPage3'.tr, style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 16)),
                    Text(_money(total), style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 26)),
                  ],
                ),
                if (short && walletController.cartList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, color: Colors.redAccent, size: 16, strokeWidth: 1.8),
                      const SizedBox(width: 6),
                      Expanded(child: Text('not_monay'.tr, style: const TextStyle(color: Colors.redAccent, fontFamily: gilroyMedium, fontSize: 13))),
                    ],
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final empty = walletController.cartList.isEmpty;
            return GestureDetector(
              onTap: empty ? null : _payWithBalance,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: empty ? 0.4 : 1,
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                    boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: _paying
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.6, color: Color(0xFF1A1200)))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: Color(0xFF1A1200), size: 22, strokeWidth: 2),
                            const SizedBox(width: 10),
                            Text('balance'.tr, style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 18)),
                          ],
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
