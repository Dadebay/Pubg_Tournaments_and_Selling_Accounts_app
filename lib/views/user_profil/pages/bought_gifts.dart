import 'package:flutter/cupertino.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/index.dart';

class BoughtGifts extends StatelessWidget {
  const BoughtGifts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, elevationWhite: true, iconRemove: true, name: 'boughtGifts'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'giftName'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'userPhoneNumber'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'code'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BoughtGiftsModel>>(
              future: BoughtGiftsModel().getGifts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return errorData(
                    onTap: () {
                      BoughtGiftsModel().getGifts();
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
                                Text(
                                  '${snapshot.data![index].giftName}',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: gilroyMedium,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                snapshot.data![index].phone.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: gilroyRegular,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
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
