import 'package:flutter/widgets.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:get/get.dart';

/// The number of notifications this account has not opened, from the server
/// (`GET /notifications/unread/`). It is refreshed on start, when the app comes back,
/// when an `EVENT` push arrives, after reading and cleared on logout.
class NotificationBadgeController extends GetxController with WidgetsBindingObserver {
  /// Unread notifications of the account.
  final RxInt unseen = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshCount();
    }
  }

  Future<void> refreshCount() async {
    try {
      final result = await UcdayyApi.getNotificationsUnread();
      final data = result.data;
      if (result.ok && data is Map) {
        unseen.value = int.tryParse('${data['unread']}') ?? 0;
      } else if (result.statusCode == 401) {
        // A guest has no read state.
        unseen.value = 0;
      }
    } catch (_) {
      // The badge simply keeps its last value when the request fails.
    }
  }

  /// One notification was read here.
  void decrement() {
    if (unseen.value > 0) {
      unseen.value--;
    }
  }

  void clear() => unseen.value = 0;
}
