// ignore_for_file: file_names

import 'package:game_app/views/cards/tournament_image.dart';
import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/tournament_page/tab_page1.dart';
import 'package:game_app/views/tournament_page/tab_page2.dart';

import 'package:hugeicons/hugeicons.dart';

import '../../controllers/settings_controller.dart';
import '../constants/catalog_empty_state.dart';
import '../constants/index.dart';
import 'tab_page3.dart';

class TournamentProfilPage extends StatefulWidget {
  final String tag;
  final String image;
  final int tournamentId;
  final bool finised;
  final int tournamentType;
  final TournamentModel winners;
  const TournamentProfilPage({
    required this.tag,
    required this.image,
    required this.tournamentId,
    required this.finised,
    required this.tournamentType,
    required this.winners,
    super.key,
  });

  @override
  State<TournamentProfilPage> createState() => _TournamentProfilPageState();
}

class _TournamentProfilPageState extends State<TournamentProfilPage> {
  final TournamentController controller = Get.put(TournamentController());
  String buttonName = 'tournamentInfo11'.tr;
  @override
  void initState() {
    super.initState();
    Get.find<SettingsController>().agreeButton.value = false;
    checkStatus();
  }

  dynamic checkStatus() async {
    await TournamentModel()
        .checkStatus(tournamentID: widget.tournamentId, value: false)
        .then((value) {
          if (value == 200) {
            buttonName = 'tournamentInfo12';
          } else if (value == 204) {
            buttonName = 'tournamentInfo12';
          } else {
            buttonName = 'tournamentInfo11';
          }
        });
    return 'tournamentInfo11';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [appBar()];
          },
          body: FutureBuilder<TournamentModel>(
            future: TournamentModel().getTournamentID(widget.tournamentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFC83D)),
                );
              } else if (snapshot.hasError) {
                return errorData(onTap: () {});
              } else if (snapshot.data == null || snapshot.data!.id == null) {
                // The server answered "Turnir not found" (deleted or hidden): nothing to show.
                return emptyData();
              }
              return TabBarView(
                children: [
                  TabPage1(
                    finised: widget.finised,
                    model: snapshot.data!,
                    buttonName: buttonName,
                    tournamentType: widget.tournamentType,
                  ),
                  TabPage2(model: snapshot.data!),
                  _hasParticipants(snapshot.data!)
                      ? TabPage3(
                          tournamentType: widget.tournamentType,
                          finised: widget.finised,
                          model: snapshot.data!,
                          tournamentId: widget.tournamentId,
                          teams: TeamUsers(),
                        )
                      : Center(
                          child: CatalogEmptyState(
                            icon: Icons.groups_outlined,
                            title: 'tournamentInfo13'.tr,
                            description: '',
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// There is something to show in the participants tab: players listed on the tournament,
  /// teams that have players, or winners.
  bool _hasParticipants(TournamentModel model) {
    final listed = (model.participated_users ?? const []).isNotEmpty;
    final inTeams = (model.teams ?? const []).any(
      (team) => (team.teamUsers ?? const []).isNotEmpty,
    );
    final winners = (model.winners ?? const []).isNotEmpty;
    return listed || inTeams || winners;
  }

  SliverAppBar appBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColorBlack,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.tag,
              child: TournamentImage(
                imageUrl: widget.image,
                fallbackAsset: tournamentFallbackAsset(
                  finished: widget.finised,
                  id: widget.tournamentId,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                    Color(0xFF000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 62,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: Colors.white,
                  size: 20,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          height: 46,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1E),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: TabBar(
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontFamily: gilroyBold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(
              fontFamily: gilroySemiBold,
              fontSize: 14,
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white70,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
              ),
            ),
            tabs: [
              Tab(text: 'tournamentInfo1'.tr),
              Tab(text: 'tournamentInfo2'.tr),
              Tab(
                text: widget.finised
                    ? 'tournamentInfo3'.tr
                    : 'tournamentInfo4'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
