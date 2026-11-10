import 'package:flutter/material.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// A chat bubble for the left of the top bar: opens the support chat and shows
/// the number of unread answers of the support team.
class SupportChatButton extends StatefulWidget {
  const SupportChatButton({this.floating = false, super.key});

  /// A bigger, filled bubble for a floating action button.
  final bool floating;

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
          width: widget.floating ? 62 : 46,
          height: widget.floating ? 62 : 46,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.floating ? 56 : 40,
                height: widget.floating ? 56 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.floating ? const Color(0xFFFFC83D) : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(color: widget.floating ? Colors.transparent : Colors.white.withValues(alpha: 0.14)),
                  boxShadow: widget.floating ? [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))] : null,
                ),
                child: Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: widget.floating ? const Color(0xFF1A1200) : Colors.white, size: widget.floating ? 26 : 21, strokeWidth: 1.8),
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
