import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/widgets.dart';
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

  const NewTournamentCard({
    required this.filter,
    required this.index,
    required this.tournament,
    required this.finised,
    required this.tournamentType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '$serverURL${tournament.image}';

    return GestureDetector(
      onTap: () {

        if (filter == 'winners'){
           Get.to(
          () => WinnersScreen(filter:filter , tournament:  tournament,),
            
          
        );
        }else{
           Get.to(
          () => ChangeNotifierProvider(
            create: (_) => TeamMembersProvider(),
            child: QuarterGroupsScreen(filter: filter, tournament: tournament),
            // TournamentDetailPage(filter: filter, tournament: tournament),
          ),
        );
        }

        
      },
      child: Container(
        width: Get.size.width,
        margin: EdgeInsets.only(
          top: index == 0 ? 15 : 0,
          bottom: 18,
          right: 12,
          left: 12,
        ),
        decoration: BoxDecoration(
          color: kPrimaryColorBlack,
          borderRadius: borderRadius30,
          border: Border.all(color: kPrimaryColorBlack1),
        ),
        child: Stack(
          children: [
            /// 🖼 Background Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius30,
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    fadeInCurve: Curves.easeInOut,
                    imageUrl: imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius30,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(child: spinKit()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),

            /// 🕶 Dark overlay
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius30,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),

            /// 🧾 Tournament info
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: finised ? EdgeInsets.zero : const EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      finised ? 'endTournament'.tr : tournament.nameTm,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: josefinSansBold,
                        fontSize: 28,
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 6),
                    //   child: Text(
                    //     _formatDate(tournament.startDate),
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       color: Colors.white.withOpacity(0.8),
                    //       fontFamily: josefinSansSemiBold,
                    //       fontSize: 18,
                    //     ),
                    //   ),
                    // ),
                    // Text(
                    //   _formatTime(tournament.startDate),
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: Colors.white.withOpacity(0.8),
                    //     fontFamily: josefinSansSemiBold,
                    //     fontSize: 18,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Returns YYYY-MM-DD
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _formatTime(DateTime date) {
    // Returns HH:MM
    return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
