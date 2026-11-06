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

import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

final List names = ['Turnir', 'Lobbi', 'bestPlayers2'.tr];

final List images = ['assets/image/img1.jpg', 'assets/image/img2.jpg', 'assets/image/img3.jpg'];
// 'Duo',
// 'assets/image/2.png',

dynamic tournamentCard(int index) {
  return GestureDetector(
    onTap: () {
      index == 2 ? Get.to(() => const BestPlayers()) : Get.to(() => TournamentPage(tournamentType: index + 1));
    },
    child: Container(
      width: Get.size.width,
      height: index == 2 ? 150 : 150,
      margin: const EdgeInsets.only(top: 15, bottom: 5, right: 12, left: 12),
      decoration: BoxDecoration(
        color: kPrimaryColorBlack,
        borderRadius: borderRadius30,
        border: Border.all(color: kPrimaryColorBlack1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius30,
              child: Image.asset(images[index], fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(borderRadius: borderRadius30, color: kPrimaryColorBlack.withValues(alpha: 0.4)),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                names[index],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

TabBar tabbar() {
  return TabBar(
    labelStyle: const TextStyle(fontFamily: gilroySemiBold, fontSize: 20),
    unselectedLabelStyle: const TextStyle(fontFamily: gilroyMedium, fontSize: 18),
    labelColor: kPrimaryColor,
    unselectedLabelColor: Colors.grey,
    labelPadding: const EdgeInsets.only(top: 8, bottom: 4),
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorColor: kPrimaryColor,
    indicatorWeight: 2,
    tabs: [
      Tab(text: 'tournament'.tr),
      Tab(text: 'endTournament'.tr),
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
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
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
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 20),
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
          child: Divider(color: Colors.grey),
        ),
        Expanded(flex: 5, child: Row(children: [withUser(), emptyUser(100)])),
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
          child: Divider(color: Colors.grey),
        ),
        Expanded(flex: 4, child: Row(children: [withUser(), emptyUser(80)])),
        Expanded(flex: 4, child: Row(children: [withUser(), emptyUser(80)])),
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
            padding: const EdgeInsets.only(left: 14, top: 5),
            child: Text(
              'Team ${index + 1}',
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipPath(
            clipper: SkewCut1(),
            child: Container(color: kPrimaryColorBlack),
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
              child: Image.asset('assets/image/logo.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: kPrimaryColorBlack, borderRadius: borderRadius5),
              padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
              child: const Text(
                'Uc Dayy',
                style: TextStyle(color: kPrimaryColor, fontFamily: gilroyBold, fontSize: 20),
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
        decoration: BoxDecoration(color: kPrimaryColorBlack.withValues(alpha: 0.4), borderRadius: borderRadius10),
        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 12, right: 12),
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
        child: Icon(CupertinoIcons.person_alt_circle, size: size, color: Colors.grey),
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

/// Confirmation dialog shell: icon, title, message, [body] and a gold confirm button with a cancel link.
void _showConfirmDialog({required Widget body, required VoidCallback onConfirm, String? message}) {
  const gold = Color(0xFFFFC83D);
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF121214)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.14),
                border: Border.all(color: gold.withValues(alpha: 0.45)),
              ),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedUserCheck01, color: gold, size: 28, strokeWidth: 1.8),
            ),
            const SizedBox(height: 16),
            Text(
              'correctData'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'correctData1'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 14, height: 1.3),
            ),
            const SizedBox(height: 18),
            body,
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                height: 52,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                ),
                child: Text(
                  'agree'.tr,
                  style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 17),
                ),
              ),
            ),
            TextButton(
              onPressed: Get.back,
              child: Text(
                'cancel'.tr,
                style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _dialogRow(String label, String value, {bool highlight = false, bool last = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 13),
    decoration: BoxDecoration(
      border: last ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
    ),
    child: Row(
      children: [
        Text(
          label.replaceAll(':', '').trim(),
          style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: highlight ? const Color(0xFFFFC83D) : Colors.white, fontFamily: gilroyBold, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

/// The player's PUBG name and id (and the price when there is one) inside the confirmation dialog.
Widget _accountSummary(String price) {
  final hasPrice = price.toString() != 'null';
  return FutureBuilder<GetMeModel>(
    future: GetMeModel().getMe(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(child: spinKit()),
        );
      } else if (snapshot.hasError || snapshot.data == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('Error', style: TextStyle(color: Colors.white70)),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            _dialogRow('accountDetaile1'.tr, '${snapshot.data!.nickname}'),
            _dialogRow('accountDetaile2'.tr, '${snapshot.data!.pubgId}', last: !hasPrice),
            if (hasPrice) _dialogRow('accountDetaile5'.tr, '$price TMT', highlight: true, last: true),
          ],
        ),
      );
    },
  );
}

dynamic subscribeTurnir({required String price, required int id, required int tournamentType, required TournamentModel turnir}) {
  _showConfirmDialog(
    body: _accountSummary(price),
    onConfirm: () {
      Get.back();
      Get.to(() => SellctTeam(turnir: turnir));
    },
  );
}

dynamic subscribeTurnirAlart({required String price}) {
  _showConfirmDialog(
    message: '',
    body: FutureBuilder<dynamic>(
      future: AddAccountModel().getConsts(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: spinKit()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Error', style: TextStyle(color: Colors.white70)),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white.withValues(alpha: 0.05)),
          child: Text(
            '${snapshot.data!['text_three']}',
            style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 15, height: 1.35),
          ),
        );
      },
    ),
    onConfirm: Get.back,
  );
}

dynamic subscribeTurnirPost({required String price, required int id, required String tournamentType}) {
  _showConfirmDialog(body: _accountSummary(price), onConfirm: () {});
}

dynamic participateTournament({required int id, required int tournamentType, required String price}) {
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
