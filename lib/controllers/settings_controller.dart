// ignore_for_file: file_names

import 'package:material_ui/material_ui.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();
  RxBool agreeButton = false.obs;
  RxBool loginUser = false.obs;
  RxInt bannerSelectedIndex = 0.obs;
  RxString pubgType = ''.obs;

  Future<bool> changeUserUI() async {
    final token = await Auth().getToken();
    if (token != null) {
      loginUser.value = true;
    } else {
      loginUser.value = false;
    }
    return false;
  }

  var tm = const Locale('tr');
  var ru = const Locale('ru');
  var en = const Locale('en');

  dynamic switchLang(String value) {
    if (value == 'en') {
      Get.updateLocale(en);
      storage.write('langCode', 'en');
    } else if (value == 'ru') {
      Get.updateLocale(ru);
      storage.write('langCode', 'ru');
    } else {
      Get.updateLocale(tm);
      storage.write('langCode', 'tr');
    }
    update();
  }
}
