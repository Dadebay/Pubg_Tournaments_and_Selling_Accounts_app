import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/utils/order_push.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Everything the support chat needs outside its own page: the push topic of
/// the player, the unread number for the badges and opening the chat from a
/// notification. The server sends an admin reply to the FCM topic
/// `support_<user id>`.
class SupportPush {
  const SupportPush._();

  /// Storage key of the topic this device is subscribed to (the logout reads it too).
  static const String topicKey = 'supportTopic';

  /// Storage key of the topic for order status pushes (`user_<user id>`).
  static const String userTopicKey = 'userTopic';

  /// Admin replies the player has not read; the badges listen to it.
  static final ValueNotifier<int> unread = ValueNotifier(0);

  /// True while the chat page is open: its own polling shows the reply, so no notification.
  static bool chatOpen = false;

  /// True once the first page after the start-up checks is on screen.
  static bool homeReady = false;
  static bool _pendingOpen = false;

  static Future<void> refreshUnread() async {
    final result = await UcdayyApi.getSupportUnread();
    final data = result.data;
    if (!result.ok || data is! Map) {
      return;
    }
    unread.value = int.tryParse('${data['unread'] ?? data['messages']}') ?? 0;
  }

  /// Subscribes this device to the player's topic. Safe to call on every start.
  static Future<void> subscribe() async {
    try {
      final result = await UcdayyApi.getMyAccount();
      final data = result.data;
      if (!result.ok || data is! Map) {
        return;
      }
      final id = int.tryParse('${data['user'] ?? data['id']}') ?? 0;
      if (id <= 0) {
        return;
      }
      // Support replies and order changes come to `user_<id>`, broadcasts of the admin to `EVENT`.
      // The old `support_<id>` topic is left (the server sends each message once).
      await _leave(topicKey);
      await _join(userTopicKey, 'user_$id');
      await FirebaseMessaging.instance.subscribeToTopic(broadcastTopic);
    } catch (e) {
      debugPrint('support topic: $e');
    }
  }

  /// Topic of the broadcasts written in the admin panel.
  static const String broadcastTopic = 'EVENT';

  /// Leaves the topic stored under [key], if any.
  static Future<void> _leave(String key) async {
    final storage = GetStorage();
    final old = storage.read<String>(key);
    if (old != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(old);
      await storage.remove(key);
    }
  }

  /// Subscribes to [topic], leaving the one stored under [key] when it is another player's.
  static Future<void> _join(String key, String topic) async {
    final storage = GetStorage();
    final old = storage.read<String>(key);
    if (old == topic) {
      return;
    }
    if (old != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(old);
    }
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    await storage.write(key, topic);
  }

  /// A push of the support chat: it comes from the player's topic, or says so in its data.
  static bool isSupport(RemoteMessage message) {
    final type = '${message.data['type'] ?? ''}'.toLowerCase();
    return (message.from ?? '').startsWith('/topics/support_') || type == 'support' || type == 'support_chat';
  }

  /// The chat is opened at once when the app is up, otherwise as soon as the first page is.
  static void open() {
    if (!homeReady) {
      _pendingOpen = true;
      return;
    }
    if (!chatOpen) {
      Get.to(() => const SupportChatPage());
    }
  }

  /// Called by the first page: opens the chat when a notification asked for it before.
  static void markHomeReady() {
    homeReady = true;
    if (_pendingOpen) {
      _pendingOpen = false;
      open();
    }
    OrderPush.flush();
  }
}
