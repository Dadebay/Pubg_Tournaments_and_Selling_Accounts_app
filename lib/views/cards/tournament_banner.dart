import 'package:flutter/material.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import 'tournament_image.dart';

const _gold = Color(0xFFFFC83D);

/// The picture card of a tournament / lobby in the lists: the poster with a dark
/// fade, the title, date and time chips, and the entry price.
class TournamentBanner extends StatelessWidget {
  const TournamentBanner({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.title,
    required this.onTap,
    this.startDate,
    this.price,
    this.mode,
    this.map,
    this.badge,
    this.heroTag,
    super.key,
  });

  final String imageUrl;
  final String fallbackAsset;
  final String title;
  final VoidCallback onTap;
  final DateTime? startDate;
  final String? price;
  final String? mode;
  final String? map;

  /// A small label in the top corner, e.g. "finished".
  final String? badge;
  final Object? heroTag;

  /// "12.50" → "12.5", "100.00" → "100"; null when there is no price.
  String? get _priceText {
    final value = double.tryParse(price ?? '');
    if (value == null || value <= 0) return null;
    return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final date = startDate?.toLocal();
    final tags = [
      if (mode != null && mode!.isNotEmpty) mode!,
      if (map != null && map!.isNotEmpty) map!,
    ];
    Widget picture = TournamentImage(imageUrl: imageUrl, fallbackAsset: fallbackAsset);
    if (heroTag != null) picture = Hero(tag: heroTag!, child: picture);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF141416)]),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The poster has its own lettering, so nothing is drawn over it but the badges.
            AspectRatio(
              aspectRatio: 1.9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  picture,
                  if (_priceText != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                        ),
                        child: Text(
                          '$_priceText TMT',
                          style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 14, height: 1.1),
                        ),
                      ),
                    ),
                  if (badge != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 13, height: 1.1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20, height: 1.15),
                        ),
                        if (date != null || tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (date != null) _chip(HugeIcons.strokeRoundedCalendar03, DateFormat('dd.MM.yyyy').format(date)),
                              if (date != null) _chip(HugeIcons.strokeRoundedClock01, DateFormat('HH:mm').format(date)),
                              for (final tag in tags) _chip(null, tag),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                    child: const Center(
                      child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.black, size: 18, strokeWidth: 2.2),
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

  Widget _chip(List<List<dynamic>>? icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            HugeIcon(icon: icon, color: Colors.white, size: 13, strokeWidth: 1.8),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 12, height: 1.1),
          ),
        ],
      ),
    );
  }
}
