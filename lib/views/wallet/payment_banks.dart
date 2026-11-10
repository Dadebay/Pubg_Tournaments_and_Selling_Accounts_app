import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';

/// One bank of the card payment (`GET /payment/banks/`).
class PaymentBank {
  const PaymentBank({required this.id, required this.nameTm, required this.nameRu, required this.enabled});

  final int id;
  final String nameTm;
  final String nameRu;
  final bool enabled;

  String get name => Get.locale?.languageCode == 'ru' ? nameRu : nameTm;

  factory PaymentBank.fromJson(Map<dynamic, dynamic> json) {
    return PaymentBank(id: json['id'] as int, nameTm: '${json['name_tm'] ?? ''}', nameRu: '${json['name_ru'] ?? ''}', enabled: json['enabled'] == true);
  }
}

/// The answer of a register call: the bank page to open and how to recognise its end.
class CardRegistration {
  const CardRegistration({required this.formUrl, required this.orderId, required this.returnUrl, this.bankId});

  final String formUrl;
  final String orderId;

  /// The page the bank sends the user back to; taken from the answer, never hard-coded.
  final String returnUrl;
  final int? bankId;

  static CardRegistration? tryParse(dynamic data) {
    if (data is! Map || data['formUrl'] == null || data['orderId'] == null) {
      return null;
    }
    return CardRegistration(formUrl: '${data['formUrl']}', orderId: '${data['orderId']}', returnUrl: '${data['returnUrl'] ?? ''}', bankId: data['bank_id'] is int ? data['bank_id'] as int : null);
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
  /// server, with no app update). With one enabled bank there is no choice screen.
  /// When the list can not be loaded the old behaviour is kept: bank 1 (the server default).
  /// Null means: cancelled, or no bank is enabled.
  static Future<int?> pickBank() async {
    final result = await UcdayyApi.getPaymentBanks();
    final data = result.data;
    if (!result.ok || data is! List) {
      return 1;
    }
    final banks = [
      for (final item in data)
        if (item is Map && PaymentBank.fromJson(item).enabled) PaymentBank.fromJson(item),
    ];
    if (banks.isEmpty) {
      showSnackBar('noConnection3', 'bankDisabled', Colors.red);
      return null;
    }
    if (banks.length == 1) {
      return banks.first.id;
    }
    return Get.bottomSheet<int>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'chooseBank'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21),
              ),
              const SizedBox(height: 16),
              for (final bank in banks)
                GestureDetector(
                  onTap: () => Get.back(result: bank.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: Color(0xFFFFC83D)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            bank.name,
                            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 17),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
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
        return result.error == 'Payment is not valid' ? 'paymentNotValid' : 'tournamentInfo14';
      case 503:
        return 'bankDisabled';
      default:
        return 'tournamentInfo14';
    }
  }

  /// "Payment already used": the order was credited before, so it counts as done.
  static bool alreadyUsed(ApiResult result) => result.statusCode == 400 && result.error == 'Payment already used';
}
