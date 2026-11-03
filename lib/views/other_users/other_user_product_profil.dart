// ignore_for_file: always_put_required_named_parameters_first

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/centered_header.dart';
import '../constants/constants.dart';

const _gold = Color(0xFFFFC83D);

/// A player of the ranking: the picture, the name, the place and the points.
class OtherUserProductProfil extends StatelessWidget {
  final String? points;
  final String? name;
  final String? image;
  final int index;
  const OtherUserProductProfil({super.key, required this.name, required this.image, required this.index, required this.points});

  Color get _color => switch (index) {
    0 => _gold,
    1 => const Color(0xFFD5D9E0),
    2 => const Color(0xFFE0955A),
    _ => const Color(0xFF60A5FA),
  };

  /// "6683.00" → "6683", "12.5" → "12.5".
  String get _pointsText {
    final value = double.tryParse(points ?? '');
    if (value == null) {
      return points ?? '0';
    }
    return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final url = image ?? '';
    final nick = (name ?? '').isEmpty ? 'Unknown' : name!;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: nick, onBack: Get.back),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withValues(alpha: 0.2), const Color(0xFF141416)]),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: 0.3)]),
                                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 24)],
                              ),
                              child: ClipOval(
                                child: url.isEmpty
                                    ? _placeholder()
                                    : CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.cover,
                                        fadeInCurve: Curves.ease,
                                        placeholder: (context, url) => const ColoredBox(color: Color(0xFF232327)),
                                        errorWidget: (context, url, error) => _placeholder(),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: -12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF141416), width: 3)),
                                child: Text(
                                  '# ${index + 1}',
                                  style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 14, height: 1.1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          nick,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 26, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withValues(alpha: 0.14), border: Border.all(color: _gold.withValues(alpha: 0.4))),
                          child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedAward01, color: _gold, size: 24, strokeWidth: 1.8)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text('userNamePlayers2'.tr, style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroySemiBold, fontSize: 16)),
                        ),
                        Text(
                          _pointsText,
                          style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 30, height: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFF232327),
      child: Center(child: Icon(Icons.person_rounded, color: Colors.white38, size: 54)),
    );
  }
}
