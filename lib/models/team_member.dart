class TeamMember {
  final int id;
  final String? name;
  final String account;
  final String extraName;
  final String user1;
  final String user2;
  final String user3;
  final QuartTurnir? quartturnir; // nullable
  final QuartTurnir? halfturnir;
  final QuartTurnir? finalturnir;
  final dynamic winnerturnir;

  TeamMember({
    required this.id,
    required this.account,
    required this.extraName,
    required this.user1,
    required this.user2,
    required this.user3,
    this.name,
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
      extraName: json['extra_name'] ?? '',
      user1: json['user_1'] ?? '',
      user2: json['user_2'] ?? '',
      user3: json['user_3'] ?? '',
      quartturnir: (json['quartturnir'] != null && json['quartturnir'] is Map) ? QuartTurnir.fromJson(json['quartturnir']) : null,
      halfturnir: (json['halfturnir'] != null && json['halfturnir'] is Map) ? QuartTurnir.fromJson(json['halfturnir']) : null,
      finalturnir: (json['finalturnir'] != null && json['finalturnir'] is Map) ? QuartTurnir.fromJson(json['finalturnir']) : null,
      winnerturnir: json['winnerturnir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'account': account,
      'extra_name': extraName,
      'user_1': user1,
      'user_2': user2,
      'user_3': user3,
      'quartturnir': quartturnir?.toJson(),
      'halfturnir': halfturnir?.toJson(),
      'finalturnir': finalturnir?.toJson(),
      'winnerturnir': winnerturnir,
    };
  }
}

class QuartTurnir {
  final String name;
  final String? startDate;
  final String? finishDate;
  final dynamic lobbiId;
  final dynamic code; // Placeholder for any additional fields

  QuartTurnir({
    required this.name,
    this.startDate,
    this.finishDate,
    this.lobbiId,
    this.code,
  });

  factory QuartTurnir.fromJson(Map<String, dynamic> json) {
    return QuartTurnir(
      name: json['name'] ?? '',
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      lobbiId: json['lobbi_id'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate,
      'finish_date': finishDate,
      'lobbi_id': lobbiId,
      'code': code,
    };
  }
}
