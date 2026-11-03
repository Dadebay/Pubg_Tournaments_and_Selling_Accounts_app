// ignore_for_file: file_names

import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/cards/new_tornament_card.dart';
import 'package:game_app/views/constants/balance_chip.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/home_page/paymant/data/tournament_provider.dart';
import 'package:provider/provider.dart';
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
  bool _winnersLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.tournamentType == 1) {
      Future.microtask(() => Provider.of<TournamentProvider>(context, listen: false).fetchTournaments());
      Get.find<WalletController>().getUserMoney();
    } else {
      TournamentModel().getTournaments(type: widget.tournamentType);
      Get.find<WalletController>().getUserMoney();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Run once when data first becomes available
    if (!_winnersLoaded) {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      final teamProvider = Provider.of<TeamMembersProvider>(context, listen: false);

      final tournaments = provider.tournaments;
      if (tournaments.isNotEmpty) {
        Future.microtask(() async {
          for (final t in tournaments) {
            await teamProvider.fetchTeamWinner(t.id);
          }
          setState(() {
            _winnersLoaded = true;
          });
        });
      }
    }
  }

  static const _listPadding = EdgeInsets.only(top: 4, bottom: 120);

  Widget tabbar() {
    final List<Tab> tabs = [];

    // Always show 'tournament'
    tabs.add(Tab(text: 'tournament'.tr));

    // Only show 'endTournament' if tournamentType == 2
    if (widget.tournamentType == 2) {
      tabs.add(Tab(text: 'endTournament'.tr));
    } else if (widget.tournamentType == 1) {
      // Show these tabs only for tournamentType == 1
      tabs.add(Tab(text: 'pol_final'.tr));
      tabs.add(Tab(text: 'final_tournament'.tr));
      tabs.add(Tab(text: 'prizeWinners'.tr));
    }

    return Container(
      height: 46,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1E),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: TabBar(
        isScrollable: widget.tournamentType != 2,
        tabAlignment: widget.tournamentType == 2 ? TabAlignment.fill : TabAlignment.start,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelStyle: const TextStyle(fontFamily: gilroyBold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontFamily: gilroySemiBold, fontSize: 14),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        labelPadding: const EdgeInsets.symmetric(horizontal: 18),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
        ),
        tabs: tabs,
      ),
    );
  }

  Widget page2(int length) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding,
      itemCount: length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return TournamentCard(index: index, finised: true, tournamentType: widget.tournamentType, tournamentModel: TournamentModel.fromJson(controller.tournamentFinisedList[index]));
      },
    );
  }

  Widget pageTornamend(String? filter) {
    final provider = Provider.of<TournamentProvider>(context);

    if (provider.isLoading) {
      return _skeleton();
    }
    if (provider.tournaments.isEmpty) {
      return emptyPage();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding,
      itemCount: provider.tournaments.length,
      itemBuilder: (context, index) {
        final t = provider.tournaments[index];
        return NewTournamentCard(filter: filter, index: index, finised: false, tournamentType: widget.tournamentType, tournament: t);
      },
    );
  }

  Widget page1(int length) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding,
      itemCount: length,
      itemBuilder: (context, index) {
        return TournamentCard(index: index, finised: false, tournamentType: widget.tournamentType, tournamentModel: TournamentModel.fromJson(controller.tournamentList[index]));
      },
    );
  }

  Widget emptyPage() {
    return Center(
      child: CatalogEmptyState(
        icon: widget.tournamentType == 1 ? Icons.emoji_events_outlined : Icons.sports_esports_outlined,
        title: 'cannot_find_data_tournament'.tr,
        description: '',
      ),
    );
  }

  Widget _skeleton() {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        children: [
          const ShimmerBlock(height: 46, radius: 23),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...const [ShimmerBlock(height: 200, radius: 28), SizedBox(height: 16)],
        ],
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (widget.tournamentType == 1) {
      await Provider.of<TournamentProvider>(context, listen: false).fetchTournaments();
    } else {
      await TournamentModel().getTournaments(type: widget.tournamentType);
      Get.find<WalletController>().getUserMoney();
    }

    _refreshController.refreshCompleted();
    setState(() {});
  }

  List<Widget> _buildTabViews() {
    final List<Widget> tabViews = [];

    if (widget.tournamentType == 1) {
      tabViews.add(pageTornamend('tournament'));
      tabViews.add(pageTornamend('yarym_final'));
      tabViews.add(pageTornamend('final'));
      tabViews.add(pageTornamend('winners'));
    } else if (widget.tournamentType == 2) {
      // For tournamentType == 2, show active and finished tournaments
      tabViews.add(controller.tournamentList.isEmpty ? emptyPage() : page1(controller.tournamentList.length));
      tabViews.add(controller.tournamentFinisedList.isEmpty ? emptyPage() : page2(controller.tournamentFinisedList.length));
    } else {
      // For other types, show only active tournaments
      tabViews.add(controller.tournamentList.isEmpty ? emptyPage() : page1(controller.tournamentList.length));
    }

    return tabViews;
  }

  @override
  Widget build(BuildContext context) {
    int tabLength = 1; // tournament is always there
    if (widget.tournamentType == 2) {
      tabLength++; // add endTournament
    } else if (widget.tournamentType == 1) {
      tabLength += 3; // add Yarym Final + Final + Bayraklar
    }

    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CenteredHeader(title: widget.tournamentType == 1 ? 'Turnir' : 'Lobbi', onBack: Get.back, trailing: const BalanceChip()),
              Expanded(
                child: SmartRefresher(
                  footer: footer(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  enablePullUp: false,
                  header: const MaterialClassicHeader(color: kPrimaryColor),
                  child: widget.tournamentType == 1 ? _buildProviderBody() : _buildGetXBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // For tournamentType == 1, use Provider state
  Widget _buildProviderBody() {
    final provider = Provider.of<TournamentProvider>(context);

    // Show loading while fetching
    if (provider.isLoading) {
      return _skeleton();
    }

    // Show error if there's an error message
    if (provider.errorMessage != null) {
      return emptyPage();
    }

    // Show tabs once data is loaded
    return Column(
      children: [
        tabbar(),
        Expanded(child: TabBarView(children: _buildTabViews())),
      ],
    );
  }

  // For other tournament types, use GetX state
  Widget _buildGetXBody() {
    return Obx(() {
      if (controller.tournamentLoading.value == 0) {
        return _skeleton();
      } else if (controller.tournamentLoading.value == 1) {
        return emptyPage();
      }

      return Column(
        children: [
          tabbar(),
          Expanded(child: TabBarView(children: _buildTabViews())),
        ],
      );
    });
  }
}
