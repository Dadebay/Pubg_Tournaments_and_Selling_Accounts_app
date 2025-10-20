// ignore_for_file: file_names
import 'dart:math';

import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../cards/tournament_card.dart';

class TournamentPage extends StatefulWidget {
  final int tournamentType;
  const TournamentPage({required this.tournamentType, super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final TournamentController controller = Get.put(TournamentController());

  @override
  void initState() {
    super.initState();
    TournamentModel().getTournaments(type: widget.tournamentType);
    Get.find<WalletController>().getUserMoney();
  }

  TabBar tabbar() {
    final List<Tab> tabs = [];

    // Always show 'tournament'
    tabs.add(Tab(text: 'tournament'.tr));

    // Only show 'endTournament' if tournamentType == 2
    if (widget.tournamentType == 2) {
      tabs.add(Tab(text: 'endTournament'.tr));
    } else {
      tabs.add(const Tab(text: 'Yarym Final'));
      tabs.add(const Tab(text: 'Final'));
      tabs.add(const Tab(text: 'Bayraklar'));
    }

    return TabBar(
      isScrollable: widget.tournamentType == 2 ? false : true,
      tabAlignment: widget.tournamentType == 2 ? TabAlignment.fill : TabAlignment.start,
      labelStyle: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 20),
      unselectedLabelStyle: const TextStyle(fontFamily: josefinSansMedium, fontSize: 18),
      labelColor: kPrimaryColor,
      unselectedLabelColor: Colors.grey,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: kPrimaryColor,
      indicatorWeight: 2,
      tabs: tabs,
    );
  }

  Widget page2(int length) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemExtent: 220,
      itemCount: length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return TournamentCard(
          index: index,
          finised: true,
          tournamentType: widget.tournamentType,
          tournamentModel: TournamentModel.fromJson(controller.tournamentFinisedList[index]),
        );
      },
    );
  }

  Widget page1(int length) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemExtent: 220,
      itemCount: length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return TournamentCard(
          index: index,
          finised: false,
          tournamentType: widget.tournamentType,
          tournamentModel: TournamentModel.fromJson(controller.tournamentList[index]),
        );
      },
    );
  }

  Widget emptyPage() {
    return Center(
      child: noData('cannot_find_data_tournament'),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await TournamentModel().getTournaments(type: widget.tournamentType);
    Get.find<WalletController>().getUserMoney();
    setState(() {});
    _refreshController.refreshCompleted();
  }

  List<Widget> _buildTabViews() {
    final List<Widget> tabViews = [];

    // Always add active tournaments
    tabViews.add(
      controller.tournamentList.isEmpty ? emptyPage() : page1(controller.tournamentList.length),
    );

    if (widget.tournamentType == 2) {
      // Add finished tournaments for Squad type
      tabViews.add(
        controller.tournamentFinisedList.isEmpty ? emptyPage() : page2(controller.tournamentFinisedList.length),
      );
    } else {
      // Add Yarym Final, Final, and Bayraklar tabs
      // You'll need to implement these pages based on your data structure
      tabViews.add(emptyPage()); // Yarym Final placeholder
      tabViews.add(emptyPage()); // Final placeholder
      tabViews.add(emptyPage()); // Bayraklar placeholder
    }

    return tabViews;
  }

  @override
  Widget build(BuildContext context) {
    int tabLength = 1; // tournament is always there
    if (widget.tournamentType == 2) {
      tabLength++; // add endTournament
    } else {
      tabLength += 3; // add Yarym Final + Final + Bayraklar
    }

    return DefaultTabController(
      length: tabLength,
      child: SafeArea(
        child: Scaffold(
          appBar: MyAppBar(
            fontSize: 22.0,
            backArrow: true,
            iconRemove: false,
            icon: userAppBarMoney(),
            name: 'tournament',
            elevationWhite: true,
          ),
          backgroundColor: kPrimaryColorBlack,
          body: SmartRefresher(
            footer: footer(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            enablePullUp: false,
            header: const MaterialClassicHeader(
              color: kPrimaryColor,
            ),
            child: Obx(() {
              if (controller.tournamentLoading.value == 0) {
                return Center(
                  child: spinKit(),
                );
              } else if (controller.tournamentLoading.value == 1) {
                return const Center(
                  child: Text('cannot_find_data_tournament'),
                );
              }

              return Column(
                children: [
                  tabbar(),
                  Expanded(
                    child: TabBarView(
                      children: _buildTabViews(),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
