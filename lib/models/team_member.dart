class TeamMember {
  final int id;
  final String? name;
  final String account;
  final String user1;
  final String user2;
  final String user3;
  final String quartturnir;
  final dynamic halfturnir; // can be int or String
  final dynamic finalturnir; // can be int or String
  final dynamic winnerturnir; // new field, can be int or String

  TeamMember({
    required this.id,
    required this.account,
    required this.user1,
    required this.user2,
    required this.user3,
    required this.quartturnir,
    this.name,
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
      quartturnir: json['quartturnir'] ?? '',
      halfturnir: json['halfturnir'], // can be String or int
      finalturnir: json['finalturnir'], // can be String or int
      winnerturnir: json['winnerturnir'], // new field
    );
  }
}
