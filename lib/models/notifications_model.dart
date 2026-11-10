import 'package:game_app/repository/ucdayy_api.dart';

class NotifcationModel {
  final int? id;
  final String? createdAt;
  final String? url;
  final String? content;
  final String? title;

  /// This account has opened the notification (kept on the server, per account).
  bool read;
  NotifcationModel({this.id, this.createdAt, this.url, this.content, this.title, this.read = false});

  factory NotifcationModel.fromJson(Map<dynamic, dynamic> json) {
    return NotifcationModel(id: json['id'], createdAt: json['created_date'], title: json['title'], content: json['description'], url: json['url'], read: json['read'] == true);
  }

  /// The notifications, newest first. With a token each carries this account's `read` state.
  Future<List<NotifcationModel>> getNotifcations() async {
    final result = await UcdayyApi.getNotifications();
    final data = result.data;
    if (!result.ok || data is! List) {
      return [];
    }
    final items = [for (final item in data.whereType<Map>()) NotifcationModel.fromJson(item)];
    items.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return items;
  }
}
