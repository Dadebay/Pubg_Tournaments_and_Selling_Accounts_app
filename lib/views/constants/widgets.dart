// ignore_for_file: deprecated_member_use, duplicate_ignore, implementation_imports, avoid_positional_boolean_parameters, unnecessary_null_comparison, always_use_package_imports

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/views/other_pages/show_all_acconts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../constants/index.dart';

SnackbarController showSnackBar(String title, String subtitle, Color color) {
  return Get.snackbar(
    title,
    subtitle,
    snackStyle: SnackStyle.FLOATING,
    titleText: title == ''
        ? const SizedBox.shrink()
        : Text(
            title.tr,
            style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 18, color: Colors.white),
          ),
    messageText: Text(
      subtitle.tr,
      style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 16, color: Colors.white),
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    borderRadius: 20.0,
    animationDuration: const Duration(milliseconds: 800),
    margin: const EdgeInsets.all(8),
  );
}

Padding divider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Divider(color: backgroundColor.withOpacity(0.4), thickness: 2),
  );
}

Widget dividerr() {
  return Container(color: Colors.grey[300], width: double.infinity, height: 1);
}

Divider customDivider() {
  return const Divider(thickness: 1, color: backgroundColor, height: 1);
}

Widget spinKit() {
  return Center(child: Lottie.asset(loader, animate: true, width: 300, height: 300));
}

Widget userAppBarMoney() {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          double a = 0.0;
          if (Get.find<WalletController>().userMoney != null) {
            a = double.parse(Get.find<WalletController>().userMoney.toString());
          }
          return Text(
            a.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 23),
          );
        }),
        const Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Icon(IconlyLight.wallet, color: Colors.white),
        ),
      ],
    ),
  );
}

Column errorData({required Function() onTap}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'errorLoadData'.tr,
        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
      ),
      const SizedBox(height: 15),
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius5),
          elevation: 0,
        ),
        child: Text(
          'noConnection3'.tr,
          style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold, fontSize: 16),
        ),
      ),
    ],
  );
}

Column emptyData() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Lottie.asset(noDataLottie, width: 350, height: 350),
      const SizedBox(height: 15),
      Text(
        'errorLoadEmptyData'.tr,
        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
      ),
    ],
  );
}

Center noData(String text) {
  return Center(
    child: Text(
      text.tr,
      style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
    ),
  );
}

ListView waitingData() {
  return ListView.builder(
    scrollDirection: Axis.vertical,
    itemCount: 10,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        height: 170,
        decoration: BoxDecoration(borderRadius: borderRadius15, color: kPrimaryColorBlack1.withOpacity(0.4)),
        child: Center(child: spinKit()),
      );
    },
  );
}

Container noBannerImage() {
  return Container(
    margin: const EdgeInsets.all(15),
    width: Get.size.width,
    height: 220,
    decoration: const BoxDecoration(borderRadius: borderRadius15, color: kPrimaryColorBlack1),
    child: Center(
      child: Text(
        'noImageBanner'.tr,
        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold),
      ),
    ),
  );
}

Padding listViewName(String text, bool icon, Size size) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: size.width >= 800 ? 30 : 24, fontFamily: gilroyBold),
        ),
        icon
            ? GestureDetector(
                onTap: () => Get.to(() => const ShowAllAccounts(name: 'accountsForSale')),
                child: Container(
                  width: size.width >= 800 ? 48 : 38,
                  height: size.width >= 800 ? 48 : 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.6),
                  ),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: size.width >= 800 ? 26 : 20, strokeWidth: 2),
                ),
              )
            : const SizedBox.shrink(),
      ],
    ),
  );
}

CustomFooter footer() {
  return CustomFooter(
    builder: (BuildContext context, LoadStatus? mode) {
      Widget body;
      if (mode == LoadStatus.idle) {
        body = const Text('');
      } else if (mode == LoadStatus.loading) {
        body = const CircularProgressIndicator(color: kPrimaryColor);
      } else if (mode == LoadStatus.failed) {
        body = const Text('Load Failed!Click retry!');
      } else if (mode == LoadStatus.canLoading) {
        body = const Text('');
      } else {
        body = const Text('No more Data');
      }
      return SizedBox(height: 55.0, child: Center(child: body));
    },
  );
}
