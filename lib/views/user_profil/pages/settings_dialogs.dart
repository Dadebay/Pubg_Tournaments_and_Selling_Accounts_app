import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';

/// Shows the privacy policy served by `/about/privacy/`.
Future<void> showPrivacyDialog() async {
  final result = await UcdayyApi.getPrivacy();
  final data = result.data;
  final text = _privacyText(data);
  if (!result.ok || text == null) {
    showSnackBar('noConnection3', result.error ?? 'errorEmpty', Colors.red);
    return;
  }
  await Get.dialog(
    AlertDialog(
      backgroundColor: kPrimaryColorBlack,
      shape: const RoundedRectangleBorder(borderRadius: borderRadius20, side: BorderSide(color: Colors.white)),
      title: Text('privacy'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20)),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Html(data: text, style: {'body': Style(color: Colors.white, fontFamily: gilroyRegular, fontSize: FontSize(16))}),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr, style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold))),
      ],
    ),
  );
}

/// The answer is either `{ text/content/privacy... }`, a list of such maps or a plain string.
String? _privacyText(dynamic data) {
  if (data is String) {
    return data;
  }
  final items = apiItems(data);
  final map = items.isNotEmpty ? items.first : (data is Map ? data : null);
  if (map == null) {
    return null;
  }
  final isRu = Get.locale?.languageCode == 'ru';
  for (final key in [if (isRu) 'text_ru' else 'text_tm', if (isRu) 'content_ru' else 'content_tm', 'text', 'content', 'privacy', 'body']) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

/// Asks for a new password twice and sends it to `/accounts/change-password/`.
Future<void> showChangePasswordDialog() async {
  final password = TextEditingController();
  final password2 = TextEditingController();
  var busy = false;
  await Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        Future<void> submit() async {
          if (password.text.isEmpty || password.text != password2.text) {
            showSnackBar('', 'passwordMismatch', Colors.red);
            return;
          }
          setState(() => busy = true);
          final result = await UcdayyApi.changePassword(password: password.text, password2: password2.text);
          if (result.ok) {
            Get.back();
            showSnackBar('', 'passwordChanged', Colors.green);
          } else {
            setState(() => busy = false);
            showSnackBar('noConnection3', result.error ?? 'errorEmpty', Colors.red);
          }
        }

        InputDecoration decoration(String hint) => InputDecoration(
              hintText: hint.tr,
              hintStyle: const TextStyle(color: Colors.white54, fontFamily: gilroyRegular),
              enabledBorder: const OutlineInputBorder(borderRadius: borderRadius15, borderSide: BorderSide(color: Colors.white38)),
              focusedBorder: const OutlineInputBorder(borderRadius: borderRadius15, borderSide: BorderSide(color: kPrimaryColor)),
            );

        return AlertDialog(
          backgroundColor: kPrimaryColorBlack,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius20, side: BorderSide(color: Colors.white)),
          title: Text('changePassword'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: password, obscureText: true, style: const TextStyle(color: Colors.white), decoration: decoration('newPassword')),
              const SizedBox(height: 12),
              TextField(controller: password2, obscureText: true, style: const TextStyle(color: Colors.white), decoration: decoration('repeatPassword')),
            ],
          ),
          actions: [
            TextButton(onPressed: Get.back, child: Text('cancel'.tr, style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold))),
            TextButton(
              onPressed: busy ? null : submit,
              child: Text('agree'.tr, style: const TextStyle(color: kPrimaryColor, fontFamily: gilroyBold)),
            ),
          ],
        );
      },
    ),
  );
  password.dispose();
  password2.dispose();
}
