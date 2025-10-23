class Transfer {
  final int id;
  final int sender;
  final int receiver;
  final double amount;
  final DateTime createdDate;

  Transfer({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.createdDate,
  });

  /// Returns the recipient ID for the given current user
  int getRecipient(int currentUserId) {
    return sender == currentUserId ? receiver : sender;
  }

  /// Returns "sent" if this transfer was sent by the current user, else "received"
  String getTransferType(int currentUserId) {
    return sender == currentUserId ? 'sent' : 'received';
  }

  /// Factory constructor for creating a Transfer from JSON
  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      sender: json['sender'] is String ? int.parse(json['sender']) : json['sender'] as int,
      receiver: json['receiver'] is String ? int.parse(json['receiver']) : json['receiver'] as int,
      amount: json['amount'] is String ? double.parse(json['amount']) : (json['amount'] as num).toDouble(),
      createdDate: DateTime.parse(json['created_date'] as String),
    );
  }

  /// Converts the Transfer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'created_date': createdDate.toIso8601String(),
    };
  }
}
