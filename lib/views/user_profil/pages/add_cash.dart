// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/wallet/online_add_wallet_money.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/add_account_model.dart';
import '../../constants/index.dart';
import '../../constants/price.dart';

class AddCash extends StatefulWidget {
  const AddCash({super.key});

  @override
  State<AddCash> createState() => _AddCashState();
}

class _AddCashState extends State<AddCash> {
  bool addCash = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: false, elevationWhite: true, name: 'cashHistory'),
      body: Column(
        children: [
          Expanded(child: page1()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await Get.find<WalletController>().getUserMoney();
                        final double a = double.parse(Get.find<WalletController>().userMoney.toString());
                        if (a >= 100.0) {
                          await Get.to(
                            () => AskMoneyPage(
                              text: 'message1',
                              textSend: 'requestCash1'.tr,
                            ),
                          );
                        } else {
                          showSnackBar('money_error_title', 'request_money_error_subtitle', Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, padding: const EdgeInsets.all(15), shape: const RoundedRectangleBorder(borderRadius: borderRadius20)),
                      child: Text(
                        'requestCash1'.tr,
                        style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => AskMoneyPage(
                          text: 'message',
                          textSend: 'requestCash'.tr,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, padding: const EdgeInsets.all(15), shape: const RoundedRectangleBorder(borderRadius: borderRadius20)),
                    child: Text(
                      'requestCash'.tr,
                      style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<TransactionHistoryModel>> page1() {
    return FutureBuilder<List<TransactionHistoryModel>>(
      future: TransactionHistoryModel().getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: spinKit());
        } else if (snapshot.hasError) {
          return errorData(onTap: () {});
        } else if (snapshot.data == null) {
          return emptyData();
        } else if (snapshot.data.toString() == '[]') {
          return noData('no_cash');
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final double a = double.parse(snapshot.data![index].count.toString());
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${'cash'.tr} ${snapshot.data!.length - index}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: josefinSansMedium,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      snapshot.data![index].created_date!.substring(0, 10),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontFamily: josefinSansRegular),
                    ),
                  ),
                  Expanded(child: Price(showDiscountedPrice: true, textColor: Colors.white, selectedIndex: 0, price: a.toStringAsFixed(0))),
                ],
              ),
              iconColor: Colors.white,
            );
          },
        );
      },
    );
  }
}

class AskMoneyPage extends StatefulWidget {
  final String text;
  final String textSend;
  const AskMoneyPage({
    required this.text,
    required this.textSend,
    super.key,
  });

  @override
  State<AskMoneyPage> createState() => _AskMoneyPageState();
}

class _AskMoneyPageState extends State<AskMoneyPage> {
  TextEditingController messageController = TextEditingController();

  FocusNode messageFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();

  TextEditingController phoneController = TextEditingController();

  FocusNode phoneFocusNode = FocusNode();

  final _login = GlobalKey<FormState>();
  Future addMoneyToCARD() async {
    final String? token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/paymentToPoint/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amountController.text,
      }),
    );

    print(response.body);
    print(response.statusCode);
    await Get.to(
      () => OnlineAddMoneyToWallet(
        url: jsonDecode(response.body)['formUrl'],
        amount: amountController.text,
      ),
    );
  }

  TextEditingController amountController = TextEditingController();

  FocusNode amountFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: false, elevationWhite: true, name: 'cashHistory'),
      body: FutureBuilder<dynamic>(
        future: AddAccountModel().getConsts(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('Empty'));
          }
          return Form(
            key: _login,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'work_time'.tr,
                    style: const TextStyle(color: Colors.white, fontFamily: josefinSansMedium, height: 1.3, fontSize: 18),
                  ),
                ),
                widget.text != 'message'
                    ? CustomTextField(
                        labelName: 'fullName',
                        borderRadius: true,
                        controller: nameController,
                        focusNode: nameFocusNode,
                        requestfocusNode: phoneFocusNode,
                        isNumber: false,
                      )
                    : const SizedBox.shrink(),
                widget.text != 'message'
                    ? PhoneNumber(
                        mineFocus: phoneFocusNode,
                        controller: phoneController,
                        requestFocus: messageFocusNode,
                        style: false,
                        disabled: true,
                      )
                    : const SizedBox.shrink(),
                widget.text != 'message'
                    ? CustomTextField(
                        maxline: 5,
                        borderRadius: true,
                        labelName: widget.text,
                        controller: messageController,
                        focusNode: messageFocusNode,
                        requestfocusNode: nameFocusNode,
                        isNumber: false,
                        isLabel: true,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 20,
                ),
                widget.text != 'message'
                    ? Center(
                        child: AgreeButton(
                          name: 'agree',
                          onTap: () async {
                            final token = await Auth().getToken();
                            if (_login.currentState!.validate()) {
                              if (token != null) {
                                Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;

                                await TransactionHistoryModel()
                                    .requestCash(
                                  phone: phoneController.text,
                                  message: '${messageController.text}  ${widget.textSend}',
                                  fullname: nameController.text,
                                )
                                    .then((value) {
                                  if (value == 200) {
                                    Get.back();

                                    showSnackBar('copySucces', 'smsSuccesfullySent', Colors.green);
                                    phoneController.clear();
                                    messageController.clear();
                                    nameController.clear();
                                  } else {
                                    showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
                                  }
                                  Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
                                });
                              } else {
                                showSnackBar('loginError', 'loginError1', Colors.red);
                              }
                            } else {
                              showSnackBar('tournamentInfo14', 'errorEmpty', Colors.red);
                            }
                          },
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          // ignore: prefer_interpolation_to_compose_strings
                          await launch('tel://' + snapshot.data!['phone_three']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
                        ),
                        child: Text(
                          'popUP1'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansSemiBold, fontSize: 22),
                        ),
                      ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text('payCARD'.tr, style: const TextStyle(color: Colors.white, fontFamily: josefinSansMedium, height: 1.3, fontSize: 18)),
                ),
                AgreeButton(
                  onTap: () {
                    //fill up your balance write how much you want show dialog

                    Get.dialog(
                      AlertDialog(
                        title: Text(
                          'OnlinePayment'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: josefinSansSemiBold,
                          ),
                        ),
                        alignment: Alignment.center,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(labelName: 'OnlinePayment1', borderRadius: true, controller: amountController, focusNode: amountFocusNode, requestfocusNode: amountFocusNode, isNumber: true),
                            const SizedBox(
                              height: 20,
                            ),
                            AgreeButton(
                              onTap: () {
                                addMoneyToCARD();
                              },
                              name: 'agree',
                            ),
                          ],
                        ),
                      ),
                    );
                    // addMoneyToCARD
                  },
                  name: 'agree'.tr,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
