import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/provider/getkonkur.dart';
import 'package:game_app/views/concurs/concurs_winners.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ConcursByID extends StatefulWidget {
  const ConcursByID({required this.id, required this.name, required this.price, super.key});

  final String id;
  final String name;
  final String price;

  @override
  State<ConcursByID> createState() => _ConcursByIDState();
}

class _ConcursByIDState extends State<ConcursByID> {
  final SettingsController settingsController = Get.put(SettingsController());
  final WalletController walletController = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  dynamic fetchData() async {
    await Provider.of<getConcursByIDProvider>(context, listen: false).getConcursCartById(context, widget.id);
  }

  String getFormattedDate(String date) {
    final localDate = DateTime.parse(date).toLocal();

    final inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    final inputDate = inputFormat.parse(localDate.toString());
    final outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    final outputDate = outputFormat.format(inputDate);

    return outputDate.toString();
  }

  dynamic addPaymentOnCard() async {
    final token = await Auth().getToken();
    if (token != null) {
      settingsController.agreeButton.value = !settingsController.agreeButton.value;
      final List list = [];
      list.add({'status': 'konkurs', 'id': widget.id, 'count': '1'});

      await UcModel().addCartPlasticCARD(list, false, true).then((value) {
        if (value == 200) {
          walletController.cartList.clear();
          walletController.cartList.refresh();
          walletController.getUserMoney();
          showSnackBar('copySucces', 'orderSubtitle', Colors.green);
          setState(() {});
        } else if (value == 404) {
          showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
        }
      });
      settingsController.agreeButton.value = !settingsController.agreeButton.value;
    } else {
      showSnackBar('loginError', 'loginError1', Colors.red);
    }
  }

  dynamic addPaymentOnWallet() async {
    final token = await Auth().getToken();

    if (token != null) {
      if (double.parse(walletController.userMoney.toString()) > 0) {
        settingsController.agreeButton.value = !settingsController.agreeButton.value;
        final List list = [];

        list.add({'status': 'konkurs', 'id': widget.id, 'count': '1'});
        await UcModel().addCart(list).then((value) {
          if (value == 200) {
            walletController.cartList.clear();
            walletController.cartList.refresh();
            walletController.getUserMoney();
            showSnackBar('copySucces', 'orderSubtitle', Colors.green);
            setState(() {});
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
  }

  Stack imagePart(BuildContext context, getConcursByIDProvider concurs) {
    final Duration duration = concurs.concursCartById!.finishedDate.difference(DateTime.now());

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 200,
          decoration: BoxDecoration(border: Border.all(color: kPrimaryColor, width: 3), borderRadius: borderRadius20),
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: borderRadius20,
            child: CachedNetworkImage(
              imageUrl: '$serverURL${concurs.concursCartById?.image}',
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: kPrimaryColorBlack,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'startDate'.tr + getFormattedDate(concurs.concursCartById!.createdDate.toString()),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 3,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: kPrimaryColorBlack, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
            child: Countdown(
              seconds: duration.inSeconds,
              build: (BuildContext ctx, double time) {
                final int days = (time / (24 * 3600)).floor();
                final int hours = ((time % (24 * 3600)) / 3600).floor();
                final int minutes = ((time % 3600) / 60).floor();
                final int seconds = (time % 60).floor();
                final String textt = Get.locale!.languageCode == 'tr' ? '$days gün $hours sag $minutes min $seconds s' : '$days день $hours час $minutes мин $seconds s';
                return Text(
                  'endDate'.tr + textt,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontFamily: josefinSansSemiBold, color: kPrimaryColor),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: const Center(
            child: Text(
              'Töleg görnüşi',
              style: TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 24),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AgreeButton(
                onTap: () {
                  addPaymentOnCard();
                  Get.back();
                  fetchData();
                },
                showIcon: true,
                name: 'Kartdan',
              ),
              const SizedBox(height: 10),
              AgreeButton(
                onTap: () {
                  addPaymentOnWallet();
                  Get.back();
                  fetchData();
                },
                showIcon: true,
                name: 'Nagt',
              ),
            ],
          ),
        );
      },
    );
  }

  dynamic page1() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'konkursName'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: josefinSansSemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'price'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: josefinSansSemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'code'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: josefinSansSemiBold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<GetBoughtKonkursByIDModel>>(
              future: GetBoughtKonkursByIDModel().getMyKonkursByID(id: int.parse(widget.id.toString())),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.data == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(noDataLottie, width: 350, height: 350),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'notBoughtConcurs'.tr,
                        style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return errorData(
                    onTap: () {
                      GetBoughtKonkursByIDModel().getMyKonkursByID(id: int.parse(widget.id.toString()));
                    },
                  );
                } else if (snapshot.data.toString() == '[]') {
                  return noData('noOrder');
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {},
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 6, bottom: 4),
                                  child: Icon(
                                    CupertinoIcons.gift,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${snapshot.data![index].konkursName}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: josefinSansMedium,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${snapshot.data![index].price} TMT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: josefinSansBold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${snapshot.data![index].code}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: josefinSansMedium,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      iconColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBarNew(
        backArrow: true,
        iconRemove: false,
        icon: Text('${widget.price} TMT', style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 20)),
        elevationWhite: true,
        name: widget.name,
        fontSize: 0.0,
      ),
      body: Consumer<getConcursByIDProvider>(
        builder: (_, concurs, __) {
          if (concurs.isLoading == true) {
            return Container(margin: const EdgeInsets.all(8), height: 220, width: Get.size.width, decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.grey.withOpacity(0.4)), child: Center(child: spinKit()));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  imagePart(context, concurs),
                  page1(),
                  Center(
                    child: AgreeButton(
                      onTap: () async {
                        if (concurs.concursCartById!.finishedDate.isBefore(DateTime.now())) {
                          await Get.to(
                            () => ConcursWinners(
                              concursID: widget.id,
                            ),
                          );
                        } else {
                          _showPurchaseDialog(context);
                        }
                      },
                      name: concurs.concursCartById!.finishedDate.isBefore(DateTime.now()) == true ? 'showWinners' : 'tournamentInfo11',
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
