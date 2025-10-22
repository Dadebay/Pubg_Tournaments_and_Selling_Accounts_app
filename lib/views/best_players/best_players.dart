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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: MyAppBar(
        fontSize: 0,
        backArrow: true,
        iconRemove: false,
        icon: Container(
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          // child: IconButton(
          //   onPressed: () {
          //     AddAccountModel().getConsts().then((value) {
          //       showBestPlayerPrice(
          //         context,
          //         'placeTurnirGet.tr',
          //         value['best_players_text'],
          //       );
          //     });
          //   },
          //   icon: const Icon(
          //     Icons.info_outline,
          //     color: kPrimaryColor,
          //   ),
          // ),
        ),
        name: 'bestPlayers2',
        elevationWhite: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1a1f3a),
              kPrimaryColorBlack,
            ],
          ),
        ),
        child: Column(
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
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          'errorLoadData'.tr,
                          style: const TextStyle(
                            fontFamily: josefinSansMedium,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.data.toString() == '[]') {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          'errorLoadEmptyData'.tr,
                          style: const TextStyle(
                            fontFamily: josefinSansMedium,
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length - 1,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemBuilder: (BuildContext context, int index) {
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BestPlayersCard(
                            index: index,
                            image: '$serverURL${snapshot.data![index].image}',
                            name: snapshot.data![index].pubgUsername!.isEmpty ? 'Unknoun' : snapshot.data![index].pubgUsername!,
                            points: snapshot.data![index].points!,
                            referalPage: false,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container topPart() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.2),
            kPrimaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'No',
              maxLines: 1,
              style: TextStyle(
                color: kPrimaryColor,
                fontFamily: josefinSansBold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'userNamePlayers'.tr,
              maxLines: 1,
              style: const TextStyle(
                color: kPrimaryColor,
                fontFamily: josefinSansBold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'userNamePlayers2'.tr,
              maxLines: 1,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: kPrimaryColor,
                fontFamily: josefinSansBold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
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
        final curvedValue = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: const Color(0xFF0A0E27),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: kPrimaryColor.withOpacity(0.5), width: 2),
              ),
              title: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withOpacity(0.2),
                      kPrimaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 24,
                    fontFamily: josefinSansBold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              content: Container(
                height: Get.size.height / 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Html(
                      data: text2.tr,
                      style: {
                        'body': Style(
                          fontFamily: josefinSansMedium,
                          fontSize: FontSize(18.0),
                          textAlign: TextAlign.left,
                          color: Colors.white70,
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
    );
  }
}
