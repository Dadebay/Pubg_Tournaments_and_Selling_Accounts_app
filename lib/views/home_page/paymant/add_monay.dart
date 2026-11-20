import 'package:game_app/views/constants/index.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/wallet/online_add_wallet_money.dart';
import 'package:game_app/views/wallet/payment_banks.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:game_app/views/wallet/phone_topup_page.dart';
import 'package:hugeicons/hugeicons.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String? selectedMethod;
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  final TextEditingController terminalAmountController = TextEditingController();
  final FocusNode terminalAmountFocusNode = FocusNode();

  /// The cashback percent of a card top-up (`bonus` of `GET /payment/banks/`), 0 until loaded or when off.
  int _cashback = 0;

  @override
  void initState() {
    super.initState();
    _loadCashback();
  }

  Future<void> _loadCashback() async {
    final percent = await PaymentFlow.cashbackPercent();
    if (mounted && percent != _cashback) {
      setState(() => _cashback = percent);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    terminalAmountController.dispose();
    terminalAmountFocusNode.dispose();
    super.dispose();
  }

  /// "+99362222307" -> "+993 62 22 23 07".
  String _prettyPhone(String full) {
    final digits = full.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('993')) {
      final r = digits.substring(3);
      return '+993 ${r.substring(0, 2)} ${r.substring(2, 4)} ${r.substring(4, 6)} ${r.substring(6)}';
    }
    return full;
  }

  /// The number is the same SIM number the TMCell page shows (the one with the most transfers left).
  /// It is shown with the instruction: send the amount to it, then send the receipt to the chat.
  Future<void> _payByTerminal() async {
    final amount = int.tryParse(terminalAmountController.text.trim());
    if (amount == null || amount < 1) {
      showSnackBar('Ýalňyşlyk', 'phoneTopUpAmountError', Colors.red);
      return;
    }
    final result = await UcdayyApi.getPhoneTopUpNumbers();
    final data = result.data;
    String phone = '';
    if (result.ok && data is List) {
      final items = data.whereType<Map>().toList()..sort((x, y) => (int.tryParse('${y['left_today']}') ?? 0).compareTo(int.tryParse('${x['left_today']}') ?? 0));
      if (items.isNotEmpty) {
        phone = '${items.first['phone_full'] ?? items.first['phone'] ?? ''}'.trim();
      }
    }
    if (phone.isEmpty || phone == 'null') {
      showSnackBar('noConnection3', 'phoneTopUpNone', Colors.red);
      return;
    }
    terminalAmountController.clear();
    _showTerminalInstruction(amount, _prettyPhone(phone));
  }

  /// "Send this amount to this number, then send the receipt picture to the chat."
  void _showTerminalInstruction(int amount, String phone) {
    const color = Color(0xFF7CE38B);
    Widget step(String n, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
            child: Text(n, style: const TextStyle(color: color, fontFamily: gilroyBold, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFFE6E6EA), fontFamily: gilroyMedium, fontSize: 14.5, height: 1.35)),
          ),
        ],
      ),
    );
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: const Color(0xFF1B1B1F), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: color.withValues(alpha: 0.16)),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedAtm01, color: color, size: 24, strokeWidth: 1.8),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('terminalTitle'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 19)),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close_rounded, size: 22, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('phoneTopUpSendTo'.tr, style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12.5)),
                          const SizedBox(height: 4),
                          Text(phone, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22)),
                          const SizedBox(height: 4),
                          Text('$amount TMT', style: const TextStyle(color: color, fontFamily: gilroyBold, fontSize: 18)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: phone.replaceAll(' ', '')));
                        showSnackBar('copySucces', 'phoneTopUpCopied', Colors.green);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.16)),
                        child: const Icon(Icons.copy_rounded, size: 19, color: color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              step('1', 'terminalStep1'.trParams({'amount': '$amount', 'phone': phone})),
              step('2', 'terminalStep2'.tr),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Get.back(); // close dialog
                  Get.to(() => SupportChatPage(initialText: 'terminalChatMessage'.trParams({'amount': '$amount', 'phone': phone})));
                },
                child: Container(
                  height: 54,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color),
                  child: Text('terminalOpenChat'.tr, style: const TextStyle(color: Color(0xFF111111), fontFamily: gilroyBold, fontSize: 16.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTerminalDialog() {
    _showAmountDialog(
      title: 'terminalTitle'.tr,
      hint: 'terminalHint'.tr,
      icon: HugeIcons.strokeRoundedAtm01,
      color: const Color(0xFF7CE38B),
      controller: terminalAmountController,
      focusNode: terminalAmountFocusNode,
      buttonLabel: 'terminalContinue'.tr,
      onSubmit: _payByTerminal,
    );
  }

  Future<void> addMoneyToCARD() async {
    final amount = int.tryParse(amountController.text.trim());
    if (amount == null || amount < 1 || amount > 100000) {
      showSnackBar('Ýalňyşlyk', 'Möçberi giriziň', Colors.red);
      return;
    }
    final bankId = await PaymentFlow.pickBank(amount: amount);
    if (bankId == null) {
      return;
    }
    final result = await UcdayyApi.registerCardTopUp(amount: amount, bankId: bankId);
    final registration = result.ok ? CardRegistration.tryParse(result.data) : null;
    if (registration == null) {
      showSnackBar('Error', PaymentFlow.errorKey(result), Colors.red);
      return;
    }
    await Get.to(() => OnlineAddMoneyToWallet(registration: registration, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        child: Column(
          children: [
            CenteredHeader(title: 'full_balance'.tr, onBack: Get.back),
            Expanded(child: _buildMethodSelection()),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          _buildMethodCard(
            number: '1',
            title: 'with_cart'.tr,
            subtitle: 'banc_cart'.tr,
            badge: _cashback > 0 ? '+$_cashback%' : null,
            icon: HugeIcons.strokeRoundedCreditCard,
            color: const Color(0xFFFFC83D),
            onTap: () {
              setState(() => selectedMethod = 'card');
              _showCardTopUpDialog();
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            number: '2',
            title: 'tmcell'.tr,
            subtitle: 'phone_b'.tr,
            icon: HugeIcons.strokeRoundedSmartPhone01,
            color: const Color(0xFF4CC9F0),
            onTap: () {
              setState(() => selectedMethod = 'tmcell');
              Get.to(() => const PhoneTopUpPage());
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            number: '3',
            title: 'terminalTitle'.tr,
            subtitle: 'terminalSub'.tr,
            icon: HugeIcons.strokeRoundedAtm01,
            color: const Color(0xFF7CE38B),
            onTap: () {
              setState(() => selectedMethod = 'terminal');
              _showTerminalDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCardTopUpDialog() async {
    // Asked again so a change of the admin shows up without leaving the page.
    final percent = await PaymentFlow.cashbackPercent();
    if (percent > 0 && percent != _cashback && mounted) {
      setState(() => _cashback = percent);
    }
    final shown = percent > 0 ? percent : _cashback;
    _showAmountDialog(
      cashbackPercent: shown,
      title: 'online_p'.tr,
      hint: 'banc_cart'.tr,
      icon: HugeIcons.strokeRoundedCreditCard,
      color: const Color(0xFFFFC83D),
      controller: amountController,
      focusNode: amountFocusNode,
      buttonLabel: 'pay_m'.tr,
      onSubmit: addMoneyToCARD,
    );
  }

  /// One dialog for both ways: an icon, the title, the amount field with quick amounts and one button.
  void _showAmountDialog({
    required String title,
    required String hint,
    required List<List<dynamic>> icon,
    required Color color,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String buttonLabel,
    required VoidCallback onSubmit,
    int cashbackPercent = 0,
  }) {
    const quick = [10, 20, 50, 100];
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: const Color(0xFF1B1B1F),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: color.withValues(alpha: 0.16)),
                    child: HugeIcon(icon: icon, color: color, size: 24, strokeWidth: 1.8),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 19)),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close_rounded, size: 22, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(hint, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroyMedium, fontSize: 13.5, height: 1.35)),
              if (cashbackPercent > 0) ...[
                const SizedBox(height: 12),
                // Follows the amount: "50 TMT -> you get 1 TMT back"; below the size where it rounds to 0 only the percent is told.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final amount = int.tryParse(value.text.trim()) ?? 0;
                    final back = (amount * cashbackPercent / 100).round();
                    final text = back > 0 ? 'cashbackAmount'.trParams({'amount': '$back', 'percent': '$cashbackPercent'}) : 'cashbackNote'.trParams({'percent': '$cashbackPercent'});
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedCoins01, color: color, size: 18, strokeWidth: 1.8),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(text, style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 13.5)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  cursorColor: color,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'add_amount'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6E6E76), fontFamily: gilroyMedium, fontSize: 16),
                    suffixText: 'TMT',
                    suffixStyle: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyBold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final value in quick)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: value == quick.last ? 0 : 8),
                        child: GestureDetector(
                          onTap: () => controller.text = '$value',
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.35))),
                            child: Text('$value', style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 14.5)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  if (controller.text.trim().isEmpty) {
                    showSnackBar('Ýalňyşlyk', 'phoneTopUpAmountError', Colors.red);
                    return;
                  }
                  Get.back(); // close dialog
                  onSubmit();
                },
                child: Container(
                  height: 54,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color),
                  child: Text(buttonLabel, style: const TextStyle(color: Color(0xFF111111), fontFamily: gilroyBold, fontSize: 16.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({required String number, required String title, required String subtitle, required List<List<dynamic>> icon, required Color color, required VoidCallback onTap, String? badge}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: color.withValues(alpha: 0.12),
        highlightColor: color.withValues(alpha: 0.06),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // One flat surface: the method colour mixed into the dark base, no gradient.
            color: Color.alphaBlend(color.withValues(alpha: 0.07), const Color(0xFF131315)),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: color.withValues(alpha: 0.16),
                ),
                child: HugeIcon(icon: icon, color: color, size: 30, strokeWidth: 1.8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, fontFamily: gilroyBold, color: Colors.white),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                            child: Text(badge, style: const TextStyle(fontSize: 12.5, fontFamily: gilroyBold, color: Color(0xFF111111))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, height: 1.25, fontFamily: gilroyMedium, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
                child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: color, size: 18, strokeWidth: 2.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
