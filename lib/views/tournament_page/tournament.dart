// ignore_for_file: file_names
import 'dart:math';

import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/team_member.dart';
import 'package:game_app/models/team_winers.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/cards/new_tornament_card.dart';
import 'package:game_app/views/constants/index.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.tournamentType == 1) {
      Future.microtask(() {
        Provider.of<TeamMembersProvider>(context, listen: false).fetchTeamWinner();
      });
      Future.microtask(
        () => Provider.of<TournamentProvider>(context, listen: false).fetchTournaments(),
      );
      Get.find<WalletController>().getUserMoney();
    } else {
      TournamentModel().getTournaments(type: widget.tournamentType);
      Get.find<WalletController>().getUserMoney();
    }
  }

  TabBar tabbar() {
    final List<Tab> tabs = [];

    // Always show 'tournament'
    tabs.add(Tab(text: 'tournament'.tr));

    // Only show 'endTournament' if tournamentType == 2
    if (widget.tournamentType == 2) {
      tabs.add(Tab(text: 'endTournament'.tr));
    } else if (widget.tournamentType == 1) {
      // Show these tabs only for tournamentType == 1
      tabs.add( Tab(text: 'pol_final'.tr));
      tabs.add( Tab(text: 'final_tournament'.tr));
      tabs.add( Tab(text: 'prizeWinners'.tr));
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

  Widget pageTornamend(String? filter) {
    final provider = Provider.of<TournamentProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.tournaments.isEmpty) {
      return emptyPage();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemExtent: 220,
      itemCount: provider.tournaments.length,
      itemBuilder: (context, index) {
        final t = provider.tournaments[index];
        return NewTournamentCard(
          filter: filter,
          index: index,
          finised: false,
          tournamentType: widget.tournamentType,
          tournament: t,
        );
      },
    );
  }

  Widget pageBayraklar() {
    final teamProvider = Provider.of<TeamMembersProvider>(context);
    final provider = Provider.of<TournamentProvider>(context);

    if (teamProvider.isLoading || provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (teamProvider.errorMessage != null) {
      return Center(child: Text('Error: ${teamProvider.errorMessage}'));
    }

    final winners = teamProvider.teamMembersWin;
    final tournament = provider.tournaments;

    if (winners.isEmpty) {
      return const Center(child: Text('No winners found.'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTournamentCard(tournament.first),
            const SizedBox(height: 20),
            ...winners.asMap().entries.map((entry) {
              return _buildWinnerCard(entry.value, entry.key);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final isBayrakGiven = tournament.bayrak != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1a237e),
            Color(0xFF0d47a1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.nameTm ?? tournament.nameRu ?? 'Tournament',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tournament.map ?? 'Unknown Map',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Prize Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBayrakGiven ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBayrakGiven ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isBayrakGiven ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBayrakGiven ? Icons.check_circle : Icons.pending,
                      color: isBayrakGiven ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIZE STATUS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBayrakGiven ? 'Prizes Distributed ✓' : 'Pending Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isBayrakGiven ? Colors.green.shade300 : Colors.orange.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tournament Details
            Row(
              children: [
                Expanded(
                  child: _buildTournamentInfo(
                    'ENTRY FEE',
                    '${tournament.price ?? '0'} TMT',
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTournamentInfo(
                    'MODE',
                    tournament.mode.toUpperCase() ?? 'N/A',
                    Icons.sports_esports,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(TeamMemberWin team, int index) {
    final rankColors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      [const Color(0xFFC0C0C0), const Color(0xFF808080)], // Silver
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
    ];

    final colors = index < 3 ? rankColors[index] : [Colors.grey.shade700, Colors.grey.shade600];
    final rankEmoji = index == 0
        ? '👑'
        : index == 1
            ? '🥈'
            : index == 2
                ? '🥉'
                : '🏅';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Main Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with rank
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              rankEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'RANK #${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.military_tech,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Team Name
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups,
                          color: Colors.white.withOpacity(0.9),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            team.name ?? 'Unnamed Team',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Squad Members
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MEMBERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPlayerChip(team.account, '1'),
                            _buildPlayerChip(team.user1, '2'),
                            _buildPlayerChip(team.user2, '3'),
                            _buildPlayerChip(team.user3, '4'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tournament Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'QUARTER',
                          team.quartturnir!.name ?? '-',
                          Icons.filter_1,
                        ),
                        _buildStatDivider(),
                        _buildStatItem(
                          'SEMI',
                          team.halfturnir == 'ikinjni' ? 'B2' : 'B1',
                          Icons.filter_2,
                        ),
                        _buildStatDivider(),
                        _buildStatItem(
                          'FINAL',
                          team.finalturnir?.name.toString() ?? '-',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Corner decoration
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(String? name, String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget page1(int length) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemExtent: 220,
      itemCount: length,
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
      tabViews.add(pageBayraklar());
    } else if (widget.tournamentType == 2) {
      // For tournamentType == 2, show active and finished tournaments
      tabViews.add(
        controller.tournamentList.isEmpty ? emptyPage() : page1(controller.tournamentList.length),
      );
      tabViews.add(
        controller.tournamentFinisedList.isEmpty ? emptyPage() : page2(controller.tournamentFinisedList.length),
      );
    } else {
      // For other types, show only active tournaments
      tabViews.add(
        controller.tournamentList.isEmpty ? emptyPage() : page1(controller.tournamentList.length),
      );
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
            child: widget.tournamentType == 1 ? _buildProviderBody() : _buildGetXBody(),
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
      return Center(child: spinKit());
    }

    // Show error if there's an error message
    if (provider.errorMessage != null) {
      return Center(
        child: Text(provider.errorMessage ?? 'cannot_find_data_tournament'),
      );
    }

    // Show tabs once data is loaded
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
  }

  // For other tournament types, use GetX state
  Widget _buildGetXBody() {
    return Obx(() {
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
    });
  }
}
