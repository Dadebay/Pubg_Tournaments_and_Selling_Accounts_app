import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'constants.dart';

/// A compact message for catalog tabs with no content or a load error.
class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({required this.icon, required this.title, required this.description, this.imageAsset, this.actionLabel, this.actionIcon = IconlyLight.arrowRight, this.onAction, super.key});

  final IconData icon;
  final String title;
  final String description;
  final String? imageAsset;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  static const _gold = Color(0xFFFFC83D);
  static const _goldDark = Color(0xFFFF9800);

  /// The icon in a gold-lit badge: a soft glow, a thin ring and a dark disc, with a few sparkles.
  Widget _badge() {
    Widget dot(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _gold.withValues(alpha: alpha),
      ),
    );
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [_gold.withValues(alpha: 0.22), _gold.withValues(alpha: 0.0)]),
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.22), width: 1.2),
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.6), width: 1.6),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E2713), Color(0xFF141416)]),
              boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.25), blurRadius: 22)],
            ),
            child: Icon(icon, color: _gold, size: 40),
          ),
          Positioned(top: 18, right: 22, child: dot(7, 0.7)),
          Positioned(bottom: 24, left: 14, child: dot(5, 0.45)),
          Positioned(top: 40, left: 6, child: dot(4, 0.35)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = (MediaQuery.sizeOf(context).width - 56).clamp(220.0, 340.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset != null)
            Image.asset(imageAsset!, width: imageWidth, height: imageWidth * 0.67, fit: BoxFit.contain, filterQuality: FilterQuality.high, excludeFromSemantics: true)
          else
            _badge(),
          SizedBox(height: imageAsset == null ? 14 : 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22, height: 1.2),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB8B8C0), fontFamily: gilroyRegular, fontSize: 15, height: 1.45),
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 26),
            GestureDetector(
              onTap: onAction,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD866), _goldDark]),
                  boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(actionIcon, size: 19, color: const Color(0xFF1A1200)),
                    const SizedBox(width: 8),
                    Text(
                      actionLabel!,
                      style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 15.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
