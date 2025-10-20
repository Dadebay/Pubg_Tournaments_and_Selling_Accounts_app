import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/views/constants/index.dart';

import '../../models/add_account_model.dart';
import '../../models/best_players_model.dart';
import '../cards/best_players_card.dart';

class BestPlayers extends StatelessWidget {
  const BestPlayers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBar(
        fontSize: 0,
        backArrow: false,
        iconRemove: false,
        icon: IconButton(
          onPressed: () {
            AddAccountModel().getConsts().then((value) {
              showBestPlayerPrice(
                context,
                'placeTurnirGet.tr',
                value['best_players_text'],
              );
            });
          },
          icon: const Icon(
            Icons.info_outline,
            color: kPrimaryColor,
          ),
        ),
        name: 'bestPlayers2',
        elevationWhite: true,
      ),
      body: Column(
        children: [
          topPart(),
          Expanded(
            child: FutureBuilder<List<BestPlayersModel>>(
              future: BestPlayersModel().getBestPlayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'errorLoadData'.tr,
                      style: const TextStyle(fontFamily: josefinSansMedium),
                    ),
                  );
                } else if (snapshot.data.toString() == '[]') {
                  return Center(
                    child: Text(
                      'errorLoadEmptyData'.tr,
                      style: const TextStyle(fontFamily: josefinSansMedium),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length - 1,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return BestPlayersCard(
                      index: index,
                      image: '$serverURL${snapshot.data![index].image}',
                      name: snapshot.data![index].pubgUsername!,
                      points: snapshot.data![index].points!,
                      referalPage: false,
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

  Container topPart() {
    return Container(
      color: kPrimaryColorBlack,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'No',
                    maxLines: 1,
                    style: TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 18),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'userNamePlayers'.tr,
                    maxLines: 1,
                    style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 18),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'userNamePlayers2'.tr,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<Object?> showBestPlayerPrice(
    BuildContext context,
    String text,
    String text2,
  ) {
    return showGeneralDialog(
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.decelerate.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 400, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: kPrimaryColorBlack,
              shape: const OutlineInputBorder(borderRadius: borderRadius15, borderSide: BorderSide(color: Colors.white)),
              title: Text(
                text.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: josefinSansBold),
              ),
              content: SizedBox(
                height: Get.size.height / 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
                    child: Html(
                      data: text2.tr,
                      style: {
                        'body': Style(fontFamily: josefinSansMedium, fontSize: FontSize(20.0), textAlign: TextAlign.left),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
    );
  }
}
