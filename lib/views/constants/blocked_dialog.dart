import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _red = Color(0xFFFF6B6B);

/// What the server says about a ban (`get-my-account`, or the body of a 403 with `code: "blocked"`):
/// the reason, whether it is forever and, for a timed ban, when it ends.
class BanInfo {
  const BanInfo({required this.reason, required this.permanent, required this.end});

  final String reason;
  final bool permanent;

  /// When a timed ban ends (null for a permanent ban or when the server did not say).
  final DateTime? end;

  factory BanInfo.fromJson(Map json) {
    final permanent = json['ban_permanent'] == true;
    final seconds = int.tryParse('${json['ban_seconds_left'] ?? ''}');
    // The seconds left do not depend on the phone's clock being right, so they come first.
    final end = permanent ? null : (seconds != null ? DateTime.now().add(Duration(seconds: seconds)) : DateTime.tryParse('${json['blocked_until'] ?? json['block_end_date'] ?? ''}')?.toLocal());
    return BanInfo(reason: json['block_reason'] == null ? '' : '${json['block_reason']}', permanent: permanent, end: end);
  }
}

/// Shows the ban dialog once, whatever asks for it (the home page or a 403 answer).
class BlockGuard {
  const BlockGuard._();

  static bool _open = false;

  /// Returns true when the time ran out and the player pressed "continue".
  static Future<bool> show(BanInfo ban, {BuildContext? context}) async {
    final target = context ?? Get.context;
    if (_open || target == null) {
      return false;
    }
    _open = true;
    try {
      final result = await showDialog<bool>(
        context: target,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        builder: (context) => _BlockedDialog(ban: ban),
      );
      return result == true;
    } finally {
      _open = false;
    }
  }
}

/// Tells a blocked player why they are blocked and counts down the time that is left
/// (days, hours, minutes, seconds), or says the ban is permanent. Returns true when the
/// time has run out and the player pressed "continue", so the caller can ask the server again.
Future<bool> showBlockedDialog(BuildContext context, {required BanInfo ban}) => BlockGuard.show(ban, context: context);

class _BlockedDialog extends StatefulWidget {
  const _BlockedDialog({required this.ban});

  final BanInfo ban;

  DateTime? get end => ban.end;

  @override
  State<_BlockedDialog> createState() => _BlockedDialogState();
}

class _BlockedDialogState extends State<_BlockedDialog> {
  Timer? _timer;
  Duration? _left;

  @override
  void initState() {
    super.initState();
    _tick();
    if (widget.ban.end != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    final end = widget.ban.end;
    if (end == null) {
      return;
    }
    final left = end.difference(DateTime.now());
    if (mounted) {
      setState(() => _left = left.isNegative ? Duration.zero : left);
    }
    if (left.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _until(DateTime end) => '${_two(end.day)}.${_two(end.month)}.${end.year}  ${_two(end.hour)}:${_two(end.minute)}';

  Widget _box(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: _red.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 26, height: 1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.ban.end;
    final left = _left;
    final ended = end != null && left != null && left == Duration.zero;
    final reason = widget.ban.reason.trim().isEmpty ? 'blockNoReason'.tr : widget.ban.reason.trim();
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.size.height * 0.88),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _red.withValues(alpha: 0.4)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E1A1A), Color(0xFF131315)]),
            boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.18), blurRadius: 36)],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withValues(alpha: 0.14),
                    border: Border.all(color: _red.withValues(alpha: 0.55), width: 1.6),
                  ),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedUserBlock01, color: _red, size: 34, strokeWidth: 1.8),
                ),
                const SizedBox(height: 14),
                Text(
                  'blockTitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'blockReason'.tr,
                        style: const TextStyle(color: _red, fontFamily: gilroySemiBold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 16, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (end == null)
                  Text(
                    'blockNoEnd'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 15),
                  )
                else if (ended)
                  Text(
                    'blockEnded'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF34D399), fontFamily: gilroyBold, fontSize: 17),
                  )
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'blockLeft'.tr,
                      style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroySemiBold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _box('${(left ?? Duration.zero).inDays}', 'blockDays'.tr),
                      const SizedBox(width: 8),
                      _box(_two((left ?? Duration.zero).inHours % 24), 'blockHours'.tr),
                      const SizedBox(width: 8),
                      _box(_two((left ?? Duration.zero).inMinutes % 60), 'blockMinutes'.tr),
                      const SizedBox(width: 8),
                      _box(_two((left ?? Duration.zero).inSeconds % 60), 'blockSeconds'.tr),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${'blockUntil'.tr}: ${_until(end)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    if (ended) {
                      Navigator.pop(context, true);
                    } else {
                      Auth().removeToken();
                      exit(0);
                    }
                  },
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: ended ? const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]) : null,
                      color: ended ? null : Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      (ended ? 'blockContinue' : 'Düşnükli').tr,
                      style: TextStyle(color: ended ? const Color(0xFF1A1200) : Colors.white, fontFamily: gilroyBold, fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
