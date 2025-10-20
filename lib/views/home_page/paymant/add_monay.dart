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
      appBar:  MyAppBar(
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
      AlertDialog(
        backgroundColor: kPrimaryColorBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:  Text(
          'online_p'.tr,
          style:const TextStyle(
            color: Colors.white,
            fontFamily: josefinSansSemiBold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
