// ignore_for_file: file_names

import 'package:game_app/models/user_models/auth_model.dart';

import '../models/accouts_for_sale_model.dart';
import '../views/constants/index.dart';

class WalletController extends GetxController {
  final storage = GetStorage();

  RxDouble finalPRice = 0.0.obs;
  RxDouble finalCount = 0.0.obs;
  RxList cartList = [].obs;
  RxString userMoney = '0.0'.obs;

  dynamic addCart({
    required int id,
    required String price,
    required String title,
    required String image,
    required String status,
  }) {
    if (cartList.isEmpty) {
      cartList.add({
        'id': id,
        'count': 1,
        'price': price,
        'name': title,
        'status': status,
        'image': image,
      });
    } else {
      bool value = false;
      for (var element in cartList) {
        if (element['id'] == id) {
          value = true;
          element['count']++;
        }
      }
      if (!value) {
        cartList.add({
          'id': id,
          'count': 1,
          'price': price,
          'name': title,
          'status': status,
          'image': image,
        });
      }
    }
    storage.write('cart', cartList);
  }

  dynamic removeCart(int id) {
    cartList.removeWhere((element) => element['id'] == id);
    storage.write('cart', cartList);
  }

  dynamic minusCart(int id) {
    for (var element in cartList) {
      if (element['id'] == id) {
        element['count']--;
      }
    }
    storage.write('cart', cartList);
  }

  /// Shows [points] (a string such as "1000.00") as the balance; anything that
  /// is not a number, e.g. from a failed request, shows 0.
  void setMoneyFromPoints(String? points) {
    userMoney.value = (points == null || double.tryParse(points) == null) ? '0' : points;
  }

  dynamic getUserMoney() async {
    final token = await Auth().getToken();
    if (token == null) {
      userMoney.value = '0';
    } else {
      await PostByIdModel().getMe().then((value) => setMoneyFromPoints(value.points));
    }
  }
}
