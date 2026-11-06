// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import '../../models/tournament_model.dart';
import '../cards/gatnashyanlar_card.dart';

/// A winning team: the shared team card with the gold crown.
// ignore: must_be_immutable
class WinnersAll extends StatelessWidget {
  final Winners winners;
  final TeamUsers team_users;
  final int usersCount;

  const WinnersAll({required this.winners, required this.usersCount, required this.team_users, super.key});

  @override
  Widget build(BuildContext context) {
    final users = winners.teamUsers ?? const <TeamUsers>[];
    return TeamShell(
      number: winners.team_number,
      filled: users.length,
      total: usersCount,
      winner: true,
      children: [for (var i = 0; i < usersCount; i++) users.length >= i + 1 ? GatnashyanlarCard(teamUsers: users[i], teamID: '', showButton: false, turnirID: '') : const TeamEmptySlot()],
    );
  }
}
