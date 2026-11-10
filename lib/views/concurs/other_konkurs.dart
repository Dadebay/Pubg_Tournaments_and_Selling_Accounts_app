import 'dart:convert';
import 'dart:io';

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/get_gifts_model.dart';
import 'package:game_app/views/cards/concurs_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/wallet/order_page.dart';
import 'package:http/http.dart' as http;

import '../../../models/user_models/auth_model.dart';

class OtherConcursScreen extends StatefulWidget {
  const OtherConcursScreen({required this.pageName, required this.sellingID, super.key});
  final String pageName;
  final int sellingID;
  @override
  State<OtherConcursScreen> createState() => _OtherConcursScreenState();
}

class _OtherConcursScreenState extends State<OtherConcursScreen> {
  String dialogTitle = '';
  TextEditingController pubgUserIDController = TextEditingController();
  FocusNode pubgUserIDFocusNode = FocusNode();
  FocusNode pubgUserIDFocusNode2 = FocusNode();
  int selectedIndex = 2;
  String title = 'selectUCType'.tr;
  final validator = GlobalKey<FormState>();
  final WalletController walletController = Get.put(WalletController());

  AppBar appBar() {
    return AppBar(
      elevation: 1,
      centerTitle: true,
      leadingWidth: 80,
      leading: IconButton(
        icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        Center(
          child: Padding(padding: const EdgeInsets.only(right: 12), child: userAppBarMoney()),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColorBlack,
      title: Text(
        widget.pageName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 25),
      ),
    );
  }

  ElevatedButton orderButton() {
    return ElevatedButton(
      onPressed: () async {
        if (await _checkToken()) {
          await onTapFunction();
        }
      },
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: kPrimaryColor,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'order'.tr,
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 22),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2, left: 8),
            child: Icon(IconlyLight.arrowRightCircle, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkToken() async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      showSnackBar('loginError', 'loginError1', Colors.red);
      return false;
    }
    return true;
  }

  Future<void> onTapFunction() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColorBlack,
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadius20,
            side: BorderSide(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'enterIDGift'.tr,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Form(
                  key: validator,
                  child: CustomTextField(
                    labelName: dialogTitle,
                    controller: pubgUserIDController,
                    borderRadius: true,
                    focusNode: pubgUserIDFocusNode,
                    requestfocusNode: pubgUserIDFocusNode2,
                    isNumber: false,
                  ),
                ),
              ),
              AgreeButton(
                name: 'agree',
                onTap: () async {
                  if (await _checkToken()) {
                    if (validator.currentState!.validate()) {
                      double value = 0.0;
                      double counts = 0.0;
                      for (var element in walletController.cartList) {
                        value += double.parse(element['price']) * element['count'];
                        counts += element['count'];
                      }
                      walletController.finalPRice.value = value;
                      walletController.finalCount.value = counts;
                      //if widget.pageName contains belet text
                      final bool containsBelet = widget.pageName.toLowerCase().contains('belet'.toLowerCase()); // case insensitive
                      await Get.to(() => OrderPage(pubgID: pubgUserIDController.text, onlyCard: containsBelet, asking: dialogTitle));
                    } else {
                      showSnackBar('tournamentInfo14', 'errorEmpty', Colors.red);
                    }
                  } else {
                    showSnackBar('noConnection3', 'order_error_subtitle', Colors.red);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<ThingsMODEL>> getThingsProducts({required int id}) async {
    final List<ThingsMODEL> pubgPost = [];
    final response = await http.get(
      Uri.parse('$serverURL/api/category/sellings/$id/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        // HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      for (final Map product in responseJson) {
        pubgPost.add(ThingsMODEL.fromJson(product));
      }
      dialogTitle = pubgPost[0].asking;
      return pubgPost;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      floatingActionButton: Obx(() {
        return AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: orderButton(),
          crossFadeState: walletController.cartList.isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 500),
          alignment: Alignment.center,
          sizeCurve: Curves.easeInOut,
        );
      }),
      appBar: appBar(),
      body: Column(
        children: [
          customDivider(),
          Expanded(
            child: FutureBuilder<List<ThingsMODEL>>(
              future: getThingsProducts(id: widget.sellingID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return spinKit();
                } else if (snapshot.data == null) {
                  return emptyData();
                } else if (snapshot.data!.isEmpty) {
                  return emptyData();
                } else if (snapshot.hasError) {
                  return errorData(onTap: () {});
                }
                return GridView.builder(
                  itemCount: snapshot.data!.length,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.8 / 4),
                  itemBuilder: (context, index) {
                    return ThingsCards(model: snapshot.data![index], selectedIndex: selectedIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
