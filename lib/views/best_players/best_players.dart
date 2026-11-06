import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/best_players_model.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:game_app/views/other_users/other_user_product_profil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _silver = Color(0xFFD5D9E0);
const _bronze = Color(0xFFE0955A);

Color _rankColor(int index) => switch (index) {
  0 => _gold,
  1 => _silver,
  2 => _bronze,
  _ => Colors.white70,
};

/// "123.00" → "123", "12.5" → "12.5".
String _pointsText(String? points) {
  final value = double.tryParse(points ?? '');
  if (value == null) return points ?? '0';
  return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);
}

String _nameOf(BestPlayersModel player) {
  final name = player.pubgUsername ?? '';
  return name.isEmpty ? 'Unknown' : name;
}

/// Empty when the player has no picture, so no request is made for it.
String _imageOf(BestPlayersModel player) {
  final image = player.image ?? '';
  if (image.isEmpty) {
    return '';
  }
  return image.startsWith('http') ? image : '$serverURL$image';
}

void _openProfile(BestPlayersModel player, int index) {
  Get.to(
    () => OtherUserProductProfil(points: player.points, name: _nameOf(player), image: _imageOf(player), index: index),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 300),
  );
}

/// The ranking of the best players: the first three on a podium, the rest as rows.
class BestPlayers extends StatefulWidget {
  const BestPlayers({super.key});

  @override
  State<BestPlayers> createState() => _BestPlayersState();
}

class _BestPlayersState extends State<BestPlayers> {
  late Future<List<BestPlayersModel>> _future = BestPlayersModel().getBestPlayers();

  Future<void> _refresh() async {
    final next = BestPlayersModel().getBestPlayers();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'bestPlayers2'.tr, onBack: Get.back),
            Expanded(
              child: FutureBuilder<List<BestPlayersModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _skeleton();
                  }
                  if (snapshot.hasError) {
                    return _message(Icons.cloud_off_rounded, 'errorLoadData'.tr);
                  }
                  final players = snapshot.data ?? const <BestPlayersModel>[];
                  if (players.isEmpty) {
                    return _message(Icons.emoji_events_outlined, 'errorLoadEmptyData'.tr);
                  }
                  return RefreshIndicator(
                    color: _gold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      children: [
                        _Podium(players: players.take(3).toList()),
                        const SizedBox(height: 22),
                        for (var i = 3; i < players.length; i++) ...[_PlayerRow(player: players[i], index: i), const SizedBox(height: 10)],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String text) {
    return RefreshIndicator(
      color: _gold,
      backgroundColor: const Color(0xFF1C1C20),
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SizedBox(
            height: box.maxHeight,
            child: Center(
              child: CatalogEmptyState(icon: icon, title: text, description: ''),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeleton() {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          const ShimmerBlock(height: 250, radius: 26),
          const SizedBox(height: 22),
          for (var i = 0; i < 6; i++) ...const [ShimmerBlock(height: 68, radius: 20), SizedBox(height: 10)],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size, required this.color});

  final String url;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: 0.35)]),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16)],
      ),
      child: ClipOval(
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xFF232327),
                child: Center(child: Icon(Icons.person_rounded, color: Colors.white38)),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => const ColoredBox(color: Color(0xFF232327)),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: Color(0xFF232327),
                  child: Center(child: Icon(Icons.person_rounded, color: Colors.white38)),
                ),
              ),
      ),
    );
  }
}

/// 2nd – 1st – 3rd, the winner standing higher and bigger.
class _Podium extends StatelessWidget {
  const _Podium({required this.players});

  final List<BestPlayersModel> players;

  @override
  Widget build(BuildContext context) {
    BestPlayersModel? at(int i) => i < players.length ? players[i] : null;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 22, 10, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold.withValues(alpha: 0.28)),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2416), Color(0xFF141416)]),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumSlot(player: at(1), index: 1, avatar: 66, lift: 22)),
          Expanded(child: _PodiumSlot(player: at(0), index: 0, avatar: 88, lift: 0)),
          Expanded(child: _PodiumSlot(player: at(2), index: 2, avatar: 66, lift: 38)),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({required this.player, required this.index, required this.avatar, required this.lift});

  final BestPlayersModel? player;
  final int index;
  final double avatar;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final player = this.player;
    if (player == null) return const SizedBox.shrink();
    final color = _rankColor(index);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openProfile(player, index),
      child: Padding(
        padding: EdgeInsets.only(top: lift),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index == 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 26, strokeWidth: 1.8),
              ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _Avatar(url: _imageOf(player), size: avatar, color: color),
                Positioned(
                  bottom: -10,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: const Color(0xFF141416), width: 2),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 13, height: 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _nameOf(player),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: index == 0 ? 17 : 15),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                _pointsText(player.points),
                style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 15, height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.index});

  final BestPlayersModel player;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openProfile(player, index),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white54, fontFamily: gilroyBold, fontSize: 17),
              ),
            ),
            _Avatar(url: _imageOf(player), size: 46, color: Colors.white24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _nameOf(player),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Text(
                _pointsText(player.points),
                style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 16, height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
