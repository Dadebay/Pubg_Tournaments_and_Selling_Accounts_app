import 'package:game_app/connection_check.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';

const _gold = Color(0xFFFFC83D);
const _red = Color(0xFFFF5A5F);
const _cardTop = Color(0xFF232327);
const _cardBottom = Color(0xFF151517);

const _cardGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_cardTop, _cardBottom]);

/// Centered card dialog with a round icon, a title, a message and two buttons.
/// Resolves to true when the confirm button is pressed.
Future<bool> showConfirmDialog({
  required List<List<dynamic>> icon,
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  Color color = _red,
}) async {
  final result = await Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: _cardGradient, border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14), border: Border.all(color: color.withValues(alpha: 0.4))),
              child: Center(child: HugeIcon(icon: icon, color: color, size: 30)),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontFamily: gilroyMedium, fontSize: 15, height: 1.35)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _DialogButton(label: cancelLabel ?? 'no'.tr, background: Colors.white.withValues(alpha: 0.1), foreground: Colors.white, onTap: () => Get.back(result: false))),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(label: confirmLabel, background: color, foreground: color == _gold ? const Color(0xFF1A1200) : Colors.white, onTap: () => Get.back(result: true)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result == true;
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.background, required this.foreground, required this.onTap});

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(child: Text(label, style: TextStyle(color: foreground, fontFamily: gilroySemiBold, fontSize: 17))),
        ),
      ),
    );
  }
}

/// Bottom sheet shell: rounded top, drag handle, title and a close button.
Future<T?> _showSheet<T>({required String title, required Widget child}) {
  return Get.bottomSheet<T>(
    SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: _cardGradient, border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20))),
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                      child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

Future<void> logOut(BuildContext context) async {
  final confirmed = await showConfirmDialog(icon: HugeIcons.strokeRoundedLogout01, title: 'log_out'.tr, message: 'log_out_title'.tr, confirmLabel: 'yes'.tr);
  if (!confirmed) {
    return;
  }
  await Auth().logout();
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const ConnectionCheck()), (Route<dynamic> route) => false);
}

void changeLanguage() {
  final SettingsController settingsController = Get.put(SettingsController());
  final current = Get.locale?.languageCode == 'ru' ? 'ru' : 'tr';

  Widget option(String code, String name, String flag) {
    final selected = code == current;
    return GestureDetector(
      onTap: () {
        settingsController.switchLang(code);
        Get.back();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? _gold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: selected ? _gold : Colors.white.withValues(alpha: 0.08), width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(flag), backgroundColor: Colors.white, radius: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 17))),
            if (selected) const Icon(Icons.check_circle_rounded, color: _gold, size: 24) else Icon(Icons.circle_outlined, color: Colors.white.withValues(alpha: 0.25), size: 24),
          ],
        ),
      ),
    );
  }

  _showSheet<void>(
    title: 'select_language'.tr,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [option('tr', 'Türkmen', tmIcon), option('ru', 'Русский', ruIcon)]),
    ),
  );
}

void defaultBottomSheet({required String name, required Widget child}) {
  _showSheet<void>(
    title: name.tr,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Center(child: child),
    ),
  );
}

/// Asks the visitor to sign in (`text2 == 'welcome'`) or to confirm a delete.
Future<Object?> showDeleteDialog(BuildContext context, String text, String text2, Function() onTap) async {
  final welcome = text2 == 'welcome';
  final confirmed = await showConfirmDialog(
    icon: welcome ? HugeIcons.strokeRoundedLogin01 : HugeIcons.strokeRoundedDelete02,
    title: text.tr,
    message: text2.tr,
    confirmLabel: (welcome ? 'signUp' : 'yes').tr,
    color: welcome ? _gold : _red,
  );
  if (confirmed) {
    onTap();
  }
  return confirmed;
}
