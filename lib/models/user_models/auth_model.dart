// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

class Auth {
  final storage = GetStorage();

  void login(String? data) async {
    await storage.write('data', data);
  }

  /// The next player on this phone must not get the previous one's support replies.
  Future<void> _leaveSupportTopic() async {
    try {
      for (final key in ['supportTopic', 'userTopic']) {
        final topic = storage.read<String>(key);
        if (topic != null) {
          await storage.remove(key);
          await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        }
      }
    } catch (_) {}
  }

  Future<bool> logout() async {
    await _leaveSupportTopic();
    await storage.remove('AccessToken');
    await storage.remove('RefreshToken');
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Token///////////////////////////////////
  Future<bool> setToken(String token) async {
    await storage.write('AccessToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getToken() async {
    return storage.read('AccessToken');
  }

  Future<bool> removeToken() async {
    await _leaveSupportTopic();
    await storage.remove('AccessToken');
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Refresh Token///////////////////////////////////

  Future<bool> setRefreshToken(String token) async {
    await storage.write('RefreshToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getRefreshToken() async {
    return storage.read('RefreshToken');
  }

  Future<bool> removeRefreshToken() async {
    await storage.remove('RefreshToken');
    return storage.read('RefreshToken') == null ? true : false;
  }
}
