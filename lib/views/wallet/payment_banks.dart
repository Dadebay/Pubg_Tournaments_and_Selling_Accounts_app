import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';

/// One bank of the card payment (`GET /payment/banks/`).
class PaymentBank {
  const PaymentBank({
    required this.id,
    required this.nameTm,
    required this.nameRu,
    required this.enabled,
    this.bonus = 0,
  });

  final int id;
  final String nameTm;
  final String nameRu;
  final bool enabled;

  /// The cashback percent of a card top-up with this bank, set by the admin (0: none).
  final int bonus;

  String get name => Get.locale?.languageCode == 'ru' ? nameRu : nameTm;

  factory PaymentBank.fromJson(Map<dynamic, dynamic> json) {
    return PaymentBank(
      id: json['id'] as int,
      nameTm: '${json['name_tm'] ?? ''}',
      nameRu: '${json['name_ru'] ?? ''}',
      enabled: json['enabled'] == true,
      bonus: int.tryParse('${json['bonus']}') ?? 0,
    );
  }
}

/// The answer of a register call: the bank page to open and how to recognise its end.
class CardRegistration {
  const CardRegistration({
    required this.formUrl,
    required this.orderId,
    required this.returnUrl,
    this.bankId,
  });

  final String formUrl;
  final String orderId;

  /// The page the bank sends the user back to; taken from the answer, never hard-coded.
  final String returnUrl;
  final int? bankId;

  static CardRegistration? tryParse(dynamic data) {
    if (data is! Map || data['formUrl'] == null || data['orderId'] == null) {
      return null;
    }
    return CardRegistration(
      formUrl: '${data['formUrl']}',
      orderId: '${data['orderId']}',
      returnUrl: '${data['returnUrl'] ?? ''}',
      bankId: data['bank_id'] is int ? data['bank_id'] as int : null,
    );
  }

  /// True when [url] is the finish page: same host, path starts with the return path (query ignored).
  bool isReturn(String url) {
    if (returnUrl.isEmpty) {
      return false;
    }
    final ret = Uri.tryParse(returnUrl);
    final current = Uri.tryParse(url);
    if (ret == null || current == null) {
      return false;
    }
    return current.host == ret.host && current.path.startsWith(ret.path);
  }
}

class PaymentFlow {
  const PaymentFlow._();

  /// Lets the player choose a bank. The list is loaded every time (a bank is switched on by the
  /// server, with no app update). Every bank of the list is shown, only the `enabled` ones can be
  /// picked. With a single bank in the list its id is returned straight away.
  /// When the list can not be loaded the old behaviour is kept: bank 1 (the server default).
  /// Null means: cancelled, or no bank is enabled. [amount] is only shown in the dialog text.
  static Future<int?> pickBank({int? amount}) async {
    final banks = await _loadBanks();
    if (banks == null) {
      return 1;
    }
    final enabled = banks.where((bank) => bank.enabled).toList();
    if (enabled.isEmpty) {
      showSnackBar('noConnection3', 'bankDisabled', Colors.red);
      return null;
    }
    // The player always chooses among the banks the server sent (a bank that is off is dimmed and
    // can not be picked). Only when the server sent a single bank there is nothing to choose.
    if (banks.length == 1) {
      return enabled.first.id;
    }
    return Get.dialog<int>(_BankDialog(banks: banks, amount: amount));
  }

  /// The best cashback percent among the enabled banks, to tell the player before paying
  /// (0 when there is none or the list can not be loaded). The real bonus is the one the status call answers.
  static Future<int> cashbackPercent() async {
    final banks = await _loadBanks();
    if (banks == null) {
      return 0;
    }
    var best = 0;
    for (final bank in banks) {
      if (bank.enabled && bank.bonus > best) {
        best = bank.bonus;
      }
    }
    return best;
  }

  /// Loads the bank list. The server answers either a plain list or `{"banks": [...]}`;
  /// both are accepted. Null when the call failed or the answer has no list.
  static Future<List<PaymentBank>?> _loadBanks() async {
    final result = await UcdayyApi.getPaymentBanks();
    if (!result.ok) {
      return null;
    }
    var data = result.data;
    if (data is Map) {
      data = data['banks'];
    }
    if (data is! List) {
      return null;
    }
    return [
      for (final item in data)
        if (item is Map) PaymentBank.fromJson(item),
    ];
  }

  /// The translation key of a failed payment call.
  static String errorKey(ApiResult result) {
    final data = result.data;
    if (data is Map && data['code'] == 'bank_disabled') {
      return 'bankDisabled';
    }
    switch (result.statusCode) {
      case 401:
        return 'loginError1';
      case 502:
        return 'paymentGatewayError';
      case 400:
        return result.error == 'Payment is not valid'
            ? 'paymentNotValid'
            : 'tournamentInfo14';
      case 503:
        return 'bankDisabled';
      default:
        return 'tournamentInfo14';
    }
  }

  /// "Payment already used": the order was credited before, so it counts as done.
  static bool alreadyUsed(ApiResult result) =>
      result.statusCode == 400 && result.error == 'Payment already used';
}

/// The logo of a bank (`assets/image/banks`), found by its name because the ids are the server's
/// to reassign; a bank without a file gets a bank icon.
String? _bankLogo(PaymentBank bank) {
  final name = '${bank.nameTm} ${bank.nameRu}'.toLowerCase();
  if (name.contains('halk') || name.contains('халк')) {
    return 'assets/image/banks/halk.png';
  }
  if (name.contains('rysgal') || name.contains('рысгал')) {
    return 'assets/image/banks/rysgal.png';
  }
  return null;
}

const _gold = Color(0xFFFFC83D);

/// "Pay by bank card": the enabled banks with their logos, one is selected, then "Continue".
class _BankDialog extends StatefulWidget {
  const _BankDialog({required this.banks, this.amount});

  final List<PaymentBank> banks;
  final int? amount;

  @override
  State<_BankDialog> createState() => _BankDialogState();
}

class _BankDialogState extends State<_BankDialog> {
  late int _selected = widget.banks.firstWhere((bank) => bank.enabled).id;

  Widget _logo(PaymentBank bank) {
    final path = _bankLogo(bank);
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: path == null
          ? const Icon(
              Icons.account_balance_rounded,
              color: Color(0xFFD32F2F),
              size: 26,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(path, fit: BoxFit.contain),
            ),
    );
  }

  /// A bank row. One that is not on yet is dimmed, marked "soon" and does not react to a tap.
  Widget _bankTile(PaymentBank bank) {
    final on = bank.enabled;
    final selected = on && _selected == bank.id;
    return GestureDetector(
      onTap: on ? () => setState(() => _selected = bank.id) : null,
      child: Opacity(
        opacity: on ? 1 : 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: selected ? 0.09 : 0.04),
            border: Border.all(
              color: selected ? _gold : Colors.white.withValues(alpha: 0.08),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _logo(bank),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  bank.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroySemiBold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (on && bank.bonus > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(8)),
                  child: Text('+${bank.bonus}%', style: const TextStyle(color: Color(0xFF111111), fontFamily: gilroyBold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
              ],
              if (on)
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? _gold : Colors.white38,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    'bankSoon'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: gilroySemiBold,
                      fontSize: 11.5,
                      height: 1.1,
                    ),
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
    final amount = widget.amount;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.size.height * 0.9),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _gold.withValues(alpha: 0.3)),
          color: const Color(0xFF1B1B1F),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_rounded, color: _gold, size: 34),
              const SizedBox(height: 12),
              Text(
                'payByCard'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: gilroyBold,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amount == null
                    ? 'chooseBank'.tr
                    : 'chooseBankFor'.trParams({'amount': '$amount'}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontFamily: gilroyMedium,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              for (final bank in widget.banks) _bankTile(bank),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Get.back(result: _selected),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _gold,
                  ),
                  child: Text(
                    'continuePayment'.tr,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: gilroyBold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontFamily: gilroySemiBold,
                    fontSize: 15,
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
