/// `GET /accounts/premium/`: the premium status of the player and the current price.
class PremiumStatus {
  const PremiumStatus({
    required this.premium,
    required this.daysLeft,
    required this.price,
    required this.days,
    this.until,
  });

  final bool premium;
  final int daysLeft;

  /// What one purchase costs, in points.
  final double price;

  /// How many days one purchase gives.
  final int days;
  final String? until;

  static double _num(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  factory PremiumStatus.fromJson(dynamic json) {
    final map = json is Map ? json : const <dynamic, dynamic>{};
    return PremiumStatus(
      premium: map['premium'] == true,
      daysLeft: _num(map['premium_days_left']).toInt(),
      price: _num(map['price']),
      days: _num(map['days']).toInt(),
      until: map['premium_until'] is String ? map['premium_until'] as String : null,
    );
  }

  /// "100.00" → "100".
  String get priceText => price == price.roundToDouble() ? '${price.toInt()}' : price.toStringAsFixed(1);
}
