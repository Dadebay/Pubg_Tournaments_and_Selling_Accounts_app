// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/tournament_page/tab_page1.dart';
import 'package:game_app/views/tournament_page/tab_page2.dart';

import '../../controllers/settings_controller.dart';
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
    await TournamentModel().checkStatus(tournamentID: widget.tournamentId, value: false).then((value) {
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
                return Center(child: spinKit());
              } else if (snapshot.hasError) {
                return errorData(onTap: () {});
              } else if (snapshot.data == null) {
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
                  TabPage2(
                    model: snapshot.data!,
                  ),
                  snapshot.data!.participated_users!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('tournamentInfo13'.tr),
                          ),
                        )
                      : TabPage3(
                          tournamentType: widget.tournamentType,
                          finised: widget.finised,
                          model: snapshot.data!,
                          tournamentId: widget.tournamentId,
                          teams: TeamUsers(),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SliverAppBar appBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: true,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColorBlack,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: const Icon(
          IconlyLight.arrowLeftCircle,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        color: kPrimaryColorBlack1,
        height: Get.size.height,
        width: Get.size.width,
        child: Stack(
          children: [
            Hero(
              tag: widget.tag,
              child: CachedNetworkImage(
                fadeInCurve: Curves.ease,
                imageUrl: widget.image,
                imageBuilder: (context, imageProvider) => Container(
                  width: Get.size.width,
                  decoration: BoxDecoration(
                    color: kPrimaryColorBlack,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(child: spinKit()),
                errorWidget: (context, url, error) => const Text('No Image'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: kPrimaryColorBlack,
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: kPrimaryColor,
                  labelStyle: const TextStyle(fontFamily: gilroySemiBold, fontSize: 20),
                  unselectedLabelStyle: const TextStyle(fontFamily: gilroyMedium, fontSize: 18),
                  labelColor: Colors.white,
                  isScrollable: widget.finised ? false : true,
                  indicatorWeight: 4,
                  indicatorPadding: const EdgeInsets.only(
                    top: 45,
                  ),
                  indicator: const BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      text: 'tournamentInfo1'.tr,
                    ),
                    Tab(
                      text: 'tournamentInfo2'.tr,
                    ),
                    Tab(
                      text: widget.finised ? 'tournamentInfo3'.tr : 'tournamentInfo4'.tr,
                    ),
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
