// ignore_for_file: file_names

import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/models/user_models/auth_model.dart';

import '../cards/order_card.dart';
import '../constants/index.dart';

class OrderPage extends StatefulWidget {
  final String pubgID;
  final String asking;
  final bool onlyCard;
  const OrderPage({required this.pubgID, required this.onlyCard, required this.asking, super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final WalletController walletController = Get.put(WalletController());
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    walletController.getUserMoney();
  }

  Widget bottomPart() {
    return Container(
      color: kPrimaryColorBlack,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Text(
              'info'.tr,
              style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: text(widget.asking, widget.pubgID),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orderPage3'.tr,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
              ),
              Obx(() {
                if (walletController.finalPRice > 0) {
                  return Text(
                    '${walletController.finalPRice} TMT',
                    style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 20),
                  );
                }
                return const Text(
                  '0 TMT',
                  style: TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 20),
                );
              }),
            ],
          ),
          // widget.onlyCard
          //     ? kartdan()
          //     :
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: kartdan(),
              // ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: AgreeButton(
                  name: 'Nagt',
                  showIcon: true,
                  onTap: () async {
                    final token = await Auth().getToken();
                    if (token != null) {
                      if (double.parse(walletController.userMoney.toString()) > 0) {
                        settingsController.agreeButton.value = !settingsController.agreeButton.value;
                        final List list = [];
                        for (var element in walletController.cartList) {
                          if (element['status'] == 'thing') {
                            list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'asking': widget.pubgID});
                          } else {
                            if (element['status'] == 'gift') {
                              list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': 'gift'});
                            } else {
                              list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': widget.pubgID});
                            }
                          }
                        }
                        print(list);
                        await UcModel().addCart(list).then((value) {
                          if (value == 200) {
                            walletController.cartList.clear();
                            walletController.cartList.refresh();
                            Get.back();
                            Get.back();
                            walletController.getUserMoney();
                            showSnackBar('copySucces', 'orderSubtitle', Colors.green);
                          } else if (value == 404) {
                            showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
                          } else {
                            showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
                          }
                        });
                        settingsController.agreeButton.value = !settingsController.agreeButton.value;
                      } else {
                        showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
                      }
                    } else {
                      showSnackBar('loginError', 'loginError1', Colors.red);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget kartdan() {
    return Center(
      child: AgreeButton(
        name: 'Kartdan',
        showIcon: true,
        onTap: () async {
          final token = await Auth().getToken();
          if (token != null) {
            settingsController.agreeButton.value = !settingsController.agreeButton.value;
            final List list = [];
            bool buything = false;
            for (var element in walletController.cartList) {
              if (element['status'] == 'thing') {
                buything = true;
                list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'asking': widget.pubgID});
              } else {
                if (element['status'] == 'gift') {
                  list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': 'gift'});
                } else {
                  list.add({'status': element['status'], 'id': element['id'], 'count': element['count'], 'pubg_id': widget.pubgID});
                }
              }
            }
            print(list);
            await UcModel()
                .addCartPlasticCARD(
              list,
              buything,
              false,
            )
                .then((value) {
              if (value == 200) {
                walletController.cartList.clear();
                walletController.cartList.refresh();
                Get.back();
                Get.back();
                walletController.getUserMoney();
                showSnackBar('copySucces', 'orderSubtitle', Colors.green);
              } else if (value == 404) {
                showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
              }
            });
            settingsController.agreeButton.value = !settingsController.agreeButton.value;
          } else {
            showSnackBar('loginError', 'loginError1', Colors.red);
          }
        },
      ),
    );
  }

  Row text(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1.tr,
          style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
        ),
        Text(
          text2.tr,
          style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontSize: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBar(
        fontSize: 0.0,
        backArrow: true,
        icon: userAppBarMoney(),
        iconRemove: false,
        name: 'orderPage'.tr,
        elevationWhite: true,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(() {
              return walletController.cartList.isEmpty
                  ? noData('Sargyt zat yok')
                  : ListView.builder(
                      itemCount: walletController.cartList.length,
                      itemExtent: size.width >= 800 ? 190 : 140,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return OrderCard(
                          id: walletController.cartList[index]['id'],
                          image: "$serverURL${walletController.cartList[index]["image"]}",
                          title: walletController.cartList[index]['name'] ?? 'Pubg UC',
                          price: walletController.cartList[index]['price'].toString(),
                          count: walletController.cartList[index]['count'],
                          status: walletController.cartList[index]['status'] ?? 'thing',
                        );
                      },
                    );
            }),
          ),
          customDivider(),
          bottomPart(),
        ],
      ),
    );
  }
}
