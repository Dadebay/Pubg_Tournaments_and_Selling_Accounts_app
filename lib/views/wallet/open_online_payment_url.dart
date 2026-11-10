import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/wallet/payment_banks.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The bank page of a basket paid by card. On the `returnUrl` (or when the user closes the
/// page) the status is asked from the server. The page pops with the status code of that call.
class OpenOnlinePaymentWebsite extends StatefulWidget {
  const OpenOnlinePaymentWebsite({required this.registration, required this.list, required this.thingBuy, required this.konkursBuy, super.key});
  final CardRegistration registration;
  final bool thingBuy;
  final bool konkursBuy;
  final List list;
  @override
  State<OpenOnlinePaymentWebsite> createState() => _OpenOnlinePaymentWebsiteState();
}

class _OpenOnlinePaymentWebsiteState extends State<OpenOnlinePaymentWebsite> {
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

  /// The same basket as in the register call, with the order id.
  List<Map<String, Object?>> get _lines {
    final orderId = widget.registration.orderId;
    if (!widget.thingBuy) {
      return [
        for (final e in widget.list) {'status': e['status'], 'id': e['id'], 'count': e['count'], 'orderId': orderId, 'pubg_id': e['pubg_id']},
      ];
    }
    if (widget.konkursBuy) {
      return [
        for (final e in widget.list) {'status': 'konkurs', 'id': e['id'], 'count': e['count'], 'orderId': orderId},
      ];
    }
    return [
      for (final e in widget.list) {'status': e['status'], 'id': e['id'], 'count': e['count'], 'asking': e['asking'], 'orderId': orderId},
    ];
  }

  Future<void> _checkStatus({required bool closePage}) async {
    final result = await UcdayyApi.basketCardStatus(_lines);
    if (result.ok || PaymentFlow.alreadyUsed(result)) {
      walletController.cartList.clear();
      walletController.cartList.refresh();
      walletController.getUserMoney();
      showSnackBar('copySucces', 'orderSubtitle', Colors.green);
      if (closePage && Get.key.currentState?.canPop() == true) {
        Get.back(result: 200);
      }
      return;
    }
    if (!closePage) {
      return;
    }
    if (result.statusCode == 409) {
      // Paid, but the stock ran out: the money went back to the balance.
      walletController.getUserMoney();
      showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
      Get.back(result: 409);
      return;
    }
    showSnackBar('noConnection3', PaymentFlow.errorKey(result), Colors.red);
    _statusCalled = false;
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
