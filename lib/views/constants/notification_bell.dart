import 'package:flutter/material.dart';
import 'package:game_app/controllers/notification_badge_controller.dart';
import 'package:game_app/views/user_profil/pages/notification.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// A bell for the top bar with the number of notifications not opened yet.
/// A tap opens the notifications, where the new ones are marked.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationBadgeController _badge =
      Get.isRegistered<NotificationBadgeController>()
      ? Get.find<NotificationBadgeController>()
      : Get.put(NotificationBadgeController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _badge.refreshCount();
  }

  Future<void> _open() async {
    await Get.to(() => NotificationPage());
    await _badge.refreshCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification03,
                  color: Colors.white,
                  size: 21,
                  strokeWidth: 1.8,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Obx(() {
                final count = _badge.unseen.value;
                return AnimatedScale(
                  scale: count > 0 ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 19),
                    height: 19,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A5F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.8),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        height: 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
