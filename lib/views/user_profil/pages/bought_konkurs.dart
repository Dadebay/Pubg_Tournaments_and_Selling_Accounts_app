import 'package:flutter/cupertino.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/index.dart';

class BoughtKonkurs extends StatelessWidget {
  const BoughtKonkurs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, elevationWhite: true, iconRemove: true, name: 'boughtKonkurs'),
      body: Column(
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
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'price'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'code'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BoughtKonkursModel>>(
              future: BoughtKonkursModel().getMyKonkurs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return errorData(
                    onTap: () {
                      BoughtKonkursModel().getMyKonkurs();
                    },
                  );
                } else if (snapshot.data == null) {
                  return emptyData();
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
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: snapshot.data![index].code.toString())).then((value) {
                          showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green);
                        });
                      },
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
                                      fontFamily: gilroyMedium,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${snapshot.data![index].price} TMT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: gilroyBold,
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
                                fontFamily: gilroyMedium,
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
}

class BoughtCODES extends StatelessWidget {
  const BoughtCODES({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, elevationWhite: true, iconRemove: true, name: 'boughtCODES'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'kodName'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'giftName'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'price'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'count'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BoughtThingsModel>>(
              future: BoughtThingsModel().getGifts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return errorData(
                    onTap: () {
                      BoughtThingsModel().getGifts();
                    },
                  );
                } else if (snapshot.data == null) {
                  return emptyData();
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
                            flex: 2,
                            child: Text(
                              '${snapshot.data![index].asking}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: gilroyBold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${snapshot.data![index].thingName}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: gilroyMedium,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${snapshot.data![index].thingCommonPrice} TMT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: gilroyBold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${snapshot.data![index].thingCount}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: gilroyMedium,
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
}
