import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/user_profil/pages/add_cash.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:game_app/views/wallet/online_add_wallet_money.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String? selectedMethod;
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  Future<void> addMoneyToCARD() async {
    final String? token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/paymentToPoint/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amountController.text,
      }),
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final String formUrl = jsonDecode(response.body)['formUrl'];
      await Get.to(
        () => OnlineAddMoneyToWallet(
          url: formUrl,
          amount: amountController.text,
        ),
      );
    } else {
      showSnackBar('Error', 'Something went wrong', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        backArrow: true,
        fontSize: 0.0,
        iconRemove: false,
        elevationWhite: true,
        name: 'full_balance'.tr,
      ),
      body: Container(
        color: kPrimaryColorBlack,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildMethodSelection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMethodCard(
            number: '1',
            title: 'with_cart'.tr,
            subtitle: 'banc_cart'.tr,
            icon: Icons.credit_card,
            color: kAccentColor,
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
            icon: Icons.smartphone,
            color: kAccentColor,
            onTap: () {
              setState(() => selectedMethod = 'tmcell');
              Get.to(
                () => AskMoneyPage(
                  text: 'message',
                  textSend: 'requestCash'.tr,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCardTopUpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('online_p'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21)),
              const SizedBox(height: 18),
              CustomTextField(
                labelName: 'add_amount'.tr,
                borderRadius: true,
                controller: amountController,
                focusNode: amountFocusNode,
                requestfocusNode: amountFocusNode,
                isNumber: true,
              ),
              const SizedBox(height: 20),
              AgreeButton(
                name: 'pay_m'.tr,
                onTap: () {
                  if (amountController.text.isEmpty) {
                    showSnackBar('Ýalňyşlyk', 'Möçberi giriziň', Colors.red);
                  } else {
                    Get.back(); // close dialog
                    addMoneyToCARD();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    const gold = Color(0xFFFFC83D);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 28, color: gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontFamily: gilroyBold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, fontFamily: gilroyMedium, color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
