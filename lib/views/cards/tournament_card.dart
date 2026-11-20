// ignore_for_file: file_names

import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/cards/tournament_banner.dart';
import 'package:game_app/views/cards/tournament_image.dart';
import 'package:game_app/views/tournament_page/tournament_profil_page.dart';

import '../constants/index.dart';

class TournamentCard extends StatelessWidget {
  final int index;
  final bool finised;
  final int tournamentType;
  final TournamentModel tournamentModel;
  const TournamentCard({required this.index, required this.tournamentModel, required this.finised, required this.tournamentType, super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = tournamentImageUrl(tournamentModel.image);
    final fallbackAsset = tournamentFallbackAsset(finished: finised, id: tournamentModel.id ?? index);
    final heroTag = 'tournament-$tournamentType-${tournamentModel.id ?? index}-$finised';
    return TournamentBanner(
      imageUrl: imageUrl,
      fallbackAsset: fallbackAsset,
      heroTag: heroTag,
      title: tournamentModel.title ?? '',
      startDate: DateTime.tryParse(tournamentModel.start_date ?? ''),
      finishDate: DateTime.tryParse(tournamentModel.finish_date ?? ''),
      isFinished: finised,
      price: tournamentModel.price,
      mode: tournamentModel.mode,
      map: tournamentModel.map,
      badge: finised ? 'endTournament'.tr : null,
      onTap: () => Get.to(() => TournamentProfilPage(tag: heroTag, finised: finised, tournamentType: tournamentType, image: imageUrl, tournamentId: tournamentModel.id!, winners: tournamentModel)),
    );
  }
}
