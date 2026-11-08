/// Models of the lucky wheel (`/api/games/lucky/`). The answers are read
/// leniently: numbers may arrive as numbers or as strings.
double _num(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

double? _positive(double? value) => value != null && value > 0 ? value : null;

class LuckyPrize {
  const LuckyPrize({required this.id, required this.label, required this.points});

  final int id;

  /// The text on the slice, e.g. "100 TMT".
  final String label;
  final double points;

  factory LuckyPrize.fromJson(Map<dynamic, dynamic> json) {
    final points = _num(json['points']);
    final label = '${json['label'] ?? ''}'.trim();
    return LuckyPrize(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      label: label.isEmpty || double.tryParse(label) != null ? '${points == points.roundToDouble() ? points.toInt() : points} TMT' : label,
      points: points,
    );
  }
}

class LuckyGame {
  const LuckyGame({required this.id, required this.title, required this.status, required this.winners, required this.winnersLeft, required this.prizes, this.spinPrice});

  final int id;
  final String title;

  /// `live`, `upcoming`, `ended`, `full` or `off`.
  final String status;
  final int? winners;
  final int? winnersLeft;

  /// The slices of the wheel, in order.
  final List<LuckyPrize> prizes;
  final double? spinPrice;

  bool get isLive => status == 'live';

  factory LuckyGame.fromJson(Map<dynamic, dynamic> json) {
    final prizes = json['prizes'];
    return LuckyGame(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? json['name'] ?? ''}',
      status: '${json['status'] ?? ''}'.toLowerCase(),
      winners: json['winners'] == null ? null : int.tryParse('${json['winners']}'),
      winnersLeft: json['winners_left'] == null ? null : int.tryParse('${json['winners_left']}'),
      prizes: prizes is List ? prizes.whereType<Map>().map(LuckyPrize.fromJson).toList() : const [],
      spinPrice: json['spin_price'] == null ? null : _num(json['spin_price']),
    );
  }
}

/// `GET /games/lucky/`: the games to show and the player's cashback.
class LuckyData {
  const LuckyData({required this.cashback, required this.spinsLeft, required this.spinPrice, required this.games});

  final double cashback;

  /// `floor(cashback)`: one spin costs 1 cashback.
  final int spinsLeft;
  final double? spinPrice;
  final List<LuckyGame> games;

  factory LuckyData.fromJson(dynamic json) {
    final map = json is Map ? json : const <dynamic, dynamic>{};
    // The server answers with one `game` object (without an id) or a list.
    final raw = map['games'] ?? map['results'] ?? (map['game'] is Map ? [map['game']] : null) ?? (json is List ? json : const []);
    final games = raw is List ? raw.whereType<Map>().map(LuckyGame.fromJson).toList() : <LuckyGame>[];
    final cashback = _num(map['cashback']);
    return LuckyData(
      cashback: cashback,
      spinsLeft: map['spins_left'] == null ? cashback.floor() : (int.tryParse('${map['spins_left']}') ?? cashback.floor()),
      // `null` (or 0) means buying spins is off: the buy button is hidden.
      spinPrice: _positive(map['spin_price'] == null ? (games.isEmpty ? null : games.first.spinPrice) : _num(map['spin_price'])),
      games: games,
    );
  }
}

/// `POST /games/lucky/{id}/spin/`.
class LuckySpinResult {
  const LuckySpinResult({required this.won, required this.points, required this.prizeLabel, required this.prizeIndex, required this.prizeId, required this.cashback, required this.pointsBalance});

  final bool won;
  final double points;
  final String? prizeLabel;

  /// The slice the wheel has to stop on, or -1 when the server did not say.
  final int prizeIndex;

  /// Id of the won slice, when the server sends the prize object with one.
  final int? prizeId;
  final double cashback;
  final double? pointsBalance;

  factory LuckySpinResult.fromJson(Map<dynamic, dynamic> json) {
    final prize = json['prize'];
    final cashback = json['cashback'] ?? json['cashback_left'];
    return LuckySpinResult(
      won: json['won'] == true,
      points: _num(json['points']),
      prizeLabel: prize is Map ? '${prize['label'] ?? ''}' : (prize == null ? null : '$prize'),
      prizeIndex: int.tryParse('${json['prize_index']}') ?? -1,
      prizeId: prize is Map ? int.tryParse('${prize['id']}') : null,
      cashback: _num(cashback),
      pointsBalance: json['points_balance'] == null ? null : _num(json['points_balance']),
    );
  }
}
