import 'package:material_ui/material_ui.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/cards/tournament_banner.dart';
import 'package:game_app/views/cards/tournament_image.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/tournament_page/qartar_groups_screen.dart';
import 'package:game_app/views/tournament_page/winners_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NewTournamentCard extends StatelessWidget {
  final String? filter;
  final int index;
  final bool finised;
  final int tournamentType;
  final Tournament tournament;

  const NewTournamentCard({required this.filter, required this.index, required this.tournament, required this.finised, required this.tournamentType, super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = tournamentImageUrl(tournament.image);
    return TournamentBanner(
      imageUrl: imageUrl,
      fallbackAsset: tournamentFallbackAsset(finished: finised, id: tournament.id),
      heroTag: 'tournament-$tournamentType-${tournament.id}-$finised',
      title: tournament.nameTm,
      startDate: tournament.startDate,
      finishDate: tournament.finishDate,
      isFinished: finised,
      price: tournament.price,
      mode: tournament.mode,
      map: tournament.map,
      badge: finised ? 'endTournament'.tr : null,
      onTap: () {
        if (filter == 'winners') {
          Get.to(() => WinnersScreen(filter: filter, tournament: tournament));
        } else {
          Get.to(
            () => ChangeNotifierProvider(
              create: (_) => TeamMembersProvider(),
              child: QuarterGroupsScreen(filter: filter, tournament: tournament),
            ),
          );
        }
      },
    );
  }
}
