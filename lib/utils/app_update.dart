import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// Forced update: `GET /api/app-version/?platform=&version=` says `update_required` when this
/// build is older than the latest one. A blocking window with a store button then covers the app.
/// A failed request never blocks. Checked at start and whenever the app returns from the background.
class AppUpdate with WidgetsBindingObserver {
  AppUpdate._();

  static final AppUpdate instance = AppUpdate._();

  bool _started = false;
  bool _open = false;

  /// Checks now and on every resume. Safe to call more than once.
  void start() {
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      check();
    }
  }

  Future<void> check() async {
    if (_open) {
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await http.get(Uri.parse('$serverURL/api/app-version/?platform=$platform&version=${info.version}')).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return;
      }
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is! Map || data['update_required'] != true) {
        return;
      }
      final ru = Get.locale?.languageCode == 'ru';
      final message = '${data[ru ? 'message_ru' : 'message_tm'] ?? ''}'.trim();
      _open = true;
      await Get.dialog<void>(
        _UpdateWindow(message: message, version: '${data['latest_version'] ?? ''}', storeUrl: '${data['store_url'] ?? ''}'),
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
      );
    } catch (_) {
      // No internet or a timeout: the user is let in.
    } finally {
      _open = false;
    }
  }
}

class _UpdateWindow extends StatelessWidget {
  const _UpdateWindow({required this.message, required this.version, required this.storeUrl});

  final String message;
  final String version;
  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _gold.withValues(alpha: 0.4)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF111113)]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update_rounded, color: _gold, size: 56),
              const SizedBox(height: 16),
              Text('updateRequiredTitle'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: gilroyMedium, fontSize: 15, height: 1.35)),
              if (version.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('updateNewVersion'.trParams({'version': version}), style: const TextStyle(color: _gold, fontFamily: gilroySemiBold, fontSize: 14)),
              ],
              if (storeUrl.isNotEmpty) ...[
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication),
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [_gold, _goldDark])),
                    child: Text('updateButton'.tr, style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
