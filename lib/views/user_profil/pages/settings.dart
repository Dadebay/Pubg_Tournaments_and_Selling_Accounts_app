// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:game_app/connection_check.dart';
import 'package:game_app/models/user_models/auth_model.dart';
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
      appBar: const MyAppBar(backArrow: true, iconRemove: true, fontSize: 0.0, name: 'settings', elevationWhite: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _hero(),
          _label('select_language'),
          _group([_row(icon: HugeIcons.strokeRoundedLanguageSquare, title: isTm ? 'Türkmen dili' : 'Rus dili', trailing: _flag(isTm ? tmIcon : ruIcon), onTap: changeLanguage)]),
          _label('support'),
          _group([_row(icon: HugeIcons.strokeRoundedCustomerSupport, title: 'support'.tr, trailing: _supportTrailing(), onTap: _openSupport)]),
          _label('share'),
          _group([_row(icon: HugeIcons.strokeRoundedShare08, title: 'share'.tr, trailing: _chevron(), onTap: _shareApp)]),
          const SizedBox(height: 8),
          _group([
            _row(
              icon: HugeIcons.strokeRoundedDelete02,
              title: 'deleteAccount'.tr,
              color: _red,
              trailing: _chevron(color: _red),
              onTap: _confirmDeleteAccount,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold.withValues(alpha: 0.2), const Color(0xFF151517)]),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)])),
            child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: Color(0xFF1A1200), size: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20)),
                const SizedBox(height: 3),
                Text('${'versia'.tr} 1.0.1', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroyMedium, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String key) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 10),
    child: Text(key.tr, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroySemiBold, fontSize: 13)),
  );

  /// A rounded card holding rows separated by hairlines.
  Widget _group(List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[if (i > 0) Divider(height: 1, indent: 68, color: Colors.white.withValues(alpha: 0.07)), rows[i]],
        ],
      ),
    );
  }

  Widget _row({required List<List<dynamic>> icon, required String title, Widget? trailing, VoidCallback? onTap, Color color = Colors.white}) {
    final accent = color == Colors.white ? _gold : color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: HugeIcon(icon: icon, color: accent, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontFamily: gilroySemiBold, fontSize: 17),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
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
