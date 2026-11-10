import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/best_players_model.dart';
import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:lottie/lottie.dart';

class ConcursWinners extends StatelessWidget {
  const ConcursWinners({required this.concursID, super.key});
  final String concursID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(fontSize: 22, backArrow: true, iconRemove: false, name: 'tournamentInfo3', elevationWhite: true),
      backgroundColor: kPrimaryColorBlack,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'signIn1'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'signIn2'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroySemiBold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'phoneNumberConcurs'.tr,
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
            child: FutureBuilder<List<GetKonkursUsers>>(
              future: GetKonkursUsers().getKonkursWINS(id: int.parse(concursID.toString())),
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
                      const SizedBox(height: 15),
                      Text(
                        'notBoughtConcurs'.tr,
                        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return errorData(
                    onTap: () {
                      GetBoughtKonkursByIDModel().getMyKonkursByID(id: int.parse(concursID.toString()));
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
                          Text(
                            ' ${index + 1}.',
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: CachedNetworkImage(
                              fadeInCurve: Curves.ease,
                              imageUrl: '$serverURL/media/${snapshot.data![index].img}',
                              imageBuilder: (context, imageProvider) => Container(
                                width: Get.size.width,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Center(child: spinKit()),
                              errorWidget: (context, url, error) => Container(
                                color: kPrimaryColor.withOpacity(0.2),
                                child: const Center(
                                  child: Text(
                                    'Surat ýok',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontFamily: gilroySemiBold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${snapshot.data![index].pubgUsername}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 17),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${snapshot.data![index].pubgID}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${snapshot.data![index].phone}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 16),
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
