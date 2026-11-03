// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// The prize list of a tournament: one row per place, the first three in medal colors.
class TabPage2 extends StatelessWidget {
  final TournamentModel model;

  const TabPage2({
    required this.model,
    super.key,
  });

  static const _medals = [Color(0xFFFFC83D), Color(0xFFD5D9E0), Color(0xFFE0955A)];

  /// "1000.00" → "1000", "12.50" → "12.5".
  String _amount(String? value) {
    final number = double.tryParse(value ?? '');
    if (number == null) {
      return value ?? '';
    }
    return number == number.roundToDouble() ? '${number.toInt()}' : number.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final awards = model.awards ?? const [];
    if (awards.isEmpty) {
      return Center(
        child: CatalogEmptyState(icon: Icons.emoji_events_outlined, title: 'tournamentInfo2'.tr, description: ''),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: awards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final medal = index < 3 ? _medals[index] : null;
        final color = medal ?? Colors.white70;
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (medal ?? Colors.white).withValues(alpha: medal == null ? 0.07 : 0.35)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [medal == null ? const Color(0xFF232327) : medal.withValues(alpha: 0.16), const Color(0xFF161618)],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.16), border: Border.all(color: color.withValues(alpha: 0.5))),
                child: index == 0
                    ? HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: color, size: 20, strokeWidth: 1.8)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(color: color, fontFamily: gilroyBold, fontSize: 17),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${index + 1}. ${'tournamentInfo2'.tr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 14),
                ),
              ),
              Text(
                _amount(awards[index].award),
                style: TextStyle(color: medal ?? Colors.white, fontFamily: gilroyBold, fontSize: 24),
              ),
              const SizedBox(width: 6),
              const Text(
                'TMT',
                style: TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
