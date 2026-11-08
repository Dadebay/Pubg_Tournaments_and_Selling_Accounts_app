// ignore_for_file: file_names
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:game_app/utils/order_push.dart';
import 'package:game_app/utils/support_push.dart';

class FCMConfig {
  Future<void> initAwesomeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
        ),
      ],
      channelGroups: [NotificationChannelGroup(channelGroupKey: 'basic_channel_group', channelGroupName: 'Basic group')],
      debug: false,
    );
    // A tap on a notification of the support chat opens the chat.
    await AwesomeNotifications().setListeners(onActionReceivedMethod: onAction);
    // await FirebaseMessaging.instance.subscribeToTopic('EVENT');
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  int a = 0;

  @pragma('vm:entry-point')
  static Future<void> onAction(ReceivedAction action) async {
    if (action.payload?['type'] == 'support') {
      SupportPush.open();
    } else if (action.payload?['type'] == 'game_order') {
      OrderPush.open();
    }
  }

  Future<void> sendNotification({required String title, required String body, Map<String, String>? payload}) async {
    a++;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(id: a, channelKey: 'basic_channel', title: title, body: body, notificationLayout: NotificationLayout.BigText, wakeUpScreen: true, payload: payload),
    );
  }
}
