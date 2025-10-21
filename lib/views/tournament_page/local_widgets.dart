import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/views/best_players/best_players.dart';
import 'package:game_app/views/tournament_page/sellect_team.dart';
import 'package:game_app/views/tournament_page/tournament.dart';

import '../../controllers/wallet_controller.dart';
import '../../models/add_account_model.dart';
import '../../models/tournament_model.dart';
import '../../models/user_models/auth_model.dart';
import '../../models/user_models/user_sign_in_model.dart';
import '../constants/index.dart';

final List names = [
  'Turnir',
  'Squad',
  'bestPlayers2'.tr,
];

final List images = [
  'assets/image/1.png',
  'assets/image/3.png',
  'assets/image/image_best.png',
];
// 'Duo',
// 'assets/image/2.png',

dynamic tournamentCard(int index) {
  return GestureDetector(
    onTap: () {
      index == 2
          ? Get.to(
              () => const BestPlayers(),
            )
          : Get.to(
              () => TournamentPage(
                tournamentType: index + 1,
              ),
            );
    },
    child: Container(
      width: Get.size.width,
      height: index == 2 ? 150 : 150,
      margin: const EdgeInsets.only(top: 15, bottom: 5, right: 12, left: 12),
      decoration: BoxDecoration(color: kPrimaryColorBlack, borderRadius: borderRadius30, border: Border.all(color: kPrimaryColorBlack1)),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius30,
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(decoration: BoxDecoration(borderRadius: borderRadius30, color: kPrimaryColorBlack.withOpacity(0.4))),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(names[index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontSize: 40)),
            ),
          ),
        ],
      ),
    ),
  );
}

TabBar tabbar() {
  return TabBar(
    labelStyle: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 20),
    unselectedLabelStyle: const TextStyle(fontFamily: josefinSansMedium, fontSize: 18),
    labelColor: kPrimaryColor,
    unselectedLabelColor: Colors.grey,
    labelPadding: const EdgeInsets.only(top: 8, bottom: 4),
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorColor: kPrimaryColor,
    indicatorWeight: 2,
    tabs: [
      Tab(
        text: 'tournament'.tr,
      ),
      Tab(
        text: 'endTournament'.tr,
      ),
      // Tab(
      //   text: 'Pol Final',
      // ),
      // Tab(
      //   text: 'Final',
      // ),
    ],
  );
}

ListTile tab3PageTypeSolo({required int index, required TournamentModel model, required bool finised}) {
  return ListTile(
    onTap: () {},
    dense: true,
    tileColor: index % 2 == 0 ? kPrimaryColorBlack : kPrimaryColorBlack1,
    minVerticalPadding: 15,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '${index + 1}.',
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontSize: 20),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: CachedNetworkImage(
              fadeInCurve: Curves.ease,
              imageUrl: finised ? '$serverURL${model.winners![index].account_image}' : '$serverURL${model.participated_users![index].userImage}',
              imageBuilder: (context, imageProvider) => Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            finised ? model.winners![index].account_nickname.toString() : model.participated_users![index].userName.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 20),
          ),
        ),
      ],
    ),
  );
}

Container type3PageTypeDuo({required int index, required TournamentModel model, required bool finised}) {
  return Container(
    height: 250,
    width: Get.size.width,
    color: kPrimaryColorBlack1,
    margin: const EdgeInsets.all(15),
    child: Column(
      children: [
        topTeamPart(index),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [withUser(), emptyUser(100)],
          ),
        ),
      ],
    ),
  );
}

Container type3PageSquad({required int index, required TournamentModel model, required bool finised}) {
  return Container(
    height: 400,
    width: Get.size.width,
    color: kPrimaryColorBlack1,
    margin: const EdgeInsets.all(15),
    child: Column(
      children: [
        topTeamPart(index),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [withUser(), emptyUser(80)],
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [withUser(), emptyUser(80)],
          ),
        ),
      ],
    ),
  );
}

Expanded topTeamPart(int index) {
  return Expanded(
    flex: 1,
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 14,
              top: 5,
            ),
            child: Text(
              'Team ${index + 1}',
              style: const TextStyle(color: Colors.white, fontFamily: josefinSansBold, fontSize: 20),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipPath(
            clipper: SkewCut1(),
            child: Container(
              color: kPrimaryColorBlack,
            ),
          ),
        ),
      ],
    ),
  );
}

Expanded withUser() {
  return Expanded(
    child: Container(
      color: kPrimaryColorBlack1,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius10,
              child: Image.asset(
                'assets/image/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: kPrimaryColorBlack,
                borderRadius: borderRadius5,
              ),
              padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
              child: const Text(
                'Uc Dayy',
                style: TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Expanded emptyUser(double size) {
  return Expanded(
    child: GestureDetector(
      onTap: () async {
        final token = await Auth().getToken();
        if (token != null && token != '') {
          showSnackBar('tournamentInfo11', 'participateError', Colors.green);
        } else {
          showSnackBar('loginError', 'loginErrorTurnir', Colors.red);
        }
      },
      child: Container(
        height: Get.size.height,
        decoration: BoxDecoration(
          color: kPrimaryColorBlack.withOpacity(0.4),
          borderRadius: borderRadius10,
        ),
        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 12, right: 12),
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
        child: Icon(
          CupertinoIcons.person_alt_circle,
          size: size,
          color: Colors.grey,
        ),
      ),
    ),
  );
}

class SkewCut1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);
    path.lineTo(50, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(SkewCut1 oldClipper) => false;
}

dynamic subscribeTurnir({required String price, required int id, required int tournamentType, required TournamentModel turnir}) {
  Get.defaultDialog(
    title: 'correctData'.tr,
    backgroundColor: kPrimaryColorBlack,
    titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    radius: 15,
    titlePadding: const EdgeInsets.only(top: 15),
    content: FutureBuilder<GetMeModel>(
      future: GetMeModel().getMe(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: spinKit());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else if (snapshot.data == null) {
          return const Center(child: Text('Empty'));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'correctData1'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
              child: Text(
                '${'accountDetaile1'.tr} ${snapshot.data!.nickname}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${'accountDetaile2'.tr} ${snapshot.data!.pubgId}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            if (price.toString() != 'null')
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 20),
                child: Text(
                  '${'accountDetaile5'.tr} $price TMT',
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
                ),
              )
            else
              const SizedBox.shrink(),
            AgreeButton(
              name: 'agree',
              onTap: () {
                // Get.back();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellctTeam(turnir: turnir)));

                // participateTournament(id: id, tournamentType: tournamentType, price: price);
              },
            ),
          ],
        );
      },
    ),
  );
}

dynamic subscribeTurnirAlart({
  required String price,
}) {
  Get.defaultDialog(
    title: 'correctData'.tr,
    backgroundColor: kPrimaryColorBlack,
    titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    radius: 15,
    titlePadding: const EdgeInsets.only(top: 15),
    content: FutureBuilder<dynamic>(
      future: AddAccountModel().getConsts(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: spinKit());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else if (snapshot.data == null) {
          return const Center(child: Text('Empty'));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'correctData1'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                snapshot.data!['text_three'],
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            AgreeButton(
              name: 'agree',
              onTap: () {
                Get.back();
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellctTeam(turnir: turnir)));

                // participateTournament(id: id, tournamentType: tournamentType, price: price);
              },
            ),
          ],
        );
      },
    ),
  );
}

dynamic subscribeTurnirPost({required String price, required int id, required String tournamentType}) {
  Get.defaultDialog(
    title: 'correctData'.tr,
    backgroundColor: kPrimaryColorBlack,
    titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    radius: 15,
    titlePadding: const EdgeInsets.only(top: 15),
    content: FutureBuilder<GetMeModel>(
      future: GetMeModel().getMe(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: spinKit());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else if (snapshot.data == null) {
          return const Center(child: Text('Empty'));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'correctData1'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
              child: Text(
                '${'accountDetaile1'.tr} ${snapshot.data!.nickname}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${'accountDetaile2'.tr} ${snapshot.data!.pubgId}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
              ),
            ),
            if (price.toString() != 'null')
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 20),
                child: Text(
                  '${'accountDetaile5'.tr} $price TMT',
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
                ),
              )
            else
              const SizedBox.shrink(),
            AgreeButton(
              name: 'agree',
              onTap: () {
                // participateTournament(id: id, tournamentType: tournamentType, price: price);
              },
            ),
          ],
        );
      },
    ),
  );
}

dynamic participateTournament({
  required int id,
  required int tournamentType,
  required String price,
}) {
  if (int.parse(price) > int.parse(Get.find<WalletController>().userMoney.value.toString())) {
    showSnackBar('Pul yetenok', 'Gorenokmy sony mal', Colors.red);
  } else {
    TournamentModel().participateTournament(tournamentID: id).then((value) {
      if (value == 200) {
        Get.back();
        Get.back();
        TournamentModel().getTournaments(type: tournamentType);
        Get.find<WalletController>().getUserMoney();

        showSnackBar('tournamentInfo18', 'tournamentInfo17', kPrimaryColor);
      } else if (value == 404) {
        Get.back();
        showSnackBar('money_error_title', 'money_error_subtitle', Colors.red);
      } else if (value == 400) {
        Get.back();
        showSnackBar('tournamentInfo19', 'tournamentInfo21', Colors.red);
      } else {
        Get.back();
        showSnackBar('noConnection3', 'tournamentInfo19', Colors.red);
      }
    });
  }
}
