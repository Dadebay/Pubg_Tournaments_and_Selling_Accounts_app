// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';
import '../other_pages/account_profil_page/account_profil_page.dart';
import '../other_pages/account_profil_page/video_preview.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// An account for sale: a dark card with a gold frame and gold corner stripes.
/// Left the account's picture, right the title line, the price with a coin stack
/// (`assets/image/coin_stack.webp`, an icon is drawn without it) and the date.
class HomePageCard extends StatelessWidget {
  final bool vip;
  final GetPostsAccountModel model;
  const HomePageCard({required this.vip, required this.model, super.key});

  /// "3000.00" → "3000", "12.50" → "12.5".
  String get _price {
    final value = double.tryParse('${model.price}');
    if (value == null) {
      return '${model.price}';
    }
    return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);
  }

  String get _title {
    final parts = [(model.phone ?? '').trim(), (model.pubgID ?? '').trim()].where((e) => e.isNotEmpty && e != 'null');
    return parts.join(' / ');
  }

  String get _date {
    final value = model.createdAt ?? '';
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = model.vip == true;
    return GestureDetector(
      onTap: () => Get.to(() => AccountProfilPage(userID: model.id!)),
      child: Container(
        height: 172,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.all(1.6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _gold.withValues(alpha: highlighted ? 1 : 0.75),
              _goldDark.withValues(alpha: highlighted ? 0.9 : 0.5),
              _gold.withValues(alpha: highlighted ? 1 : 0.75),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: highlighted ? 0.3 : 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.5),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F1F24), Color(0xFF0E0E10)]),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _CornerStripes())),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      AspectRatio(aspectRatio: 0.82, child: _picture()),
                      const SizedBox(width: 14),
                      Expanded(child: _details()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _picture() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              fadeInCurve: Curves.ease,
              imageUrl: mediaUrl(model.image),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.white.withValues(alpha: 0.05),
                child: Center(child: spinKit()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.white.withValues(alpha: 0.08),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  'noImageBanner'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The text side: the title, the price in a gold chip and the date in a small pill.
  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_title.isNotEmpty)
          Text(
            _title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17, height: 1.1),
          ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withValues(alpha: 0.45)),
            gradient: LinearGradient(colors: [_gold.withValues(alpha: 0.2), _gold.withValues(alpha: 0.06)]),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AssetOr(
                asset: 'assets/image/coin_stack.webp',
                height: 26,
                fallback: const HugeIcon(icon: HugeIcons.strokeRoundedCoins01, color: _gold, size: 24, strokeWidth: 1.8),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      text: _price,
                      style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 24, height: 1.1),
                      children: const [
                        TextSpan(
                          text: ' TMT',
                          style: TextStyle(color: Color(0xFFE6C36A), fontFamily: gilroySemiBold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withValues(alpha: 0.07)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, color: Color(0xFF9A9AA3), size: 15, strokeWidth: 1.8),
              const SizedBox(width: 6),
              Text(
                _date,
                style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyMedium, fontSize: 13, height: 1.1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A picture from the assets; [fallback] is drawn while the file does not exist.
class _AssetOr extends StatelessWidget {
  const _AssetOr({required this.asset, required this.height, required this.fallback});

  final String asset;
  final double height;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, height: height, fit: BoxFit.contain, cacheHeight: (height * 3).round(), errorBuilder: (context, error, stackTrace) => fallback);
  }
}

/// The gold stripes in the top-right and bottom-right corners of the card.
class _CornerStripes extends CustomPainter {
  const _CornerStripes();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE08A), _goldDark]).createShader(Rect.fromLTWH(0, 0, w, h));
    void stripe(double a, double t, {required bool bottom}) {
      final path = Path();
      if (bottom) {
        path
          ..moveTo(w - a, h)
          ..lineTo(w - a + t, h)
          ..lineTo(w, h - a + t)
          ..lineTo(w, h - a);
      } else {
        path
          ..moveTo(w - a, 0)
          ..lineTo(w - a + t, 0)
          ..lineTo(w, a - t)
          ..lineTo(w, a);
      }
      canvas.drawPath(path..close(), paint);
    }

    stripe(70, 15, bottom: true);
    stripe(38, 9, bottom: true);
    stripe(46, 8, bottom: false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
