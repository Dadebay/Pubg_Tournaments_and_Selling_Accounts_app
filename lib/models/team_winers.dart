// Model for tournament stages
class TournamentStage {
  final String? name;
  final String? startDate;
  final String? finishDate;
  final String? lobbiId;
  final String? code; // Placeholder for any additional fields

  TournamentStage({
    this.name,
    this.startDate,
    this.finishDate,
    this.lobbiId,
    this.code,
  });

  factory TournamentStage.fromJson(Map<String, dynamic> json) {
    return TournamentStage(
      name: json['name'] as String?,
      startDate: json['start_date'] as String?,
      finishDate: json['finish_date'] as String?,
      lobbiId: json['lobbi_id'] as String?,
      code: json['code'] as String?,
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

// Updated TeamMember model
class TeamMemberWin {
  final int? id;
  final String? name;
  final String? account;
  final String? user1;
  final String? user2;
  final String? user3;
  final TournamentStage? quartturnir;
  final TournamentStage? halfturnir;
  final TournamentStage? finalturnir;
  final int? winnerturnir;

  TeamMemberWin({
    this.id,
    this.name,
    this.account,
    this.user1,
    this.user2,
    this.user3,
    this.quartturnir,
    this.halfturnir,
    this.finalturnir,
    this.winnerturnir,
  });

  factory TeamMemberWin.fromJson(Map<String, dynamic> json) {
    return TeamMemberWin(
      id: json['id'] as int?,
      name: json['name'] as String?,
      account: json['account'] as String?,
      user1: json['user_1'] as String?,
      user2: json['user_2'] as String?,
      user3: json['user_3'] as String?,
      quartturnir: json['quartturnir'] != null
          ? TournamentStage.fromJson(json['quartturnir'] as Map<String, dynamic>)
          : null,
      halfturnir: json['halfturnir'] != null
          ? TournamentStage.fromJson(json['halfturnir'] as Map<String, dynamic>)
          : null,
      finalturnir: json['finalturnir'] != null
          ? TournamentStage.fromJson(json['finalturnir'] as Map<String, dynamic>)
          : null,
      winnerturnir: json['winnerturnir'] as int?,
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
      'halfturnir': halfturnir?.toJson(),
      'finalturnir': finalturnir?.toJson(),
      'winnerturnir': winnerturnir,
    };
  }
}