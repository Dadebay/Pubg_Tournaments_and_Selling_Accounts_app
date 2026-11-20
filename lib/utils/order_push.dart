import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/catalog/game_orders_page.dart';
import 'package:game_app/views/orders/orders_history_page.dart';
import 'package:get/get.dart';

/// The push the server sends to the topic `user_<user id>` when an admin changes the
/// status of a game or program order: `data: {type: 'game_order', order_id, status}`.
/// A tap opens "My orders" of games.
class OrderPush {
  const OrderPush._();

  static bool _pendingOpen = false;
  static bool _pendingAccount = false;

  /// The push of a bought account: `data: {type: 'account_order', order_id, status}`.
  static bool isAccountOrder(RemoteMessage message) => '${message.data['type'] ?? ''}' == 'account_order';

  /// An order status push. The `user_<id>` topic also carries support replies, so the topic alone says nothing.
  static bool isOrder(RemoteMessage message) {
    if (SupportPush.isSupport(message)) {
      return false;
    }
    return '${message.data['type'] ?? ''}'.toLowerCase().contains('order');
  }

  /// The payload a local notification carries so a tap can tell what to open.
  static Map<String, String>? payload(RemoteMessage message) {
    if (SupportPush.isSupport(message)) {
      return {'type': 'support'};
    }
    if (isAccountOrder(message)) {
      return {'type': 'account_order'};
    }
    return isOrder(message) ? {'type': 'game_order'} : null;
  }

  /// A game order opens the game orders; a bought account opens "My orders" ([account]).
  static void open({bool account = false}) {
    if (!SupportPush.homeReady) {
      _pendingOpen = true;
      _pendingAccount = account;
      return;
    }
    Get.to(() => account ? const OrdersHistoryPage() : const GameOrdersPage());
  }

  /// Called when the first page is up: opens the orders if a notification asked for it before.
  static void flush() {
    if (_pendingOpen) {
      _pendingOpen = false;
      open(account: _pendingAccount);
      _pendingAccount = false;
    }
  }
}
