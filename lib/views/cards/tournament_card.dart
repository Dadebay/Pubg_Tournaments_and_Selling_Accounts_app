// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/tournament_page/tournament_profil_page.dart';

import '../constants/index.dart';

class TournamentCard extends StatelessWidget {
  final int index;
  final bool finised;
  final int tournamentType;
  final TournamentModel tournamentModel;
  const TournamentCard({
    required this.index,
    required this.tournamentModel,
    required this.finised,
    required this.tournamentType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => TournamentProfilPage(tag: '$serverURL${tournamentModel.image}', finised: finised, tournamentType: tournamentType, image: '$serverURL${tournamentModel.image}', tournamentId: tournamentModel.id!, winners: tournamentModel),
        );
      },
      child: Container(
        width: Get.size.width,
        margin: EdgeInsets.only(top: index == 0 ? 15 : 0, bottom: 18, right: 12, left: 12),
        decoration: BoxDecoration(color: kPrimaryColorBlack, borderRadius: borderRadius30, border: Border.all(color: kPrimaryColorBlack1)),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius30,
                child: Hero(
                  tag: '$serverURL${tournamentModel.image}',
                  child: CachedNetworkImage(
                    fadeInCurve: Curves.ease,
                    imageUrl: '$serverURL${tournamentModel.image}',
                    imageBuilder: (context, imageProvider) => Container(
                      width: Get.size.width,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius20,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(child: spinKit()),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
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
                padding: finised ? EdgeInsets.zero : const EdgeInsets.only(left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(finised ? 'endTournament'.tr : tournamentModel.title!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 28)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(tournamentModel.start_date!.substring(0, 10), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontFamily: gilroySemiBold, fontSize: 18)),
                    ),
                    Text(tournamentModel.start_date!.substring(11, 16), textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontFamily: gilroySemiBold, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
