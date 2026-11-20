// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:game_app/connection_check.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';

// import 'package:restart_app/restart_app.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static const _gold = Color(0xFFFFC83D);
  static const _red = Color(0xFFFF5A5F);

  @override
  void initState() {
    super.initState();
    SupportPush.refreshUnread();
  }

  Future<void> _openSupport() async {
    await Get.to(() => const SupportChatPage());
    await SupportPush.refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    final isTm = Get.locale!.toLanguageTag() == 'tr';
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: 'settings'.tr, onBack: Get.back),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _hero(),
                  _tile(icon: HugeIcons.strokeRoundedLanguageSquare, title: 'select_language'.tr, trailing: _languageTrailing(isTm), onTap: changeLanguage),
                  _tile(icon: HugeIcons.strokeRoundedCustomerSupport, title: 'support'.tr, trailing: _supportTrailing(), onTap: _openSupport),
                  _tile(icon: HugeIcons.strokeRoundedShare08, title: 'share'.tr, trailing: _chevron(), onTap: _shareApp),
                  const SizedBox(height: 10),
                  _tile(icon: HugeIcons.strokeRoundedDelete02, title: 'deleteAccount'.tr, color: _red, trailing: _chevron(color: _red), onTap: _confirmDeleteAccount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The app name and version: one flat card at the top.
  Widget _hero() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: const Color(0xFF1B1B1F), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: _gold),
            child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: Color(0xFF1A1200), size: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20)),
                const SizedBox(height: 3),
                Text('${'versia'.tr} 1.0.1', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontFamily: gilroyMedium, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One flat button-card: an icon tile, the title, something at the end.
  Widget _tile({required List<List<dynamic>> icon, required String title, Widget? trailing, VoidCallback? onTap, Color color = Colors.white}) {
    final accent = color == Colors.white ? _gold : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF1B1B1F),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: accent.withValues(alpha: 0.10),
          highlightColor: accent.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)),
                  child: Center(child: HugeIcon(icon: icon, color: accent, size: 22, strokeWidth: 1.8)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontFamily: gilroySemiBold, fontSize: 17)),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The flag of the language in use, then the arrow.
  Widget _languageTrailing(bool isTm) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_flag(isTm ? tmIcon : ruIcon), const SizedBox(width: 6), _chevron()],
    );
  }

  Widget _supportTrailing() {
    return ValueListenableBuilder<int>(
      valueListenable: SupportPush.unread,
      builder: (context, unread, _) {
        if (unread <= 0) {
          return _chevron();
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(12)),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 12)),
            ),
            _chevron(),
          ],
        );
      },
    );
  }

  Widget _chevron({Color color = Colors.white54}) => Icon(Icons.chevron_right_rounded, color: color, size: 24);

  Widget _flag(String asset) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: borderRadius30,
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }

  /// Asks once more before the account is removed.
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showConfirmDialog(
      icon: HugeIcons.strokeRoundedDelete02,
      title: 'deleteAccount'.tr,
      message: 'deleteAccountConfirm'.tr,
      confirmLabel: 'yes'.tr,
    );
    if (!confirmed) {
      return;
    }
    // Restart.restartApp();
    await Auth().removeToken();
    await Auth().removeRefreshToken();
    // Not awaited: the page stays open, and the tokens are already gone.
    unawaited(Get.to(() => const ConnectionCheck()));
  }

  /// Shares the store page of the platform the app is running on.
  Future<void> _shareApp() async {
    final link = Platform.isIOS ? appStoreLink : playStoreLink;
    await SharePlus.instance.share(ShareParams(text: '$appName\n$link', subject: appName));
  }
}
