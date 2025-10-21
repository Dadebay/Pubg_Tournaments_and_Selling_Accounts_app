class TeamMember {
  final int id;
  final String? name;
  final String account;
  final String user1;
  final String user2;
  final String user3;
  final QuartTurnir? quartturnir; // nullable
  final dynamic halfturnir;
  final dynamic finalturnir;
  final dynamic winnerturnir;

  TeamMember({
    required this.id,
    this.name,
    required this.account,
    required this.user1,
    required this.user2,
    required this.user3,
    this.quartturnir,
    this.halfturnir,
    this.finalturnir,
    this.winnerturnir,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? 0,
      name: json['name'],
      account: json['account'] ?? '',
      user1: json['user_1'] ?? '',
      user2: json['user_2'] ?? '',
      user3: json['user_3'] ?? '',
      quartturnir: (json['quartturnir'] != null && json['quartturnir'] is Map)
          ? QuartTurnir.fromJson(json['quartturnir'])
          : null,
      halfturnir: json['halfturnir'],
      finalturnir: json['finalturnir'],
      winnerturnir: json['winnerturnir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'account': account,
      'user_1': user1,
      'user_2': user2,
      'user_3': user3,
      'quartturnir': quartturnir?.toJson(),
      'halfturnir': halfturnir,
      'finalturnir': finalturnir,
      'winnerturnir': winnerturnir,
    };
  }
}

class QuartTurnir {
  final String name;
  final DateTime? startDate;
  final DateTime? finishDate;
  final dynamic lobbiId;

  QuartTurnir({
    required this.name,
    this.startDate,
    this.finishDate,
    this.lobbiId,
  });

  factory QuartTurnir.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return QuartTurnir(
      name: json['name'] ?? '',
      startDate: parseDate(json['start_date']),
      finishDate: parseDate(json['finish_date']),
      lobbiId: json['lobbi_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate?.toIso8601String(),
      'finish_date': finishDate?.toIso8601String(),
      'lobbi_id': lobbiId,
    };
  }
}

