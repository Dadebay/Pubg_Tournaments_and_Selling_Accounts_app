import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/index.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// The page a banner opens when it has no action: its picture, the title, the text
/// and, when there is a phone number (given or written in the text), a call button.
class BannerProfileView extends StatelessWidget {
  final String description;
  final String pageName;
  final String image;

  /// A number to call; when empty the first number found in the text is used.
  final String? phone;

  const BannerProfileView(this.pageName, this.image, this.description, {this.phone, super.key});

  String get _plainText => description.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ');

  String? get _number {
    final given = (phone ?? '').trim();
    if (given.isNotEmpty) {
      return given;
    }
    return RegExp(r'\+?\d[\d\s-]{7,}\d').firstMatch(_plainText)?.group(0)?.trim();
  }

  Future<void> _call(String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isNotEmpty) {
      await launchUrl(Uri(scheme: 'tel', path: digits));
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = _number;
    final hasText = _plainText.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: pageName, onBack: Get.back),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + (number != null ? 80 : 0) + MediaQuery.paddingOf(context).bottom),
                children: [
                  _picture(),
                  if (pageName.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      pageName,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 26, height: 1.15),
                    ),
                  ],
                  if (hasText) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
                      ),
                      child: Html(
                        data: description,
                        style: {
                          'body': Style(
                            fontFamily: gilroyMedium,
                            fontSize: FontSize(17.0),
                            color: const Color(0xFFE6E6EA),
                            textAlign: TextAlign.left,
                            lineHeight: const LineHeight(1.45),
                            margin: Margins.zero,
                          ),
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: number == null ? null : _callBar(number),
    );
  }

  Widget _picture() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
        color: const Color(0xFF1B1B1E),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.12), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.5),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: CachedNetworkImage(
            fadeInCurve: Curves.ease,
            imageUrl: image,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(child: spinKit()),
            errorWidget: (context, url, error) => noBannerImage(),
          ),
        ),
      ),
    );
  }

  /// The call button, fixed at the bottom of the page.
  Widget _callBar(String number) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(Get.context!).bottom),
      decoration: BoxDecoration(
        color: const Color(0xF2131315),
        border: Border(top: BorderSide(color: _gold.withValues(alpha: 0.25))),
      ),
      child: GestureDetector(
        onTap: () => _call(number),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
            boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedCall02, color: Colors.black, size: 22, strokeWidth: 2.2),
              const SizedBox(width: 10),
              Text(
                number,
                style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
