import 'package:game_app/models/notifications_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Counts the notifications the user has not opened yet. The newest id seen is kept
/// on the device, so everything above it is new.
class NotificationBadgeController extends GetxController {
  static const _key = 'last_seen_notification_id';

  final GetStorage _box = GetStorage();

  /// How many notifications came after the last visit to the notification page.
  final RxInt unseen = 0.obs;

  int get lastSeenId => _box.read<int>(_key) ?? 0;

  Future<void> refreshCount() async {
    try {
      final items = await NotifcationModel().getNotifcations();
      unseen.value = items.where((item) => (item.id ?? 0) > lastSeenId).length;
    } catch (_) {
      // The badge simply keeps its last value when the request fails.
    }
  }

  /// Everything in [items] counts as seen from now on.
  Future<void> markSeen(List<NotifcationModel> items) async {
    var newest = lastSeenId;
    for (final item in items) {
      if ((item.id ?? 0) > newest) {
        newest = item.id!;
      }
    }
    await _box.write(_key, newest);
    unseen.value = 0;
  }
}
