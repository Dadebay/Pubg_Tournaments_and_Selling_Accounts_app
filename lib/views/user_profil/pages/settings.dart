// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:game_app/connection_check.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/views/constants/index.dart';
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
  Widget build(BuildContext context) {
    final isTm = Get.locale!.toLanguageTag() == 'tr';
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, fontSize: 0.0, name: 'settings', elevationWhite: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _group([_row(icon: HugeIcons.strokeRoundedLanguageSquare, title: isTm ? 'Türkmen dili' : 'Rus dili', trailing: _flag(isTm ? tmIcon : ruIcon), onTap: changeLanguage), _row(icon: HugeIcons.strokeRoundedInformationCircle, title: 'versia'.tr, trailing: _value('1.0.1'))]),
          _group([_row(icon: HugeIcons.strokeRoundedShare08, title: 'share'.tr, trailing: _chevron(), onTap: _shareApp)]),
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

  Widget _chevron({Color color = Colors.white54}) => Icon(Icons.chevron_right_rounded, color: color, size: 24);

  Widget _value(String text) => Text(
    text,
    style: const TextStyle(color: _gold, fontFamily: gilroySemiBold, fontSize: 16),
  );

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
    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _red.withValues(alpha: 0.14),
                  border: Border.all(color: _red.withValues(alpha: 0.4)),
                ),
                child: const Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: _red, size: 30),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'deleteAccount'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21),
              ),
              const SizedBox(height: 8),
              Text(
                'deleteAccountConfirm'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontFamily: gilroyMedium, fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _dialogButton('no'.tr, Colors.white.withValues(alpha: 0.1), Colors.white, () => Get.back(result: false))),
                  const SizedBox(width: 12),
                  Expanded(child: _dialogButton('yes'.tr, _red, Colors.white, () => Get.back(result: true))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) {
      return;
    }
    // Restart.restartApp();
    await Auth().removeToken();
    await Auth().removeRefreshToken();
    // Not awaited: the page stays open, and the tokens are already gone.
    unawaited(Get.to(() => const ConnectionCheck()));
  }

  Widget _dialogButton(String label, Color background, Color foreground, VoidCallback onTap) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: foreground, fontFamily: gilroySemiBold, fontSize: 17),
            ),
          ),
        ),
      ),
    );
  }

  /// Shares the store page of the platform the app is running on.
  Future<void> _shareApp() async {
    final link = Platform.isIOS ? appStoreLink : playStoreLink;
    await SharePlus.instance.share(ShareParams(text: '$appName\n$link', subject: appName));
  }
}
