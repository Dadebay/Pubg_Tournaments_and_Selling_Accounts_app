/// Models of the support chat (`/api/support/`).
int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

class SupportChat {
  const SupportChat({required this.id, required this.status});

  final int id;

  /// `open` or `closed`.
  final String status;

  bool get isClosed => status == 'closed';

  factory SupportChat.fromJson(Map<dynamic, dynamic> json) {
    return SupportChat(id: _int(json['id']), status: '${json['status'] ?? 'open'}');
  }
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.mine,
    required this.body,
    required this.image,
    required this.createdAt,
    required this.admin,
    this.pending = false,
    this.failed = false,
  });

  final int id;
  final bool mine;
  final String body;
  final String? image;
  final DateTime createdAt;

  /// Name of the support agent (admin messages only).
  final String? admin;

  /// Shown at once while the request is still on its way / after it failed.
  final bool pending;
  final bool failed;

  factory SupportMessage.fromJson(Map<dynamic, dynamic> json) {
    final image = json['image'];
    return SupportMessage(
      id: _int(json['id']),
      mine: json['mine'] == true || json['sender'] == 'user',
      body: '${json['body'] ?? ''}',
      image: image is String && image.isNotEmpty ? image : null,
      createdAt: DateTime.tryParse('${json['created_date']}')?.toLocal() ?? DateTime.now(),
      admin: json['admin'] is String ? json['admin'] as String : null,
    );
  }

  SupportMessage copyWith({bool? pending, bool? failed}) {
    return SupportMessage(
      id: id,
      mine: mine,
      body: body,
      image: image,
      createdAt: createdAt,
      admin: admin,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }
}

/// One page of `GET /support/chats/{id}/messages/`, oldest first.
class SupportMessages {
  const SupportMessages({
    required this.messages,
    required this.hasMore,
    required this.status,
  });

  final List<SupportMessage> messages;
  final bool hasMore;
  final String status;

  factory SupportMessages.fromJson(dynamic json) {
    final map = json is Map ? json : const <dynamic, dynamic>{};
    final raw = map['messages'];
    return SupportMessages(
      messages: raw is List ? raw.whereType<Map>().map(SupportMessage.fromJson).toList() : const [],
      hasMore: map['has_more'] == true,
      status: '${map['status'] ?? 'open'}',
    );
  }
}
