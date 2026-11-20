import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:game_app/views/constants/constants.dart';

const catalogGold = Color(0xFFFFC83D);
const catalogGoldDark = Color(0xFFFF9800);

/// "125" for 125.0, "12.5" for 12.5.
String catalogMoney(double value) => value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(2);

/// A network picture that never shows a broken image: [fallback] while empty, loading or failed.
class CatalogImage extends StatelessWidget {
  const CatalogImage({required this.url, this.fit = BoxFit.cover, this.icon = Icons.image_outlined, super.key});

  final String url;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      color: const Color(0xFF1B1B1E),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white24, size: 32),
    );
    if (url.isEmpty) {
      return fallback();
    }
    return CachedNetworkImage(imageUrl: url, fit: fit, fadeInCurve: Curves.ease, placeholder: (context, url) => fallback(), errorWidget: (context, url, error) => fallback());
  }
}

/// The gold pill button used by the catalog screens.
class CatalogGoldButton extends StatelessWidget {
  const CatalogGoldButton({required this.label, required this.onTap, this.busy = false, this.height = 54, super.key});

  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: const LinearGradient(colors: [Color(0xFFFFD866), catalogGoldDark]),
            boxShadow: [BoxShadow(color: catalogGold.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
              : Text(
                  label,
                  style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 17),
                ),
        ),
      ),
    );
  }
}
