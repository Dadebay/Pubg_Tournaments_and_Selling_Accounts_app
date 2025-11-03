import 'package:flutter/material.dart';
import 'package:game_app/views/user_profil/pages/history_orders_page.dart';
import 'package:game_app/views/user_profil/pages/new_notification_page.dart';
import 'package:get/get.dart';

import '../../models/user_models/auth_model.dart';
import '../constants/constants.dart';
import '../constants/widgets.dart';
import '../other_pages/show_all_acconts.dart';
import '../user_profil/pages/add_cash.dart';
import '../user_profil/pages/notification.dart';

class MiniCategoryCard extends StatelessWidget {
  final int index;
  final String name;
  final String image;
  const MiniCategoryCard({
    required this.index,
    required this.name,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (index == 0) {
          await Get.to(
            () => ShowAllAccounts(
              name: name,
            ),
          );
        } else if (index == 1) {
          final token = await Auth().getToken();
          if (token != null) {
            // defaultBottomSheet(name: 'selectCityTitle', child: getCitiess());
            await Get.to(() => const HistoryOrdersPage());
          } else {
            showSnackBar('loginError', 'add_account_login_error', Colors.red);
          }
        }
        //  else if (index == 2) {
        //   await Get.to(
        //     () => AskMoneyPage(
        //       text: 'message',
        //       textSend: 'requestCash'.tr,
        //     ),
        //   );
        // }
        else if (index == 2) {
          await Get.to(() => NotificationPage());
        }
      },
      child: Container(
        width: Get.size.width,
        margin: const EdgeInsets.only(
          left: 16,
        ),
        decoration: BoxDecoration(borderRadius: borderRadius20, color: Colors.grey.withOpacity(0.1)),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius20,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(decoration: BoxDecoration(borderRadius: borderRadius20, color: kPrimaryColorBlack.withOpacity(0.5))),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(name.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontWeight: FontWeight.bold, fontSize: 33)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewMiniCategoryCard extends StatelessWidget {
  final int index;
  final String name;
  final String image;
  const NewMiniCategoryCard({
    required this.index,
    required this.name,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (index == 0) {
          await Get.to(
            () => ShowAllAccounts(
              name: name,
            ),
          );
        } else if (index == 3) {
          final token = await Auth().getToken();
          if (token != null) {
            // defaultBottomSheet(name: 'selectCityTitle', child: getCitiess());
            await Get.to(() => const HistoryOrdersPage());
          } else {
            showSnackBar('loginError', 'add_account_login_error', Colors.red);
          }
        }
        //  else if (index == 2) {
        //   await Get.to(
        //     () => AskMoneyPage(
        //       text: 'message',
        //       textSend: 'requestCash'.tr,
        //     ),
        //   );
        // }
        else if (index == 1) {
          await Get.to(() => NewNotificationPage());
        }
      },
      child: Container(
        width: Get.size.width,
        margin: const EdgeInsets.only(
          left: 16,
        ),
        decoration: BoxDecoration(borderRadius: borderRadius20, color: Colors.grey.withOpacity(0.1)),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius20,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(decoration: BoxDecoration(borderRadius: borderRadius20, color: kPrimaryColorBlack.withOpacity(0.5))),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(name.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontWeight: FontWeight.bold, fontSize: 33)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
