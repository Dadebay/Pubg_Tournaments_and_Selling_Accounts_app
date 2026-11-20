import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:game_app/utils/server_status.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// "Technical work is going on": shown over the whole app while the server does not answer
/// or is under maintenance. It checks again every 10 seconds and closes itself when the
/// server is back; the button checks at once. The picture is `assets/image/maintenance.webp`
/// (an icon is drawn until it exists).
class MaintenanceDialog extends StatefulWidget {
  const MaintenanceDialog({required this.first, super.key});

  final ServerState first;

  @override
  State<MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<MaintenanceDialog> {
  late ServerState _state = widget.first;
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _retry());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_checking || !mounted) {
      return;
    }
    setState(() => _checking = true);
    final state = await ServerStatus.check();
    if (!mounted) {
      return;
    }
    if (state.isUp) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _state = state;
      _checking = false;
    });
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final since = _state.since;
    final message = (_state.message ?? '').trim().isNotEmpty ? _state.message! : 'maintenanceText'.tr;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.size.height * 0.9),
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _gold.withValues(alpha: 0.4)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF111113)]),
            boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.18), blurRadius: 40)],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/image/maintenance.webp',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 110,
                    height: 110,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.13),
                      border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.6),
                    ),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: _gold, size: 54, strokeWidth: 1.7),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'maintenanceTitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 23, height: 1.2),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFD5D5DA), fontFamily: gilroyMedium, fontSize: 15.5, height: 1.4),
                ),
                if (since != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${'maintenanceSince'.tr}: ${_two(since.day)}.${_two(since.month)}.${since.year}  ${_two(since.hour)}:${_two(since.minute)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _gold, fontFamily: gilroySemiBold, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _retry,
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                      boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: _checking
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                        : Text(
                            'noConnection3'.tr,
                            style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'maintenanceAuto'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
