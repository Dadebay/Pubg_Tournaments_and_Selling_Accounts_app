import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:game_app/bottom_nav_bar.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class OnlineAddMoneyToWallet extends StatefulWidget {
  const OnlineAddMoneyToWallet({
    required this.url,
    required this.amount,
    super.key,
  });
  final String url;
  final String amount;
  @override
  State<OnlineAddMoneyToWallet> createState() => _OnlineAddMoneyToWalletState();
}

class _OnlineAddMoneyToWalletState extends State<OnlineAddMoneyToWallet> {
  late WebViewController _controller;
  final WalletController walletController = Get.put(WalletController());
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _controller.runJavaScriptReturningResult('document.body.innerText').then((result) async {
              // Assuming the JSON data is in the body text
              try {
                // Log the type of result to understand its structure

                // Attempt to decode the JSON
                // ignore: unused_local_variable
                final jsonData = jsonDecode(result.toString());

                // Extract orderId from the URL
                final Uri uri = Uri.parse(url);
                final String? orderId = uri.queryParameters['orderId'];
                final String? token = await Auth().getToken();

                if (orderId != null) {
                  final response2 = await http.post(
                    Uri.parse('$serverURL/api/paymentToPointStatus/'),
                    headers: <String, String>{
                      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
                      HttpHeaders.authorizationHeader: 'Bearer $token',
                    },
                    body: jsonEncode({
                      'orderId': orderId,
                      'amount': widget.amount,
                    }),
                  );
                  log(token.toString());
                  log(token.toString());
                  log(token.toString());
                  log(token.toString());
                  log(token.toString());
                  log(
                    jsonEncode({
                      'orderId': orderId,
                      'amount': widget.amount,
                    }),
                  );
                  log(response2.statusCode.toString());
                  log(response2.body.toString());

                  if (response2.statusCode == 200) {
                    walletController.cartList.clear();
                    walletController.cartList.refresh();
                    showSnackBar('copySucces', 'orderSubtitle', Colors.green);
                    await Get.to(
                      () => const BottomNavBar(
                        showPages: false,
                      ),
                    );
                  }
                } else {}
                // ignore: empty_catches
              } catch (e) {
                // showSnackBar('tournamentInfo1', 'tournamentInfo14', Colors.red);
              }
            });
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        fontSize: 0.0,
        backArrow: true,
        icon: userAppBarMoney(),
        iconRemove: false,
        name: 'orderPage'.tr,
        elevationWhite: true,
      ),
      backgroundColor: kPrimaryColorBlack,
      body: WebViewWidget(
        controller: _controller..loadRequest(Uri.parse(widget.url)),
      ),
    );
  }
}
