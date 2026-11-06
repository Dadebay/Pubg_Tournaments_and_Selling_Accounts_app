import 'package:flutter/material.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// A chat bubble for the left of the top bar: opens the support chat and shows
/// the number of unread answers of the support team.
class SupportChatButton extends StatefulWidget {
  const SupportChatButton({super.key});

  @override
  State<SupportChatButton> createState() => _SupportChatButtonState();
}

class _SupportChatButtonState extends State<SupportChatButton> {
  @override
  void initState() {
    super.initState();
    SupportPush.refreshUnread();
  }

  Future<void> _open() async {
    await Get.to(() => const SupportChatPage());
    await SupportPush.refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: Center(
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
                  child: HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: Colors.white, size: 21, strokeWidth: 1.8),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: SupportPush.unread,
                  builder: (context, unread, _) {
                    if (unread <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      constraints: const BoxConstraints(minWidth: 19),
                      height: 19,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A5F),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      child: Text(unread > 99 ? '99+' : '$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
