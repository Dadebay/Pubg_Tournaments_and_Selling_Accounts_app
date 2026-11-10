import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/wallet/payment_banks.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The bank page of a card top-up. When the bank sends the user to the `returnUrl` (or the user
/// closes the page) the server is asked for the status of the order; it checks with the bank itself.
class OnlineAddMoneyToWallet extends StatefulWidget {
  const OnlineAddMoneyToWallet({required this.registration, required this.amount, super.key});
  final CardRegistration registration;

  /// Whole manat, the same amount as in the register call.
  final int amount;
  @override
  State<OnlineAddMoneyToWallet> createState() => _OnlineAddMoneyToWalletState();
}

class _OnlineAddMoneyToWalletState extends State<OnlineAddMoneyToWallet> {
  late final WebViewController _controller;
  final WalletController walletController = Get.put(WalletController());
  bool _statusCalled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (widget.registration.isReturn(request.url)) {
              _finish();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (widget.registration.isReturn(url)) {
              _finish();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.registration.formUrl));
  }

  @override
  void dispose() {
    // The user left the page by themselves: still ask the server, if they paid it succeeds.
    if (!_statusCalled) {
      _statusCalled = true;
      _checkStatus(closePage: false);
    }
    super.dispose();
  }

  void _finish() {
    if (_statusCalled) {
      return;
    }
    _statusCalled = true;
    _checkStatus(closePage: true);
  }

  Future<void> _checkStatus({required bool closePage}) async {
    final result = await UcdayyApi.cardTopUpStatus(amount: widget.amount, orderId: widget.registration.orderId);
    final data = result.data;
    final done = result.ok && data is Map && data['success'] == true;
    if (done || PaymentFlow.alreadyUsed(result)) {
      walletController.getUserMoney();
      if (closePage && Get.key.currentState?.canPop() == true) {
        Get.back();
      }
      if (done) {
        final bonus = data['bonus'] is num ? (data['bonus'] as num).toInt() : 0;
        final credited = data['amount'] is num ? (data['amount'] as num).toInt() : widget.amount;
        final message = bonus > 0 ? 'topUpSuccessBonus'.trParams({'amount': '$credited', 'bonus': '$bonus'}) : 'topUpSuccess'.trParams({'amount': '$credited'});
        showSnackBar('copySucces', message, Colors.green);
      } else {
        showSnackBar('copySucces', 'orderSubtitle', Colors.green);
      }
      return;
    }
    if (!closePage) {
      // The page is already gone and the order was not paid: nothing to tell.
      return;
    }
    if (result.statusCode == 400 && result.error == 'Payment is not valid') {
      _askCheckAgain();
    } else {
      showSnackBar('noConnection3', PaymentFlow.errorKey(result), Colors.red);
      if (mounted) {
        _statusCalled = false;
      }
    }
  }

  /// Not paid (yet): the player may press "check again" when they really paid.
  void _askCheckAgain() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1B1B1F),
        title: Text('paymentNotValid'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // dialog
              _statusCalled = true; // closing the page must not check again
              Get.back(); // payment page
            },
            child: Text('cancel'.tr, style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // dialog
              _statusCalled = true;
              _checkStatus(closePage: true);
            },
            child: Text('paymentCheckAgain'.tr, style: const TextStyle(color: Color(0xFFFFC83D), fontFamily: gilroySemiBold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        fontSize: 0.0,
        backArrow: true,
        icon: Padding(padding: const EdgeInsets.only(right: 8), child: userAppBarMoney()),
        iconRemove: false,
        name: 'orderPage'.tr,
        elevationWhite: true,
      ),
      backgroundColor: kPrimaryColorBlack,
      body: WebViewWidget(controller: _controller),
    );
  }
}
