import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/models/add_account_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/index.dart';

const _gold = Color(0xFFFFC83D);

/// The service notice shown right under the video of an account: a shield, the
/// first lines of the server's text and a call button when the text has a phone
/// number. A tap opens the whole text.
class AccountNotice extends StatefulWidget {
  const AccountNotice({super.key});

  @override
  State<AccountNotice> createState() => _AccountNoticeState();
}

class _AccountNoticeState extends State<AccountNotice> {
  late final Future<dynamic> _consts = AddAccountModel().getConsts();

  String _plain(String html) {
    return html
        .replaceAll(RegExp(r'<(br|/p|/div|/li)[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _consts,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final html = data is Map ? '${data['text_one'] ?? ''}' : '';
        if (html.trim().isEmpty) {
          return const SizedBox(height: 0);
        }
        final text = _plain(html);
        final phone = RegExp(r'\+?\d[\d\s-]{7,}\d').firstMatch(text)?.group(0)?.trim();
        return GestureDetector(
          onTap: () => showDialog(context: context, barrierColor: Colors.black.withValues(alpha: 0.75), builder: (context) => _noticeDialog(html, phone)),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.4)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold.withValues(alpha: 0.16), const Color(0xFF161618)]),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withValues(alpha: 0.15)),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedShield01, color: _gold, size: 22, strokeWidth: 1.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFE6E6EA), fontFamily: gilroyMedium, fontSize: 12.5, height: 1.3),
                  ),
                ),
                if (phone != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''))),
                    child: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                      ),
                      child: const HugeIcon(icon: HugeIcons.strokeRoundedCall02, color: Colors.black, size: 20, strokeWidth: 2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _noticeDialog(String html, String? phone) {
  const gold = Color(0xFFFFC83D);
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
    child: Container(
      constraints: BoxConstraints(maxHeight: Get.size.height * 0.82),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2415), Color(0xFF131315)]),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.15), blurRadius: 36)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.14),
              border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedShield01, color: gold, size: 32, strokeWidth: 1.8),
          ),
          const SizedBox(height: 14),
          Text(
            'accountsForSale'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Html(
                  data: html,
                  style: {
                    'body': Style(
                      fontFamily: gilroyMedium,
                      fontSize: FontSize(16.0),
                      color: const Color(0xFFE6E6EA),
                      textAlign: TextAlign.center,
                      lineHeight: const LineHeight(1.4),
                      margin: Margins.zero,
                    ),
                  },
                ),
              ),
            ),
          ),
          if (phone != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''))),
              child: Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withValues(alpha: 0.6)),
                  color: gold.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(icon: HugeIcons.strokeRoundedCall02, color: gold, size: 20, strokeWidth: 1.8),
                    const SizedBox(width: 10),
                    Text(
                      phone,
                      style: const TextStyle(color: gold, fontFamily: gilroyBold, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: Get.back,
            child: Container(
              height: 54,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Text(
                'readAndAgree'.tr,
                style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
